# Tổng quan kỹ thuật dự án

## Mục tiêu tài liệu

Tài liệu này tập trung vào 3 câu hỏi:

- Dự án đang dùng những service nào
- Mỗi service được dùng để làm gì
- Các service gọi nhau theo luồng nào

Tài liệu này không đi theo kiểu mô tả từng bước chạy script deploy, mà tập trung vào kiến trúc và vai trò của từng thành phần.

## 1. Dự án này đang làm gì

Dự án dựng một ứng dụng web chạy trong Kubernetes trên AWS.

Yêu cầu chính mà dự án giải quyết:

- Hạ tầng AWS được tạo bằng Terraform
- Kubernetes chạy trên một EC2 bằng minikube
- Ứng dụng chạy trong Pod, không chạy trực tiếp trên EC2
- Người dùng ngoài Internet truy cập ứng dụng qua ALB
- Có thể deploy và destroy bằng script

Ứng dụng hiện tại là một web app Next.js static, được build thành Docker image và chạy trong Kubernetes.

## 2. Các service và thành phần đang dùng

### Terraform

Mục đích sử dụng:

- Quản lý toàn bộ hạ tầng dưới dạng code
- Tạo và liên kết các tài nguyên AWS
- Render `user_data` cho EC2 bằng provider `cloudinit`

Trong dự án này, Terraform là lớp điều phối trung tâm.

Các file chính:

- [versions.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/versions.tf:1)
- [variables.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/variables.tf:1)
- [locals.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/locals.tf:1)
- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:1)
- [outputs.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/outputs.tf:1)

### Amazon VPC

Mục đích sử dụng:

- Tạo mạng riêng cho toàn bộ hệ thống
- Chứa ALB và EC2
- Chia subnet để đặt tài nguyên

Trong dự án này, VPC là lớp network nền.

File liên quan:

- [modules/vpc/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/vpc/main.tf:1)

Các resource chính:

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- `aws_route_table`

### Security Groups

Mục đích sử dụng:

- Kiểm soát traffic được phép vào ALB
- Kiểm soát traffic từ ALB vào EC2
- Tùy chọn mở SSH khi cần debug

Trong dự án này có 2 security group chính:

- SG của ALB: cho phép HTTP `80` từ Internet
- SG của EC2: chỉ cho phép NodePort `30080` từ ALB, và có thể mở thêm `22` nếu cấu hình SSH

File liên quan:

- [modules/security_groups/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/security_groups/main.tf:1)

### Amazon S3 Artifact Bucket

Mục đích sử dụng:

- Lưu tạm source code ứng dụng và manifest Kubernetes
- Là nơi để EC2 tải source về trong lúc bootstrap

Bucket này là private bucket, không public.

Tại sao cần bucket này:

- Không nên nhét toàn bộ source app vào `user_data`
- EC2 cần một nơi ổn định để lấy source khi vừa khởi tạo
- Terraform có thể upload source trong cùng một lần apply

File liên quan:

- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:44)

Các resource chính:

- `aws_s3_bucket.artifacts`
- `aws_s3_bucket_public_access_block.artifacts`
- `aws_s3_object.artifacts`

### IAM Role và Instance Profile

Mục đích sử dụng:

- Cấp quyền cho EC2 đọc artifact từ S3
- Tránh hard-code access key trên máy EC2

EC2 không dùng access key thủ công để tải source. Thay vào đó, EC2 dùng IAM role gắn qua instance profile.

File liên quan:

- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:71)

Các resource chính:

- `aws_iam_role.ec2`
- `aws_iam_role_policy.ec2_artifacts`
- `aws_iam_instance_profile.ec2`

### EC2

Mục đích sử dụng:

- Là máy chủ chạy Docker
- Là host chạy minikube
- Là nơi build Docker image của ứng dụng
- Là target mà ALB forward traffic vào

Điểm quan trọng:

- App không chạy trực tiếp như một web server cài thẳng trên EC2
- EC2 chỉ là host cho môi trường Kubernetes

