# Project Structure

```
macie-sensitive-data-lab/
├── terraform/                      # Infrastructure as Code
│   ├── versions.tf                 # Provider versions
│   ├── variables.tf                # Input variables
│   ├── locals.tf                   # Local values
│   ├── main.tf                     # Main resources (S3, SNS, EventBridge, Macie)
│   ├── outputs.tf                  # Output values
│   ├── terraform.tfvars.example    # Example configuration
│   ├── .gitignore                  # Terraform gitignore
│   └── README.md                   # Terraform setup guide
│
├── sample-data/                    # Sample sensitive data
│   └── customer-records-fake.txt   # Fake PII/credit card data for testing
│
├── evidence/                       # Lab screenshots (2 ảnh yêu cầu)
│   ├── SCREENSHOTS_NEEDED.md       # Hướng dẫn chụp ảnh
│   ├── 01-macie-findings.png      # Macie detect sensitive data
│   └── 02-email-alert.png         # Email cảnh báo từ SNS
│
├── ACCOUNT_SETUP.md               # Account activation guide
├── README.md                      # Main lab documentation
├── .gitignore                     # Project gitignore
└── PROJECT_STRUCTURE.md           # This file

```

## Quick Start

1. Setup Terraform variables:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your email
   ```

2. Deploy infrastructure:
   ```bash
   terraform init
   terraform apply
   ```

3. Confirm SNS email subscription

4. Wait 5-10 minutes for Macie findings

5. Take 2 screenshots following `evidence/SCREENSHOTS_NEEDED.md`:
   - Macie findings
   - Email alert

6. Push to GitHub and submit link

7. Cleanup:
   ```bash
   terraform destroy
   ```

## Resources Created

- **S3 Bucket:** Sample sensitive data storage
- **Amazon Macie:** Enabled with classification job
- **SNS Topic:** Alert notifications
- **EventBridge Rule:** Macie findings → SNS
- **S3 Objects:** Fake customer records with PII

## Cost

~$0 during 30-day Macie free trial
