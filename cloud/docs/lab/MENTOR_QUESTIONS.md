# Mentor Questions

## Mục đích tài liệu

Tài liệu này tổng hợp các câu hỏi trọng tâm mentor có thể hỏi, ý mà câu hỏi đó muốn kiểm tra, và câu trả lời ngắn gọn để trình bày.

## 1. Tổng quan dự án

### Dự án này làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu bài toán tổng thể không
- Bạn có nói rõ app đang chạy ở đâu không

Trả lời ngắn:

Dự án dựng hạ tầng AWS bằng Terraform, chạy minikube trên một EC2, deploy web app vào Kubernetes Pods, và expose app ra Internet qua Application Load Balancer.

### App có chạy trực tiếp trên EC2 không?

Mentor muốn kiểm tra:

- Bạn có thật sự đáp ứng yêu cầu “app chạy trong K8s” không

Trả lời ngắn:

Không. EC2 chỉ là host chạy Docker, minikube và kubectl. Ứng dụng được build thành Docker image và chạy trong Pods do Kubernetes quản lý.

### Những service chính nào đang được dùng?

Mentor muốn kiểm tra:

- Bạn có nắm được kiến trúc không

Trả lời ngắn:

Dự án dùng Terraform, VPC, Security Groups, EC2, S3 artifact bucket, IAM role, cloud-init, Docker, minikube, Kubernetes manifests và ALB.

## 2. Terraform

### Vì sao dự án này đạt yêu cầu có ít nhất 2 Terraform providers?

Mentor muốn kiểm tra:

- Bạn có hiểu yêu cầu đề bài không
- Bạn có biết provider nào đang được wire với nhau không

Trả lời ngắn:

Project dùng `hashicorp/aws` để tạo hạ tầng AWS và `hashicorp/cloudinit` để render bootstrap script cho EC2. Hai provider này được dùng trong cùng một cấu hình Terraform.

### Provider wiring nằm ở đâu?

Mentor muốn kiểm tra:

- Bạn có biết phần “nối” giữa các provider

Trả lời ngắn:

`cloudinit` render `data.cloudinit_config.minikube`, sau đó output `rendered` của nó được truyền vào `user_data` của EC2 trong provider `aws`.

### `main.tf` có vai trò gì?

Mentor muốn kiểm tra:

- Bạn có hiểu file trung tâm của dự án không

Trả lời ngắn:

`main.tf` là nơi wiring toàn bộ tài nguyên: gọi module VPC, security groups, tạo S3 bucket, IAM, render cloud-init, tạo EC2 và cấu hình ALB.

### Vì sao có resource để trong module, có resource để thẳng trong `main.tf`?

Mentor muốn kiểm tra:

- Bạn có hiểu cách tổ chức code Terraform không

Trả lời ngắn:

Những phần hạ tầng nền có ranh giới rõ như VPC, security groups, EC2 được tách module. Những phần gắn chặt với luồng deploy của project như artifact bucket, IAM đọc bucket, cloud-init và ALB wiring được để ở `main.tf` để dễ nhìn toàn bộ flow.

### Private artifact bucket được tạo ở đâu và để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu vai trò của S3 trong flow deploy không

Trả lời ngắn:

Bucket được tạo trong `main.tf` bằng `aws_s3_bucket.artifacts`. Nó dùng để stage source `web-app/` và `k8s/` để EC2 tải về trong bootstrap.

## 3. EC2 và bootstrap

### `user_data.sh.tpl` là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu bootstrap logic không

Trả lời ngắn:

Đó là bootstrap script cho EC2. Nó cài Docker, kubectl, minikube, tải source từ S3, build image, start minikube và apply Kubernetes manifests.

### Script nào chạy `user_data.sh.tpl`?

Mentor muốn kiểm tra:

- Bạn có phân biệt Terraform render và EC2 execute không

Trả lời ngắn:

