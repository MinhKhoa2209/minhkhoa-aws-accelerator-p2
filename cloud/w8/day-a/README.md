# W8-D1 — Terraform Foundations

## Scope hôm nay

- hiểu Infrastructure as Code là gì và vì sao team platform dùng IaC
- nắm cấu trúc cơ bản của Terraform project
- đọc và viết được HCL syntax ở mức block, argument, expression, variable, local, output

## IaC overview

Infrastructure as Code là cách mô tả hạ tầng bằng code thay vì click tay trên console. Với Terraform, mình viết desired state vào file `.tf`, sau đó dùng workflow `init -> fmt -> validate -> plan -> apply` để tạo hoặc cập nhật hạ tầng một cách có thể review và lặp lại.

Lý do IaC quan trọng:
- giảm config drift giữa các môi trường
- review được thay đổi qua Git thay vì thao tác thủ công
- tái sử dụng cấu hình qua module và variable
- dễ audit, rollback và tự động hóa qua CI/CD

## Các khái niệm Terraform cần nhớ

- `terraform`: khai báo version constraint và backend/provider requirements
- `variable`: đầu vào cho module hoặc root configuration
- `locals`: gom expression để tái sử dụng, tránh hard-code lặp lại
- `output`: giá trị đầu ra sau khi apply hoặc để module cha dùng
- `resource`: mô tả object hạ tầng cần Terraform quản lý
- `data`: đọc thông tin đã tồn tại thay vì tạo mới
- `state`: file ghi Terraform đang quản lý gì; không được sửa tay trừ khi biết chính xác hệ quả

## HCL syntax cần nắm

- Block: `resource "aws_s3_bucket" "logs" { ... }`
- Argument: `bucket = "my-bucket"`
- Expression: `var.environment == "prod" ? 3 : 1`
- Collection types: `list`, `map`, `set`, `object`
- Interpolation và template string: `"cloud/w8/${var.environment}"`
- Validation: dùng `validation` trong `variable` để chặn input sai sớm
- `for` expression: tạo list/map mới từ collection hiện có

## Evidence trong repo

- Mẫu Terraform cơ bản: `terraform-basics/`
- Reflection cuối ngày: `../reflection.md`

## Cách tự verify

Nếu máy đã cài Terraform:

```powershell
cd cloud/w8/day-a/terraform-basics
terraform fmt -recursive
terraform validate
terraform console
```

`terraform console` hữu ích để thử expression như:

```hcl
> local.w8_paths
> local.learning_summary
> var.environment == "learning" ? "self-study" : "delivery"
```