File liên quan:

- [modules/ec2_web/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/ec2_web/main.tf:1)

Resource chính:

- `aws_instance`

### Cloud-init

Mục đích sử dụng:

- Render script bootstrap cho EC2
- Tự động cấu hình máy ngay khi EC2 vừa được tạo

Cloud-init là cầu nối giữa Terraform và phần cài đặt runtime trên EC2.

File liên quan:

- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:113)
- [user_data.sh.tpl](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/user_data.sh.tpl:1)

Vai trò cụ thể:

- Cài Docker
- Cài kubectl
- Cài minikube
- Tải source từ S3
- Build image app
- Apply manifest Kubernetes

### Docker

Mục đích sử dụng:

- Build image của web app
- Là container runtime cho minikube khi chạy với Docker driver

Trong dự án này, Docker có 2 vai trò:

- Build image từ source `web-app`
- Là nền để minikube chạy cluster single-node

File liên quan:

- [user_data.sh.tpl](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/user_data.sh.tpl:1)
- [web-app/Dockerfile](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/web-app/Dockerfile:1)

### Minikube

Mục đích sử dụng:

- Tạo cụm Kubernetes trên EC2
- Chạy Pod và Service của ứng dụng

Lý do dùng minikube:

- Đúng yêu cầu đề bài
- Phù hợp để chạy single-node Kubernetes trên EC2
- Có thể map NodePort ra host bằng Docker driver

File liên quan:

- [user_data.sh.tpl](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/user_data.sh.tpl:1)

### Kubernetes Deployment

Mục đích sử dụng:

- Chạy ứng dụng web dưới dạng Pod
- Giữ đủ số replica
- Tự phục hồi nếu Pod lỗi

Trong dự án này:

- Deployment chạy 2 replicas
- Mỗi replica chứa container web app

File liên quan:

- [k8s/deployment.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/deployment.yaml:1)

### Kubernetes Service

Mục đích sử dụng:

- Tạo đầu vào ổn định cho các Pod
- Phân phối traffic tới các Pod của Deployment
- Expose app bằng `NodePort`

Trong dự án này:

- Service dùng `type: NodePort`
- NodePort cố định là `30080`

File liên quan:

- [k8s/service.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/service.yaml:1)

### Kubernetes Namespace

Mục đích sử dụng:

- Tách resource của project khỏi namespace mặc định
- Dễ quản lý Pod, Service và các resource khác

File liên quan:

- [k8s/namespace.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/namespace.yaml:1)

### Kustomize

Mục đích sử dụng:

- Gom toàn bộ manifest Kubernetes lại để apply một lần
- Áp namespace và labels chung

File liên quan:

- [k8s/kustomization.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/kustomization.yaml:1)

### Smoke Test Client Pod

Mục đích sử dụng:

- Kiểm tra nội bộ trong cluster rằng Service có thể được gọi
- Hỗ trợ debug nếu app không lên từ bên ngoài

File liên quan:

- [k8s/smoke-test-client.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/smoke-test-client.yaml:1)

### Application Load Balancer

Mục đích sử dụng:

- Public entrypoint cho người dùng ngoài Internet
- Nhận request HTTP từ browser
- Forward request vào EC2 port `30080`

ALB không đi thẳng vào Pod. Nó đi vào EC2, sau đó NodePort của Kubernetes nhận tiếp.

File liên quan:

- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:132)

Các resource chính:

- `aws_lb.web`
- `aws_lb_target_group.web`
- `aws_lb_target_group_attachment.web`
- `aws_lb_listener.http`

## 3. Luồng các service gọi nhau

### Luồng tạo hạ tầng và runtime

Luồng nội bộ của hệ thống:

