# W10 - Amazon Macie Sensitive Data Lab

Lab phát hiện sensitive data trong S3 và gửi cảnh báo qua email.

## ⚠️ Prerequisites

**Account cần fully activated để chạy lab này.**

Nếu gặp lỗi `SubscriptionRequiredException`, xem hướng dẫn: **[ACCOUNT_SETUP.md](./ACCOUNT_SETUP.md)**

## Kiến trúc

```text
Sample files -> S3 bucket -> Macie Job -> Findings -> EventBridge -> SNS -> Email
```

## Evidence

Kết quả kiểm tra lab được ghi tại [evidence/evidence-pack.md](./evidence/evidence-pack.md).

## Setup với Terraform

### 1. Tạo tfvars file

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` với email của bạn.

### 2. Deploy

```bash
terraform init
terraform apply
```

### 3. Confirm email subscription

Check inbox và click link "Confirm subscription".

### 4. Wait for findings

Macie job mất 5-10 phút. Check findings tại:
```
https://console.aws.amazon.com/macie/home?region=us-east-1#findings
```

### 5. Verify evidence

Kiểm tra kết quả Macie finding và SNS/EventBridge trong [evidence/evidence-pack.md](./evidence/evidence-pack.md).

Xem chi tiết: [terraform/README.md](./terraform/README.md)

## Cleanup

```bash
cd terraform
terraform destroy
```

**Note về Macie Job:**
- Macie classification jobs không thể xóa sau khi complete
- Job sẽ tự động expire sau 90 ngày
- Terraform sẽ bỏ qua job khi destroy (không ảnh hưởng chi phí)
- Để disable Macie hoàn toàn:
  ```bash
  aws macie2 disable-macie --region us-east-1
  ```
