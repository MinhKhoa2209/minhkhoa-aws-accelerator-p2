# W10-D2 - Secrets Rotation và Supply Chain Security

## Mục tiêu

Day B thêm hai lớp bảo vệ sau RBAC và admission policy:

```text
AWS Secrets Manager -> External Secrets Operator -> Kubernetes Secret -> Pod
CI Trivy scan -> Cosign sign -> Admission verify signature -> Pod
```

Kết quả cần đạt:

- Secret lấy từ AWS Secrets Manager và đồng bộ vào Kubernetes bằng External
  Secrets Operator.
- `refreshInterval` nhỏ hơn 60 giây để rotation được phản ánh nhanh mà không
  cần rebuild image.
- Image được scan bằng Trivy trong CI trước khi publish.
- Image được ký bằng Cosign.
- Admission policy từ chối image chưa ký hoặc không khớp identity CI.
- Exception CVE có lý do, chủ sở hữu và ngày hết hạn.

## Cấu trúc

```text
day-b/
  eso/          External Secrets manifests
  signing/      Kyverno verifyImages policy và workload mẫu
  ci-trivy/     GitHub Actions workflow mẫu cho Trivy + Cosign
  scripts/      Kiểm tra nhanh artifact Day B
```

## 1. Chuẩn bị secret trong AWS

Tạo secret dạng JSON trong AWS Secrets Manager:

```powershell
aws secretsmanager create-secret `
  --region us-east-1 `
  --name w10/announcement-app `
  --description "W10 Day B demo secret for ESO rotation" `
  --secret-string '{\"API_TOKEN\":\"initial-token\",\"ROTATION_VERSION\":\"v1\"}'
```

Khi rotation, cập nhật cùng secret:

```powershell
aws secretsmanager put-secret-value `
  --region us-east-1 `
  --secret-id w10/announcement-app `
  --secret-string '{\"API_TOKEN\":\"rotated-token\",\"ROTATION_VERSION\":\"v2\"}'
```

## 2. Cài External Secrets Operator

Trên cluster thật, cài ESO trước khi apply manifests:

```powershell
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets `
  --namespace external-secrets `
  --create-namespace `
  --set installCRDs=true
```

Lab hiện chạy trên minikube, nên `SecretStore` đọc AWS credentials từ
Kubernetes Secret runtime tên `aws-credentials`. Secret này không nằm trong Git.

```powershell
aws configure export-credentials --format process

# tạo secret trong cluster từ access key hiện tại, không ghi vào repo
kubectl create secret generic aws-credentials `
  -n w10-secrets-lab `
  --from-literal=access-key-id=<AWS_ACCESS_KEY_ID> `
  --from-literal=secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

Nếu dùng EKS production, nên đổi `SecretStore` sang IRSA thay vì static key và
gắn IAM role tối thiểu cho ServiceAccount.

Apply cấu hình Day B:

```powershell
kubectl apply -k cloud/w10/day-b/eso
kubectl get externalsecret -n w10-secrets-lab
kubectl get secret announcement-app-runtime -n w10-secrets-lab
```

## 3. Kiểm tra rotation < 60 giây

Sau khi `put-secret-value`, theo dõi Kubernetes Secret:

```powershell
kubectl get secret announcement-app-runtime `
  -n w10-secrets-lab `
  -o jsonpath="{.data.ROTATION_VERSION}" `
  | %{ [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

`ExternalSecret` đang đặt `refreshInterval: 30s`, nên bản mới phải xuất hiện
trong vòng dưới 60 giây nếu ESO có quyền đọc AWS Secrets Manager.

Workload đọc secret qua environment variables. Secret env var không tự reload
trong process đang chạy, nên pattern production nên dùng volume-mounted secret,
app-level config reload, hoặc controller rollout restart có kiểm soát nếu app
chỉ đọc env lúc khởi động. Mục tiêu của lab là chứng minh Kubernetes Secret
được rotate mà không rebuild image.

## 4. Trivy scan trong CI

Workflow mẫu nằm ở:

```text
cloud/w10/day-b/ci-trivy/trivy-cosign.yml
```

Để bật thật trên GitHub, copy nội dung này vào `.github/workflows/trivy-cosign.yml`.
Workflow:

- build image W8 Day 2,
- scan filesystem và image bằng Trivy,
- fail khi có vulnerability mức `HIGH` hoặc `CRITICAL`,
- đăng nhập GHCR,
- push image,
- ký image bằng Cosign keyless OIDC.

## 5. Cosign signing

Workflow dùng keyless signing:

```text
cosign sign --yes ghcr.io/<owner>/<repo>/w8-announcement-app:<sha>
```

Identity hợp lệ được ràng buộc bởi GitHub OIDC:

```text
issuer: https://token.actions.githubusercontent.com
subject: https://github.com/<owner>/<repo>/.github/workflows/trivy-cosign.yml@refs/heads/main
```

Không nên ký thủ công bằng máy cá nhân cho release chính vì admission policy
sẽ không chứng minh được image đến từ pipeline đã scan.

## 6. Admission reject unsigned image

Day B dùng Kyverno `verifyImages` để kiểm tra chữ ký image:

```powershell
kubectl create namespace kyverno
kubectl apply -f https://github.com/kyverno/kyverno/releases/download/v1.13.4/install.yaml
kubectl wait --for=condition=Available deployment/kyverno-admission-controller `
  -n kyverno `
  --timeout=180s

kubectl apply -k cloud/w10/day-b/signing
```

Test workload chưa ký:

```powershell
kubectl apply -f cloud/w10/day-b/signing/examples/unsigned-image.yaml
```

Lệnh trên phải bị từ chối vì image thuộc pattern `ghcr.io/minhkhoa2209/*` nhưng
không có chữ ký hợp lệ từ workflow được cho phép.

## 7. Exception CVE

Nếu CI fail vì CVE nhưng chưa thể sửa ngay, ghi exception theo template:

```text
cloud/w10/day-b/ci-trivy/cve-exception-template.md
```

Exception phải có:

- CVE ID và package bị ảnh hưởng.
- Lý do chấp nhận tạm thời.
- Owner chịu trách nhiệm.
- Ngày hết hạn.
- Mitigation trong thời gian chờ fix.

Không thêm CVE vào ignore list nếu chưa có exception được review.

## 8. Kiểm tra nhanh artifact

Chạy script local:

```powershell
.\cloud\w10\day-b\scripts\verify-day-b.ps1
```

Script kiểm tra:

- các file chính tồn tại,
- `refreshInterval` không vượt quá 60 giây,
- Kyverno đang ở `validationFailureAction: Enforce`,
- policy có `verifyImages`, `failureAction: Enforce` và webhook fail-closed,
- policy có Rekor transparency log cho keyless signature verification,
- workflow Trivy fail trên `HIGH,CRITICAL`,
- workflow có bước Cosign signing.

## Evidence

1. `ExternalSecret` ở trạng thái ready và tạo được Secret
   `announcement-app-runtime`.
2. Secret trong Kubernetes đổi sang `ROTATION_VERSION=v2` trong vòng dưới 60
   giây sau khi cập nhật AWS Secrets Manager.
3. GitHub Actions fail nếu Trivy phát hiện HIGH/CRITICAL.
4. Image sau khi publish có chữ ký Cosign.
5. Kyverno từ chối workload dùng image chưa ký.
6. CVE exception có owner và ngày hết hạn nếu cần tạm thời bỏ qua.

Evidence đã chạy trên minikube nằm ở [`EVIDENCE.md`](EVIDENCE.md).

## Tài liệu

- [Kịch bản giải thích chi tiết Day B](DAY_B_SCRIPT.md)
- [Tài liệu self-study](../../docs/w10/day2-secrets-supply-chain.md)