Terraform chỉ render file này qua provider `cloudinit` rồi truyền vào `user_data` của EC2. Khi EC2 khởi động lần đầu, cloud-init trên máy sẽ tự chạy nội dung đó.

### “Bootstrap” nghĩa là gì trong project này?

Mentor muốn kiểm tra:

- Bạn có hiểu khái niệm cài đặt ban đầu không

Trả lời ngắn:

Bootstrap là quá trình cấu hình một EC2 mới tạo để nó trở thành máy có thể chạy minikube và tự deploy ứng dụng vào Kubernetes.

### Vì sao cần S3 thay vì nhét source vào `user_data`?

Mentor muốn kiểm tra:

- Bạn có hiểu trade-off trong thiết kế không

Trả lời ngắn:

`user_data` không phù hợp để mang toàn bộ source lớn. Dùng S3 giúp source được stage sạch hơn, dễ quản lý hơn và EC2 có thể tải lại đầy đủ trong bootstrap.

## 4. Kubernetes

### `kustomization.yaml` dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu điểm vào của manifest K8s không

Trả lời ngắn:

Đây là file tổng cho Kustomize. Nó gom namespace, deployment, service và smoke-test pod để apply một lần bằng `kubectl apply -k`.

### `deployment.yaml` dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu cách app chạy trong K8s không

Trả lời ngắn:

Nó tạo Deployment cho web app, chạy 2 replicas, khai báo image, port 80, readiness probe, liveness probe và resource limits.

### `service.yaml` dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu cách expose Pod không

Trả lời ngắn:

Nó tạo `Service` kiểu `NodePort` để làm đầu vào ổn định cho Pod và mở port `30080` trên node để ALB có thể forward vào.

### Pod là gì?

Mentor muốn kiểm tra:

- Bạn có nắm khái niệm cơ bản của Kubernetes không

Trả lời ngắn:

Pod là đơn vị chạy nhỏ nhất trong Kubernetes. Ứng dụng thực tế chạy bên trong Pod, không chạy trực tiếp trên EC2.

### Vì sao dùng `Deployment` với `replicas: 2`?

Mentor muốn kiểm tra:

- Bạn có hiểu tính sẵn sàng cơ bản không

Trả lời ngắn:

Hai replicas giúp nếu một Pod lỗi vẫn còn Pod còn lại phục vụ traffic, đồng thời Service có thể phân phối request giữa các Pod.

### `readinessProbe` và `livenessProbe` khác nhau thế nào?

Mentor muốn kiểm tra:

- Bạn có hiểu health check trong Kubernetes không

Trả lời ngắn:

`readinessProbe` quyết định Pod đã sẵn sàng nhận traffic chưa. `livenessProbe` kiểm tra container còn sống không, nếu fail liên tục thì Kubernetes sẽ restart container.

### `smoke-test-client.yaml` dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có biết cách test nội bộ trong cluster không

Trả lời ngắn:

Nó tạo một Pod `busybox` để thử gọi Service từ bên trong cluster, giúp xác nhận DNS nội bộ và đường đi Service -> Pod hoạt động.

## 5. Networking và traffic

### Traffic từ Internet đi vào app theo đường nào?

Mentor muốn kiểm tra:

- Bạn có hiểu end-to-end flow không

Trả lời ngắn:

`Browser -> ALB:80 -> EC2:30080 -> minikube NodePort 30080 -> Kubernetes Service -> Pod:80 -> app`

### ALB có đi thẳng vào Pod không?

Mentor muốn kiểm tra:

- Bạn có hiểu ranh giới giữa AWS networking và Kubernetes networking không

Trả lời ngắn:

Không. ALB target vào EC2 instance port `30080`. Kubernetes Service kiểu NodePort bên trong minikube mới route tiếp vào Pod.

### Vì sao ALB target EC2 port `30080`?

Mentor muốn kiểm tra:

- Bạn có hiểu NodePort được dùng thế nào không

Trả lời ngắn:

Vì `service.yaml` expose ứng dụng qua `NodePort 30080`, và minikube được start với mapping `30080:30080`, nên ALB có thể forward thẳng vào EC2 port đó.

### Security groups được thiết kế thế nào?

Mentor muốn kiểm tra:

- Bạn có hiểu kiểm soát network access không

Trả lời ngắn:

ALB SG cho phép HTTP 80 từ Internet. EC2 SG chỉ cho phép port `30080` từ ALB SG. SSH mặc định tắt và chỉ mở nếu cấu hình `allowed_ssh_cidrs`.

### Health check của ALB đi theo đường nào?

Mentor muốn kiểm tra:

- Bạn có hiểu target health check thực tế không

Trả lời ngắn:

ALB gọi `/healthz` vào EC2 port `30080`, rồi request đi tiếp qua NodePort, Service và Pod. Nếu app trả `200`, target mới được xem là healthy.

## 6. Quyết định thiết kế

### Vì sao chọn minikube thay vì kind?

Mentor muốn kiểm tra:

- Bạn có lý do rõ cho lựa chọn của mình không

Trả lời ngắn:

Minikube phù hợp với yêu cầu đề bài và hỗ trợ Docker driver cùng port mapping `--ports`, giúp expose NodePort ra host EC2 đơn giản hơn.

### Vì sao không dùng EKS?

Mentor muốn kiểm tra:

- Bạn có bám đúng phạm vi đề bài không

Trả lời ngắn:

Đề bài yêu cầu cụm K8s chạy bằng minikube hoặc kind trên EC2, nên EKS không nằm trong hướng triển khai này.

### Vì sao dùng `NodePort` thay vì `LoadBalancer` service?

Mentor muốn kiểm tra:

- Bạn có hiểu môi trường minikube khác EKS như thế nào không

Trả lời ngắn:

Trên minikube, `LoadBalancer` service không tự tạo AWS load balancer như trên EKS có controller. Ở đây ALB đã được Terraform tạo sẵn, nên `NodePort` là cách đơn giản để nối ALB với app.

### Vì sao app là Next.js static chạy qua Nginx?

Mentor muốn kiểm tra:

- Bạn có cân nhắc blast radius và độ phù hợp của app với đề bài không

Trả lời ngắn:

App chỉ cần làm dashboard trình bày deployment, nên static export là đủ. Chạy bằng Nginx giúp container nhẹ, đơn giản và phù hợp với health check trên port 80.

## 7. Vận hành và kiểm chứng

### Làm sao chứng minh app chạy trong Kubernetes?

Mentor muốn kiểm tra:

- Bạn có evidence kỹ thuật không

Trả lời ngắn:

Có thể kiểm tra bằng `kubectl get pods,svc -n k8s-project`. Pod phải ở trạng thái `Running` và Service phải là `NodePort`.

### Làm sao chứng minh project reproducible?

Mentor muốn kiểm tra:

- Bạn có hiểu tính tái lập của IaC không

Trả lời ngắn:

Toàn bộ hạ tầng và flow deploy được mô tả bằng Terraform và script. Chạy lại `terraform plan` sau khi apply không nên xuất hiện thay đổi ngoài ý muốn.

### Nếu `/healthz` chưa lên thì debug theo thứ tự nào?

Mentor muốn kiểm tra:

- Bạn có khả năng vận hành và xử lý lỗi không

Trả lời ngắn:

Em sẽ kiểm tra theo thứ tự: ALB target health, log cloud-init trên EC2, trạng thái minikube, `kubectl get pods,svc`, `kubectl logs`, và cuối cùng `curl http://127.0.0.1:30080/healthz` trên EC2.

### Destroy có xóa sạch không?

Mentor muốn kiểm tra:

- Bạn có quản lý vòng đời tài nguyên đầy đủ không

Trả lời ngắn:

Có. `scripts/destroy.ps1` chạy `terraform destroy -auto-approve`. Artifact bucket dùng `force_destroy = true`, nên object trong bucket cũng được xóa cùng stack.

