# Script trình bày dự án

## Mục tiêu

Tài liệu này là script nói trực tiếp khi trình bày dự án với mentor hoặc trainer.

Thời lượng phù hợp:

- Bản ngắn: 3 đến 5 phút
- Bản đầy đủ kèm demo: 7 đến 10 phút

## 1. Mở đầu

Chào mentor, đây là project tuần 8 của em về triển khai Kubernetes trên AWS bằng Terraform.

Mục tiêu của project là đáp ứng đầy đủ các yêu cầu của challenge:

- Hạ tầng AWS được dựng bằng Terraform
- Cụm Kubernetes chạy bằng minikube trên EC2
- Ứng dụng chạy trong Kubernetes, không cài trực tiếp lên EC2
- Ứng dụng truy cập được từ Internet qua ALB
- Có thể deploy bằng một lệnh và destroy sạch sau khi dùng
- Có ít nhất hai Terraform provider được wire trong cùng một cấu hình

Ứng dụng em chọn là một web app Next.js static tên là Cloud Launch Console. App này đóng vai trò như một dashboard nhỏ để trình bày trạng thái triển khai, luồng traffic và các evidence của bài challenge.

## 2. Tổng quan kiến trúc

Kiến trúc của project gồm các thành phần chính:

- Terraform là lớp điều phối toàn bộ hạ tầng
- AWS VPC là network nền
- Một EC2 instance chạy Docker và minikube
- Một private S3 artifact bucket dùng để stage source code
- IAM role cho phép EC2 đọc source từ S3
- ALB là entrypoint public từ Internet
- Trong minikube có Kubernetes Deployment và NodePort Service để chạy app

Nếu mô tả ngắn gọn luồng traffic thì là:

`Internet -> ALB:80 -> EC2:30080 -> minikube NodePort -> Kubernetes Service -> Pod -> web app`

Điểm quan trọng là ALB không đi thẳng vào Pod. ALB chỉ forward vào EC2 port 30080. Sau đó NodePort Service trong Kubernetes mới route tiếp vào Pod.

## 3. Vì sao em chọn cách triển khai này

Em chọn minikube thay vì kind vì đề bài cho phép cả hai, nhưng minikube với Docker driver hỗ trợ map NodePort ra host rõ ràng hơn qua `--ports`, nên rất phù hợp với mô hình ALB forward vào EC2.

Em chọn NodePort thay vì Kubernetes LoadBalancer Service vì đây không phải EKS. Trong minikube trên EC2, cách đơn giản và phù hợp nhất là dùng ALB của AWS trỏ vào EC2 port cố định, sau đó NodePort nhận traffic và chuyển vào Pod.

Em chọn Next.js static export chạy bằng Nginx vì app của bài này không cần backend động. Cách này giúp image nhẹ, startup nhanh, đơn giản cho health check và dễ chạy ổn định trong Kubernetes.

## 4. Terraform đang làm gì

Terraform của project này dùng hai provider:

- `hashicorp/aws`
- `hashicorp/cloudinit`

`aws` dùng để tạo:

- VPC
- subnets
- security groups
- S3 artifact bucket
- IAM role và instance profile
- EC2
- ALB, target group và listener

`cloudinit` dùng để render bootstrap script cho EC2 từ file `user_data.sh.tpl`.

Điểm wiring giữa hai provider là:

- `cloudinit` render ra `data.cloudinit_config.minikube.rendered`
- phần render đó được truyền vào `user_data` của EC2

Nói ngắn gọn, Terraform không chỉ tạo hạ tầng AWS mà còn truyền luôn logic bootstrap vào EC2 trong cùng một lần apply.

## 5. Vai trò của EC2 và bootstrap

EC2 trong project này không chạy app trực tiếp.

Vai trò của EC2 là:

- chạy Docker
- chạy minikube
- build Docker image từ source app
- apply manifest Kubernetes

