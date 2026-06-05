# Presentation Script: W8 K8s Project

## 1. Mở đầu

Chào mentor, đây là project cuối tuần 8 của em: dựng một ứng dụng chạy trong Kubernetes trên AWS bằng Terraform.

Mục tiêu chính của project là chứng minh 5 điểm:

- Hạ tầng AWS được dựng bằng Terraform.
- Kubernetes chạy trên một EC2 bằng minikube.
- Ứng dụng không cài trực tiếp trên EC2, mà chạy trong Kubernetes Pods.
- Người dùng Internet truy cập app qua AWS Application Load Balancer.
- Có thể deploy bằng một lệnh và destroy sạch sau khi hoàn thành.

Ứng dụng của em là **Cloud Launch Console**, một dashboard nhỏ để trình bày trạng thái triển khai, đường đi traffic và các evidence cần có cho bài cloud deployment.

## 2. Kiến trúc tổng quan

Luồng traffic của project:

```text
Internet
  -> Application Load Balancer :80
  -> EC2 instance :30080
  -> minikube NodePort Service :30080
  -> Kubernetes Service
  -> Next.js Pods :80
```

Terraform tạo các resource chính:

- VPC và public subnets.
- Security groups cho ALB và EC2.
- EC2 instance để chạy Docker, minikube và kubectl.
- ALB, listener HTTP port 80 và target group trỏ vào EC2 port 30080.
- IAM role cho EC2 đọc artifact từ S3.
- Private S3 bucket dùng để stage source `web-app/` và manifest `k8s/`.

Trên EC2, cloud-init sẽ:

- Cài Docker, kubectl và minikube.
- Start minikube bằng Docker driver.
- Mở port mapping `30080:30080`.
- Tải source app và manifest từ S3.
- Build Docker image Next.js static app.
- Load image vào minikube.
- Apply Kubernetes manifests.
- Chờ Pod ready.

## 3. Vì sao chọn thiết kế này

Em chọn minikube vì minikube có cơ chế `--ports` với Docker driver để map NodePort ra host EC2 rõ ràng.

Em chọn NodePort cố định `30080` vì ALB target group có thể forward thẳng vào EC2 port đó. Cách này đơn giản, dễ giải thích, không cần AWS Load Balancer Controller hoặc EKS.

Em dùng static Next.js export chạy bằng Nginx vì app chỉ là dashboard frontend, không cần server runtime. Container vẫn listen port `80`, phù hợp với Kubernetes Deployment và Service hiện tại.

## 4. Terraform provider wiring

Project dùng nhiều hơn một Terraform provider:

- `aws`: tạo toàn bộ AWS infrastructure như VPC, EC2, ALB, IAM, S3 và security groups.
- `cloudinit`: render bootstrap script cho EC2 dưới dạng cloud-init user data.

Điểm wiring nằm ở `aws_instance.user_data`. Terraform lấy output từ `data.cloudinit_config.minikube.rendered` và truyền vào module EC2.

Điều này tạo dependency tự nhiên: Terraform render script trước, sau đó EC2 được tạo với user data đã hoàn chỉnh. Trong cùng một lần `terraform apply`, hạ tầng AWS và bootstrap logic được điều phối cùng nhau.

## 5. One-click deploy demo

Lệnh deploy từ repo:

```powershell
cd cloud\w8\k8s-project
.\scripts\deploy.ps1
```

Script này chạy:

- `terraform init`
- `terraform apply -auto-approve`
- In ra ALB URL
- Poll endpoint `/healthz` đến khi app ready

Sau khi hoàn tất, lấy URL bằng:

```powershell
terraform output -raw alb_url
```

Mở URL đó trên browser để chứng minh app truy cập được qua ALB.

## 6. Evidence nên trình bày

Các ảnh evidence chính nằm trong thư mục `evidence/`:

- `alb-browser-home.png`: browser mở được app bằng ALB DNS.
- `terraform-apply-success.png`: deploy script chạy thành công và health check ready.
- `kubernetes-pods-service.png`: Pod và Service chạy trong namespace `k8s-project`.
- `terraform-plan-no-changes.png`: chạy lại plan không có thay đổi, chứng minh reproducible.
- `terraform-destroy-success.png`: destroy sạch tài nguyên sau khi hoàn thành.

Khi demo với mentor, em sẽ đi theo thứ tự:

1. Mở README để giới thiệu kiến trúc.
2. Mở ALB URL để chứng minh app public.
3. Mở evidence Kubernetes để chứng minh app chạy trong Pods.
4. Giải thích provider wiring.
5. Chạy hoặc trình bày lệnh destroy để chứng minh dọn được sạch.

## 7. Câu hỏi mentor có thể hỏi

### Câu 1: App có thật sự chạy trong Kubernetes không?

Có. EC2 chỉ dùng để chạy Docker, minikube và kubectl. App được build thành Docker image, load vào minikube, rồi chạy bằng Kubernetes Deployment trong namespace `k8s-project`.

