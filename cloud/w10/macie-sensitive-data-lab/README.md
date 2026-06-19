# W10 - Amazon Macie Sensitive Data Lab

Lab phát hiện sensitive data trong S3 và gửi cảnh báo qua email.

## Kiến trúc

```text
Sample files -> S3 bucket -> Macie Job -> Findings -> EventBridge -> SNS -> Email
```

Luồng lab bắt đầu bằng file mẫu `customer-records-fake.txt` chứa dữ liệu nhạy cảm giả lập. File này được upload vào S3 bucket, sau đó Amazon Macie chạy classification job để quét object và tạo finding khi phát hiện dữ liệu như số thẻ tín dụng hoặc SSN. Finding từ Macie được EventBridge bắt lại bằng rule `xbrain-macie-sensitive-data-findings`, chuyển tới SNS topic `xbrain-macie-sensitive-data-alerts`, rồi SNS gửi email cảnh báo tới người nhận đã subscribe.

## Mô tả ảnh

### 1. Macie Findings

![Macie Findings](./01-macie-findings.png)

Ảnh này thể hiện Macie job đã phát hiện finding loại `SensitiveData:S3Object/Multiple` trong bucket `xbrain-macie-sensitive-data-058114477594`. Finding có mức độ `High` và thuộc job `xbrain-macie-sensitive-data-job-20260619110910`.

### 2. Email Alert

![Email Alert](./02-email-alert.png)

Ảnh này thể hiện email cảnh báo từ AWS Notifications qua SNS với subject `Macie Finding - Sensitive Data Alert`, gửi tới `minhkhoaoik2209@gmail.com` và tham chiếu object `sample-data/customer-records-fake.txt` trong S3.
