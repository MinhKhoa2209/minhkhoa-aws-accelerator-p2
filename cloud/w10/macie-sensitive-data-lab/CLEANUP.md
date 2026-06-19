# Cleanup Guide

## Automatic Cleanup (Recommended)

```bash
cd terraform
terraform destroy
```

Terraform sẽ tự động xóa:
- ✅ S3 bucket
- ✅ S3 objects
- ✅ SNS topic và subscriptions
- ✅ EventBridge rule và targets
- ⚠️ Macie account (ENABLED nhưng không tạo job mới)

## Macie Classification Jobs

**Lưu ý quan trọng:**

- ❌ Macie jobs **không thể xóa** sau khi COMPLETE (AWS limitation)
- ✅ Jobs sẽ tự động expire sau **90 ngày**
- 💰 Completed jobs **không tính phí**
- 📊 Findings vẫn có thể xem trong Console

Terraform sẽ tự động bỏ qua job khi destroy (không có lỗi).

## Manual Cleanup (Nếu cần)

### 1. Xóa SNS Topic

```bash
aws sns delete-topic \
  --topic-arn arn:aws:sns:us-east-1:058114477594:xbrain-macie-sensitive-data-alerts \
  --region us-east-1
```

### 2. Xóa EventBridge Rule

```bash
# Remove targets first
aws events remove-targets \
  --rule xbrain-macie-sensitive-data-findings \
  --ids sns-macie-sensitive-data-alerts \
  --region us-east-1

# Delete rule
aws events delete-rule \
  --name xbrain-macie-sensitive-data-findings \
  --region us-east-1
```

### 3. Xóa S3 Bucket

```bash
aws s3 rb s3://xbrain-macie-sensitive-data-058114477594 --force --region us-east-1
```

### 4. Disable Macie (Optional)

⚠️ **Chỉ disable nếu không dùng Macie cho mục đích khác!**

```bash
aws macie2 disable-macie --region us-east-1
```

Sau khi disable:
- Tất cả findings sẽ bị xóa
- Macie configuration sẽ bị reset
- Tính phí $1/month sẽ dừng (sau free trial)

## Verify Cleanup

```bash
# Check S3 buckets
aws s3 ls | grep xbrain-macie

# Check SNS topics
aws sns list-topics --region us-east-1 | grep xbrain-macie

# Check EventBridge rules
aws events list-rules --region us-east-1 --name-prefix xbrain-macie

# Check Macie status
aws macie2 get-macie-session --region us-east-1
```

## Cost After Cleanup

- **S3:** $0 (deleted)
- **SNS:** $0 (deleted)
- **EventBridge:** $0 (deleted)
- **Macie:** $0 (30-day free trial) → $1/month nếu vẫn ENABLED sau trial
- **Macie Jobs:** $0 (completed jobs không tính phí)

**Total:** ~$0 nếu cleanup trong 30 ngày free trial

## Troubleshooting

### Error: Cannot delete completed Macie job

```
ValidationException: cannot update completed job
```

**Giải pháp:** Bỏ qua lỗi này, job sẽ tự expire sau 90 ngày.

```bash
# Remove from Terraform state
terraform state rm aws_macie2_classification_job.sample_data

# Continue destroy
terraform destroy
```

### S3 bucket not empty

```
BucketNotEmpty: The bucket you tried to delete is not empty
```

**Giải pháp:** Force delete với `--force` flag:

```bash
aws s3 rb s3://bucket-name --force --region us-east-1
```
