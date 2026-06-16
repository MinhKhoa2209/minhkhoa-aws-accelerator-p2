# Kịch bản giải thích W10 Day B

## 1. Mở đầu

Day B trả lời hai câu hỏi vận hành bảo mật:

1. Secret trong cluster đến từ đâu và rotate thế nào?
2. Image chạy trong cluster có thật sự đến từ pipeline đã scan và ký không?

Luồng tổng thể:

```text
AWS Secrets Manager
        |
        v
External Secrets Operator
        |
        v
Kubernetes Secret
        |
        v
Pod runtime

GitHub Actions -> Trivy -> GHCR -> Cosign -> Kyverno verifyImages -> Pod
```

Day A kiểm soát ai được tạo object và object có label quản trị hay không. Day B
kiểm soát dữ liệu nhạy cảm và nguồn gốc artifact.

## 2. Secrets rotation

Kubernetes Secret tự nó không phải secret manager. Secret trong etcd vẫn là dữ
liệu trong cluster, nên production cần nguồn bên ngoài như AWS Secrets Manager,
Vault hoặc cloud secret manager tương đương.

Trong lab này:

- AWS Secrets Manager giữ secret gốc.
- External Secrets Operator đọc secret theo chu kỳ.
- Kubernetes Secret `announcement-app-runtime` chỉ là bản runtime projection.
- Pod consume secret qua `envFrom`.

`ExternalSecret` dùng:

```yaml
refreshInterval: 30s
```

Điểm này đáp ứng yêu cầu rotation dưới 60 giây. Khi AWS Secret đổi từ
`ROTATION_VERSION=v1` sang `v2`, ESO sẽ reconcile và cập nhật Kubernetes Secret.

## 3. SecretStore và quyền AWS

`SecretStore` khai báo provider:

```yaml
provider:
  aws:
    service: SecretsManager
    region: us-east-1
```

Vì lab đang chạy trên minikube, `SecretStore` dùng credential secret runtime:

```yaml
auth:
  secretRef:
    accessKeyIDSecretRef:
      name: aws-credentials
      key: access-key-id
    secretAccessKeySecretRef:
      name: aws-credentials
      key: secret-access-key
```

Secret `aws-credentials` chỉ được tạo trực tiếp trong cluster, không commit vào
Git. Trên EKS thật, nên chuyển sang IRSA. IAM role chỉ nên có quyền tối thiểu:

```text
secretsmanager:GetSecretValue
secretsmanager:DescribeSecret
```

và chỉ scope vào secret ARN của lab.

## 4. Vì sao env var không đủ cho hot reload?

Khi Pod đọc Secret qua environment variable, process chỉ nhận giá trị tại thời
điểm container start. Kubernetes Secret có thể đã rotate, nhưng app không tự
nhận giá trị env mới.

Production có ba lựa chọn phổ biến:

1. Mount secret dạng volume để kubelet cập nhật nội dung file.
2. App tự reload file/config.
3. Dùng controller restart rollout có kiểm soát khi secret đổi.

Lab Day B vẫn chứng minh được phần quan trọng: cluster secret được cập nhật
không cần rebuild image.

## 5. Supply chain security

Pipeline an toàn không chỉ build image. Nó phải chứng minh:

- source được checkout từ repo đúng,
- dependency và image được scan,
- vulnerability policy có ngưỡng fail rõ ràng,
- image được push vào registry,
- image được ký bởi identity của CI,
- cluster chỉ nhận image có chữ ký hợp lệ.

Trong workflow mẫu:

```text
Trivy fs scan -> Docker build -> Trivy image scan -> GHCR push -> Cosign sign
```

Trivy fail với:

```yaml
severity: HIGH,CRITICAL
exit-code: "1"
```

Như vậy pipeline dừng trước khi image được publish nếu phát hiện lỗ hổng nặng.

## 6. Cosign keyless signing

Cosign keyless dùng GitHub OIDC thay vì giữ private key dài hạn trong repo. Khi
workflow chạy, GitHub phát token tạm thời. Cosign dùng token đó để ký image và
ghi chứng cứ vào Sigstore transparency log.

Điểm cần giải thích với mentor:

- Ký image không thay thế scan vulnerability.
- Scan trả lời "image có vấn đề đã biết không?"
- Signing trả lời "image này có đúng được tạo bởi pipeline tin cậy không?"
- Admission verify trả lời "cluster có nên cho image này chạy không?"

## 7. Kyverno verifyImages

Kyverno policy trong `signing/require-signed-images.yaml` enforce image thuộc
pattern:

```text
ghcr.io/minhkhoa2209/*
```

Policy yêu cầu chữ ký keyless có:

```text
issuer = https://token.actions.githubusercontent.com
subject = https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2/.github/workflows/trivy-cosign.yml@refs/heads/main
rekor = https://rekor.sigstore.dev
```

Nếu developer cố deploy image cùng registry nhưng không được ký bởi workflow
này, admission webhook sẽ từ chối trước khi Pod được lưu vào API server.

Policy cũng đặt webhook fail-closed:

```yaml
webhookConfiguration:
  failurePolicy: Fail
```

Điều này nghĩa là nếu Kyverno không thể kiểm tra chữ ký, request không được âm
thầm cho qua.

## 8. Exception CVE

Exception không phải "bỏ qua cho nhanh". Exception là quyết định rủi ro có thời
hạn. Template yêu cầu:

- CVE ID,
- package,
- severity,
- owner,
- hết hạn,
- mitigation,
- kế hoạch fix.

Nếu exception hết hạn mà chưa fix, pipeline phải quay lại fail.

## 9. Evidence cần trình bày

### Evidence 1 - ESO ready

```powershell
kubectl get externalsecret -n w10-secrets-lab
kubectl get secret announcement-app-runtime -n w10-secrets-lab
```

Yêu cầu: `ExternalSecret` ready và Kubernetes Secret tồn tại.

### Evidence 2 - Rotation dưới 60 giây

Sau `aws secretsmanager put-secret-value`, chụp thời điểm secret đổi:

```powershell
kubectl get secret announcement-app-runtime -n w10-secrets-lab -o yaml
```

### Evidence 3 - Trivy fail

Chụp GitHub Actions log cho thấy Trivy dừng pipeline khi có HIGH/CRITICAL.

### Evidence 4 - Cosign signature

Kiểm tra image đã ký:

```powershell
cosign verify `
  --certificate-identity "https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2/.github/workflows/trivy-cosign.yml@refs/heads/main" `
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" `
  ghcr.io/minhkhoa2209/minhkhoa-aws-accelerator-p2/w8-announcement-app:<sha>
```

### Evidence 5 - Admission reject unsigned image

```powershell
kubectl apply -f cloud/w10/day-b/signing/examples/unsigned-image.yaml
```

Yêu cầu: Kyverno từ chối request vì image không có signature hợp lệ.

## 10. Kết luận trình bày

Day B làm rõ rằng bảo mật runtime và bảo mật delivery phải đi cùng nhau. Secret
không nên nằm cố định trong manifest, mà được đồng bộ từ AWS Secrets Manager
qua ESO với chu kỳ rotation rõ ràng. Image không nên được tin chỉ vì tag trông
đúng, mà phải được scan, ký và verify ở admission. Khi kết hợp Day A và Day B,
cluster vừa kiểm soát quyền, vừa kiểm soát nội dung workload và nguồn gốc
artifact.
