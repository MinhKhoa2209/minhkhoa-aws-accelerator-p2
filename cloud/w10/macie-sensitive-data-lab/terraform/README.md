# Terraform - Amazon Macie Sensitive Data Lab

Infrastructure as Code để deploy lab Amazon Macie.

## Kiến trúc

```text
Sample data (S3) → Macie Job → Findings → EventBridge → SNS → Email
```

## Resources được tạo

- **S3 Bucket:** Chứa sample sensitive data file
- **SNS Topic:** Nhận notifications từ EventBridge
- **SNS Subscription:** (Optional) Email subscription
- **EventBridge Rule:** Bắt Macie Finding events
- **Macie Account:** Enable Amazon Macie
- **Macie Job:** One-time classification job scan S3 bucket

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Amazon Macie đã được enable (hoặc Terraform sẽ enable tự động)
- Account đã fully activated (không còn Free Tier restrictions)

## Setup

### 1. Tạo tfvars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
region             = "us-east-1"
notification_email = "your-email@example.com"  # Hoặc để trống nếu không cần email
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan

```bash
terraform plan
```

### 4. Apply

```bash
terraform apply
```

Nhập `yes` để confirm.

### 5. Confirm Email Subscription

Nếu bạn cung cấp `notification_email`, check inbox và click link **"Confirm subscription"** trong email từ AWS SNS.

### 6. Wait for Macie Job

Macie classification job sẽ mất **5-10 phút** để scan và tạo findings.

Check status:

```bash
terraform output macie_job_id
aws macie2 describe-classification-job --job-id <JOB_ID> --region us-east-1
```

### 7. View Findings

Console:
```
https://console.aws.amazon.com/macie/home?region=us-east-1#findings
```

CLI:
```bash
aws macie2 list-findings --region us-east-1
```

## Outputs

```bash
terraform output
```

- `bucket_name` - S3 bucket name
- `sns_topic_arn` - SNS topic ARN
- `eventbridge_rule_name` - EventBridge rule name
- `macie_job_id` - Macie job ID
- `macie_status` - Macie account status (ENABLED)

## Cleanup

```bash
terraform destroy
```

**Note:** Terraform sẽ destroy tất cả resources nhưng **không disable Macie**. Macie account vẫn active và tính phí $1/month sau free trial. Để disable:

```bash
aws macie2 disable-macie --region us-east-1
```

## Cost

- **Macie:** $0 (30-day free trial) → $1/month sau đó
- **S3:** ~$0.001 (1 file nhỏ)
- **SNS:** $0 (free tier)
- **EventBridge:** $0 (free tier)

**Total:** ~$0 cho lab

## Troubleshooting

### Error: SubscriptionRequiredException

Account chưa fully activated. Xem: `../ACCOUNT_SETUP.md`

### Macie job không tạo findings

- Đợi thêm 5-10 phút
- Check sample data file có upload thành công không:
  ```bash
  aws s3 ls s3://$(terraform output -raw bucket_name)/sample-data/
  ```

### Không nhận được email

- Check spam folder
- Confirm SNS subscription (check email inbox)
- Test EventBridge rule:
  ```bash
  aws events test-event-pattern \
    --event-pattern file://test-event.json \
    --event '{"source":["aws.macie"],"detail-type":["Macie Finding"]}'
  ```

## Module Structure

```
terraform/
├── versions.tf          # Provider versions
├── variables.tf         # Input variables
├── locals.tf            # Local values
├── main.tf              # Main resources
├── outputs.tf           # Output values
├── .gitignore           # Git ignore patterns
├── terraform.tfvars.example
└── README.md
```

## Next Steps

1. ✅ Apply Terraform
2. ✅ Confirm SNS email
3. ✅ Wait for Macie findings
4. ✅ Take screenshots (xem `../evidence/SCREENSHOTS_NEEDED.md`)
5. ✅ Destroy resources khi hoàn thành