Evidence là lệnh:

```bash
kubectl get pods,svc -n k8s-project
```

Pod app phải ở trạng thái `Running`, Service là `NodePort`, và nodePort là `30080`.

### Câu 2: ALB forward vào Kubernetes bằng cách nào?

ALB không forward trực tiếp vào Pod. ALB target group forward vào EC2 port `30080`.

Port `30080` là NodePort của Kubernetes Service. Minikube được start với Docker driver và mapping `--ports=30080:30080`, nên request từ host EC2 vào port 30080 sẽ tới Service trong minikube, sau đó Service route đến Pod.

### Câu 3: Vì sao không dùng EKS?

Đề bài yêu cầu cụm Kubernetes chạy bằng minikube hoặc kind trên EC2, nên em không dùng EKS. Mục tiêu của bài là hiểu cách tự dựng K8s lab trên EC2 và expose app qua ALB.

### Câu 4: Vì sao chọn minikube thay vì kind?

Minikube Docker driver hỗ trợ port mapping bằng `minikube start --ports`. Với project này, em cần expose NodePort ra EC2 host để ALB forward được, nên minikube là lựa chọn trực tiếp và dễ kiểm soát.

### Câu 5: Vì sao dùng NodePort thay vì LoadBalancer Service?

Trong môi trường minikube trên EC2, `type: LoadBalancer` không tự tạo AWS ALB như EKS với AWS Load Balancer Controller. NodePort phù hợp hơn vì ALB đã được tạo bằng Terraform và chỉ cần target EC2 port cố định.

### Câu 6: Security group được thiết kế thế nào?

ALB nhận HTTP port `80` từ `allowed_web_cidrs`, mặc định là public để trainer truy cập được.

EC2 chỉ nhận app traffic port `30080` từ security group của ALB. SSH mặc định bị tắt vì `allowed_ssh_cidrs = []`, chỉ mở khi cần debug.

EC2 cần outbound Internet để cài package, pull binary, và build image trong bootstrap.

### Câu 7: Vì sao cần S3 artifact bucket?

Terraform không nên nhét toàn bộ source app và manifest lớn vào user data. Thay vào đó, Terraform upload source `web-app/` và `k8s/` lên private S3 bucket. EC2 dùng IAM instance role để tải artifact xuống trong bootstrap.

Cách này sạch hơn, dễ mở rộng hơn, và user data chỉ giữ logic bootstrap.

### Câu 8: Provider thứ hai được wire như thế nào?

Provider `cloudinit` render shell script thành cloud-init multipart config. Output của nó được truyền vào `user_data` của EC2 trong provider `aws`.

Vì `aws_instance` phụ thuộc vào rendered user data, Terraform biết thứ tự cần làm trong cùng một apply.

### Câu 9: Nếu `/healthz` chưa ready thì debug thế nào?

Em sẽ kiểm tra theo thứ tự:

1. ALB target group health status.
2. EC2 user data log:

```bash
sudo tail -n 200 /var/log/cloud-init-output.log
```

3. Minikube status:

```bash
minikube status
```

4. Kubernetes resources:

```bash
kubectl get pods,svc -n k8s-project
kubectl describe pod -n k8s-project
kubectl logs -n k8s-project deploy/k8s-project-app
```

5. Local NodePort on EC2:

```bash
curl http://127.0.0.1:30080/healthz
```

### Câu 10: Project có reproducible không?

Có. Hạ tầng được mô tả bằng Terraform, app source và Kubernetes manifest nằm trong repo, deploy bằng script một lệnh.

Evidence `terraform-plan-no-changes.png` cho thấy sau khi apply, chạy lại plan không tạo thay đổi ngoài ý muốn.

### Câu 11: Vì sao app là static Next.js thay vì backend app?

Mục tiêu bài là cloud infrastructure và Kubernetes deployment, không phải backend business logic. Static Next.js giúp app nhẹ, build nhanh, chạy ổn bằng Nginx, và vẫn đủ chuyên nghiệp để trình bày kiến trúc, evidence, runbook.

### Câu 12: Destroy có sạch không?

Có. Dùng:

```powershell
.\scripts\destroy.ps1
```

Script chạy `terraform destroy -auto-approve`. S3 artifact bucket có `force_destroy = true`, nên object trong bucket cũng được xoá cùng stack.

## 8. Kết luận

Project này đáp ứng yêu cầu challenge:

- Terraform dựng AWS infrastructure.
- Kubernetes chạy bằng minikube trên EC2.
- App chạy trong Kubernetes Pods.
- Internet truy cập qua ALB.
- Có một lệnh deploy và một lệnh destroy.
- Có ít nhất hai provider Terraform được wire trong cùng cấu hình.
- Có evidence chứng minh app chạy, có thể reproduce và destroy sạch.

