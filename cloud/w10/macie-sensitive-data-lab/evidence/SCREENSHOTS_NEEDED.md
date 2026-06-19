# Screenshots Cần Chụp - Yêu Cầu Bài Tập

Theo yêu cầu đề bài, chỉ cần chụp **2 ảnh**:

## 1. Macie Findings - `01-macie-findings.png`

**Cách chụp:**
1. Vào Amazon Macie Console: https://console.aws.amazon.com/macie
2. Click vào **Findings** trong menu bên trái
3. Đợi job complete (5-10 phút) để có findings
4. Chụp màn hình danh sách findings
5. **Phải hiển thị:** 
   - Sensitive data types detected (SSN, Credit Card, Email...)
   - Severity level
   - S3 bucket name
   - File name: customer-records-fake.txt

**Console URL:**
```
https://console.aws.amazon.com/macie/home?region=us-east-1#findings
```

---

## 2. Email Alert - `02-email-alert.png`

**Cách chụp:**
1. Mở email inbox: `dinhminhkhoa.dev@gmail.com`
2. Tìm email từ **AWS Notifications** với subject có "Macie Finding"
3. Mở email
4. Chụp màn hình email
5. **Phải hiển thị:**
   - From: AWS Notifications (via SNS)
   - Subject: chứa "Macie Finding" hoặc "Sensitive Data"
   - Body: thông tin về finding (bucket, object, sensitive data types)

**Lưu ý:** Nếu chưa nhận được email:
- Confirm SNS subscription trước
- Đợi Macie job complete
- Có thể cần gửi test event để trigger email

---

## Upload lên GitHub

Sau khi chụp 2 ảnh:

1. Đặt ảnh vào thư mục này:
   ```
   evidence/
   ├── 01-macie-findings.png
   └── 02-email-alert.png
   ```

2. Commit và push lên GitHub:
   ```bash
   git add evidence/*.png
   git commit -m "Add Macie lab evidence screenshots"
   git push
   ```

3. Nộp bài: Dán link GitHub vào form

**Link ví dụ:**
```
https://github.com/your-username/minhkhoa-aws-accelerator-p2/tree/main/cloud/w10/macie-sensitive-data-lab
```
