# Final Project: Deploy a Web App on AWS

This lab deploys the assignment architecture with Terraform:

- VPC with public and private subnets across two Availability Zones
- EC2 web server in a public subnet
- RDS MySQL database in private subnets
- S3 bucket for static assets
- Security groups with only required inbound traffic
- S3 remote state backend with DynamoDB locking

## Folder Layout

```text
lab-terraform/
  backend.tf.example          S3 backend configuration to copy after backend bootstrap
  bootstrap-backend/          One-time S3 state bucket and DynamoDB lock table
  main.tf                     Root module wiring
  modules/
    ec2_web/                  Public web server
    rds_mysql/                Private MySQL database
    s3_assets/                Static asset bucket
    security_groups/          EC2 and RDS security groups
    vpc/                      VPC, subnets, route tables, internet gateway
  web-app/                    Static HTML/CSS/JS app deployed to EC2 Nginx
  terraform.tfvars.example    Example variable values
```

## GitHub Safety

Do not commit generated Terraform runtime files or personal configuration:

- `terraform.tfvars`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `.terraform/`
- `backend.tf`

The repo `.gitignore` excludes these files. Commit `terraform.tfvars.example`, `backend.tf.example`, and `.terraform.lock.hcl`.

## Prerequisites

- AWS CLI credentials configured
- Terraform installed
- An AWS account with permission to create VPC, EC2, RDS, S3, and DynamoDB resources

## Step 1: Create the Remote Backend

Terraform cannot use an S3 backend until the backend bucket and lock table already exist. Create them once:

```powershell
cd cloud\w8\lab-terraform\bootstrap-backend
terraform init
terraform apply
```

Record these outputs:

```powershell
terraform output -raw state_bucket_name
terraform output -raw lock_table_name
```

## Step 2: Enable S3 Backend

From `cloud\w8\lab-terraform`, copy the backend example:

```powershell
Copy-Item backend.tf.example backend.tf
```

Edit `backend.tf` so the `bucket`, `region`, and `dynamodb_table` values match the bootstrap outputs.

If you already ran `terraform apply` before enabling the backend, migrate the existing local state into S3:

```powershell
terraform init -migrate-state
```

If this is your first deploy, a normal init is enough:

```powershell
terraform init
```

## Step 3: Configure Variables

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars`:

- Set `allowed_http_cidrs` to your IP CIDR for a stricter submission, or leave `0.0.0.0/0` for a public demo web server.
- Set `db_username` and `db_password`. The RDS password must be at least 8 characters and cannot include `/`, `@`, double quotes, or spaces.
- Optionally set `key_name` if you want SSH access.

## Step 4: Deploy

```powershell
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

After apply:

```powershell
terraform output -raw web_url
```

Open the URL in a browser. The page is served from the EC2 instance and includes the private RDS endpoint plus S3 bucket name as deployment evidence.

The web app source is in `web-app/`. Terraform reads those files and the EC2 `user_data` script writes them into `/usr/share/nginx/html` when the instance boots.

## Step 5: Destroy

```powershell
terraform destroy
```

Destroy the backend only after the main lab stack is destroyed:

```powershell
cd bootstrap-backend
terraform destroy
```

## Assignment Mapping

- Step 1 VPC module: `modules/vpc`
- Step 2 EC2 in public subnet: `modules/ec2_web`
- Step 3 RDS MySQL in private subnet: `modules/rds_mysql`
- Step 4 S3 static assets bucket: `modules/s3_assets`
- Step 5 Security groups: `modules/security_groups`
- Remote state: `backend.tf.example` plus `bootstrap-backend`

## Suggested Evidence

- `terraform apply` success with outputs
- Browser opened to `terraform output -raw web_url`
- EC2 instance running in the public subnet
- RDS MySQL status `Available` and `Publicly accessible: No`
- Public/private subnets in two Availability Zones
- Security group rules for HTTP and MySQL
- S3 assets bucket with `static/index.html`
- S3 backend bucket and DynamoDB lock table
- `terraform plan` showing no changes after apply
