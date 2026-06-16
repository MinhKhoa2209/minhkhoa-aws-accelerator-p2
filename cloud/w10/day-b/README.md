# W10-D2 - Secrets Rotation và Supply Chain Security

Day B chứng minh hai luồng chính:

```text
AWS Secrets Manager -> External Secrets Operator -> Kubernetes Secret -> Pod
GitHub Actions -> Trivy -> GHCR -> Cosign -> Kyverno verifyImages -> Pod
```

## Nội dung

- `eso/`: namespace, SecretStore, ExternalSecret và workload đọc secret.
- `signing/`: Kyverno policy bắt buộc image GHCR phải có chữ ký hợp lệ.
- `ci-trivy/`: workflow mẫu Trivy + Cosign và template CVE exception.
- `scripts/verify-day-b.ps1`: kiểm tra nhanh artifact Day B.

## Chạy lab

Tạo hoặc cập nhật secret trong AWS Secrets Manager:

```powershell
aws secretsmanager create-secret `
  --region us-east-1 `
  --name w10/announcement-app `
  --secret-string '{\"API_TOKEN\":\"initial-token\",\"ROTATION_VERSION\":\"v1\"}'

aws secretsmanager put-secret-value `
  --region us-east-1 `
  --secret-id w10/announcement-app `
  --secret-string '{\"API_TOKEN\":\"rotated-token\",\"ROTATION_VERSION\":\"v2\"}'
```

Cài External Secrets Operator:

```powershell
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets `
  --namespace external-secrets `
  --create-namespace `
  --set installCRDs=true
```

Với minikube, tạo secret runtime cho AWS credentials. Secret này không commit
vào Git:

```powershell
kubectl create secret generic aws-credentials `
  -n w10-secrets-lab `
  --from-literal=access-key-id=<AWS_ACCESS_KEY_ID> `
  --from-literal=secret-access-key=<AWS_SECRET_ACCESS_KEY>
```

Apply ESO manifests:

```powershell
kubectl apply -k cloud/w10/day-b/eso
kubectl get externalsecret,secretstore,pod -n w10-secrets-lab
```

Cài Kyverno và apply policy ký image:

```powershell
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm upgrade --install kyverno kyverno/kyverno `
  --namespace kyverno `
  --create-namespace

kubectl apply -k cloud/w10/day-b/signing
```

Test admission:

```powershell
kubectl apply -f cloud/w10/day-b/signing/examples/unsigned-image.yaml
kubectl apply -f cloud/w10/day-b/signing/examples/signed-image-template.yaml
kubectl get deploy,pod -n w10-supply-chain-lab
```

Image chưa ký phải bị từ chối. Image đã ký từ workflow
`.github/workflows/trivy-cosign.yml` phải được Kyverno cho chạy.

## CI và signing

Workflow thật nằm ở `.github/workflows/trivy-cosign.yml`; bản tham khảo nằm ở
`ci-trivy/trivy-cosign.yml`. Workflow scan source và image bằng Trivy, fail với
`HIGH,CRITICAL`, push image lên GHCR, rồi ký bằng Cosign keyless qua GitHub OIDC.

Verify chữ ký local:

```powershell
$env:Path = "C:\Tools\Cosign;$env:Path"
cosign verify `
  --certificate-identity "https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2/.github/workflows/trivy-cosign.yml@refs/heads/main" `
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" `
  ghcr.io/minhkhoa2209/minhkhoa-aws-accelerator-p2/w8-announcement-app:<sha>
```

## Kiểm tra

```powershell
.\cloud\w10\day-b\scripts\verify-day-b.ps1
```

Script kiểm tra file chính, `refreshInterval <= 60s`, Kyverno enforce
fail-closed, Rekor verification, Trivy fail policy, và Cosign signing.

## Ghi chú

- `ExternalSecret` đang dùng `refreshInterval: 30s`.
- Với EKS production, nên dùng IRSA thay vì static AWS key trong cluster.
- Nếu cần bỏ qua CVE tạm thời, dùng `ci-trivy/cve-exception-template.md`.
- Tài liệu giải thích chi tiết nằm ở [DAY_B_SCRIPT.md](../../docs/w10/DAY_B_SCRIPT.md).