Khi EC2 vừa được tạo, `user_data.sh.tpl` sẽ bootstrap máy bằng cách:

- cài Docker, kubectl, minikube
- tải source app và manifest từ private S3 bucket
- build image của app
- start minikube bằng Docker driver
- load image vào minikube
- apply các file trong thư mục `k8s`

Vì vậy app thực tế được chạy trong Pod của Kubernetes, không phải web server cài trực tiếp trên hệ điều hành EC2.

## 6. Vai trò của các file Kubernetes

Trong thư mục `k8s`, các file chính có vai trò như sau:

- `namespace.yaml`: tạo namespace riêng `k8s-project`
- `deployment.yaml`: chạy web app dưới dạng Deployment với 2 replicas
- `service.yaml`: tạo Service kiểu NodePort ở port 30080
- `kustomization.yaml`: gom tất cả manifest để apply một lần
- `smoke-test-client.yaml`: pod test nội bộ để kiểm tra service trong cluster

`deployment.yaml` có:

- `readinessProbe`
- `livenessProbe`
- `resources.requests`
- `resources.limits`

Những phần này bám sát các kỹ thuật thực hành quan trọng trong phần Kubernetes in Practice.

## 7. Cách deploy và kiểm tra

Project có one-click deploy bằng:

```powershell
cd cloud\w8\k8s-project
.\scripts\deploy.ps1
```

Script này sẽ:

- chạy `terraform init`
- chạy `terraform apply -auto-approve`
- lấy output `alb_url`
- chờ endpoint `/healthz` qua ALB trả HTTP 200

Sau khi deploy xong, có thể lấy URL bằng:

```powershell
terraform output -raw alb_url
```

Để kiểm tra app thực sự chạy trong Kubernetes, có thể dùng:

```bash
kubectl get pods,svc -n k8s-project
```

## 8. Evidence em chuẩn bị

Các evidence chính của project gồm:

- Browser mở được app qua ALB DNS
- Terraform apply thành công
- Kubernetes Pods và Service đang chạy
- Terraform plan không có thay đổi ngoài ý muốn
- Terraform destroy thành công

Những evidence này dùng để chứng minh:

- app public qua ALB
- app thật sự chạy trong Kubernetes
- project có thể reproduce
- hạ tầng có thể dọn sạch

## 9. Điểm em muốn nhấn mạnh với mentor

Ba điểm kỹ thuật quan trọng nhất của project là:

1. App chạy trong Kubernetes Pods, không chạy trực tiếp trên EC2
2. Terraform dùng nhiều provider trong cùng một cấu hình, cụ thể là `aws` và `cloudinit`
3. Traffic được expose ra Internet qua ALB bằng mô hình `ALB -> EC2 NodePort -> Kubernetes Service -> Pod`

## 10. Cách chốt bài

Tóm lại, project này đáp ứng đầy đủ yêu cầu challenge:

- AWS infrastructure được dựng bằng Terraform
- minikube chạy trên EC2
- app chạy trong Kubernetes
- app truy cập được qua ALB
- có one-click deploy
- có remote state trên S3
- có locking qua S3 backend `use_lockfile`
- có evidence và có destroy sạch

Nếu mentor muốn, em có thể đi sâu thêm vào một trong ba phần:

- Terraform wiring
- luồng traffic từ ALB vào Pod
- bootstrap của EC2 qua `user_data.sh.tpl`

## 11. Phiên bản cực ngắn để nói trong 60 giây

Đây là project Kubernetes on AWS bằng Terraform. Terraform tạo VPC, EC2, IAM, S3 artifact bucket và ALB. EC2 dùng cloud-init để cài Docker và minikube, tải source từ S3, build image và deploy app vào Kubernetes. App chạy trong Pod, được expose bằng NodePort 30080. ALB nhận request từ Internet và forward vào EC2, sau đó Kubernetes Service route vào Pod. Project có one-click deploy, remote state trên S3 và destroy sạch.