1. Terraform tạo VPC, subnet, security groups
2. Terraform tạo private S3 artifact bucket
3. Terraform upload source `web-app/` và `k8s/` lên S3
4. Terraform tạo IAM role để EC2 có quyền đọc bucket
5. Terraform render `user_data` bằng `cloudinit`
6. Terraform tạo EC2 và gắn `user_data`
7. EC2 boot lên và chạy script bootstrap
8. Script bootstrap trên EC2 gọi S3 để tải source về
9. EC2 build Docker image
10. EC2 start minikube
11. EC2 dùng `kubectl apply -k` để tạo namespace, deployment, service và smoke-test pod
12. Terraform tạo ALB và gắn EC2 vào target group

### Luồng request của người dùng

Luồng request từ browser:

1. Người dùng mở DNS của ALB
2. ALB listener `:80` nhận request
3. ALB forward request vào EC2 `:30080`
4. EC2 host chuyển request vào minikube NodePort `30080`
5. Kubernetes Service nhận request
6. Service chọn một Pod của Deployment
7. Container Nginx trong Pod trả về nội dung web app

Viết gọn:

`Browser -> ALB -> EC2:30080 -> Kubernetes Service -> Pod -> Nginx -> App`

## 4. Luồng health check

### Health check trong Kubernetes

Deployment dùng:

- `readinessProbe` vào `/healthz`
- `livenessProbe` vào `/healthz`

Mục đích:

- chỉ route traffic vào Pod đã sẵn sàng
- restart container nếu app bị treo

### Health check trên EC2

Sau khi apply manifest, bootstrap script trên EC2 gọi:

- `curl http://127.0.0.1:30080/healthz`

Mục đích:

- kiểm tra app đã truy cập được qua NodePort trên chính host chưa

### Health check của ALB

ALB target group gọi:

- path `/healthz`
- port `traffic-port`, tức là `30080`

Mục đích:

- chỉ route traffic khi target EC2 thật sự healthy

## 5. Vai trò của từng nhóm file

### Root Terraform

- [versions.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/versions.tf:1): khai báo version và provider
- [variables.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/variables.tf:1): khai báo biến đầu vào
- [locals.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/locals.tf:1): tạo tên dùng chung và giá trị nội bộ
- [main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/main.tf:1): wiring toàn bộ tài nguyên
- [outputs.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/outputs.tf:1): xuất ALB URL, EC2 IP, bucket, node port
- [user_data.sh.tpl](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/user_data.sh.tpl:1): bootstrap runtime trên EC2

### Modules

- [modules/vpc/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/vpc/main.tf:1): network nền
- [modules/security_groups/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/security_groups/main.tf:1): chính sách mạng
- [modules/ec2_web/main.tf](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/modules/ec2_web/main.tf:1): máy EC2 chạy minikube

### Kubernetes

- [k8s/kustomization.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/kustomization.yaml:1): file tổng cho manifest
- [k8s/namespace.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/namespace.yaml:1): namespace riêng
- [k8s/deployment.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/deployment.yaml:1): chạy app bằng Pod
- [k8s/service.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/service.yaml:1): expose app bằng NodePort
- [k8s/smoke-test-client.yaml](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/k8s/smoke-test-client.yaml:1): pod test nội bộ

### Scripts

- [scripts/deploy.ps1](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/scripts/deploy.ps1:1): deploy và chờ app healthy
- [scripts/destroy.ps1](d:/AWS/minhkhoa-aws-accelerator-p2/cloud/w8/k8s-project/scripts/destroy.ps1:1): destroy toàn bộ stack

## 6. Cách giải thích ngắn gọn với mentor

Có thể trình bày ngắn như sau:

"Dự án dùng Terraform để tạo VPC, security groups, EC2, IAM, S3 artifact bucket và ALB. Terraform upload source app cùng manifest Kubernetes lên S3. EC2 nhận cloud-init user data, tự tải source từ S3, build Docker image, start minikube và apply các file trong `k8s/`. Ứng dụng chạy trong Pod, được expose bằng NodePort `30080`. ALB nhận request từ Internet và forward vào EC2 port `30080`, sau đó Kubernetes Service chuyển tiếp vào Pod."

