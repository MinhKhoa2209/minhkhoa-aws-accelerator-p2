# W10 - Amazon Macie Sensitive Data Lab

Lab phát hiện sensitive data trong S3 và gửi cảnh báo qua email.

## ⚠️ Prerequisites

**Account cần fully activated để chạy lab này.**

Nếu gặp lỗi `SubscriptionRequiredException`, xem hướng dẫn: **[ACCOUNT_SETUP.md](./ACCOUNT_SETUP.md)**

## Kiến trúc

```text
Sample files -> S3 bucket -> Macie Job -> Findings -> EventBridge -> SNS -> Email
```

## Evidence - Yêu Cầu Bài Tập

Theo đề bài, cần chụp **2 ảnh**:

### 1. Macie Findings
![Macie Findings](./evidence/01-macie-findings.png)
*Kết quả detect sensitive data trong S3*

### 2. Email Alert
![Email Alert](./evidence/02-email-alert.png)
*Email cảnh báo nhận được từ SNS*

📸 Xem hướng dẫn chi tiết: [evidence/SCREENSHOTS_NEEDED.md](./evidence/SCREENSHOTS_NEEDED.md)

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

### 5. Take screenshots

Chụp 2 ảnh theo hướng dẫn: [evidence/SCREENSHOTS_NEEDED.md](./evidence/SCREENSHOTS_NEEDED.md)

Xem chi tiết: [terraform/README.md](./terraform/README.md)

## Nộp Bài

1. Chụp 2 ảnh và đặt vào `evidence/`:
   - `01-macie-findings.png`
   - `02-email-alert.png`

2. Push lên GitHub:
   ```bash
   git add evidence/*.png
   git commit -m "Add Macie lab evidence"
   git push
   ```

3. Nộp link GitHub vào form

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

