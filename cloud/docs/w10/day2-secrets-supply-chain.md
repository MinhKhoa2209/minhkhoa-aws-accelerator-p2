# W10-D2 - Secrets Rotation và Supply Chain Security

## 1. Vì sao cần Day 2?

Sau Day 1, cluster đã có RBAC và admission policy. Tuy nhiên một platform vẫn
chưa an toàn nếu:

- secret nằm trực tiếp trong Git,
- secret không rotate được,
- image chưa scan vẫn được push,
- image chưa ký vẫn được deploy,
- exception CVE không có hạn xử lý.

Day 2 bổ sung kiểm soát ở hai lớp: secret lifecycle và software supply chain.

## 2. Secrets rotation

Kubernetes Secret là object runtime, không phải secret manager hoàn chỉnh.
Trong production, secret nên được giữ ở hệ thống chuyên dụng như AWS Secrets
Manager. External Secrets Operator đồng bộ secret từ AWS về Kubernetes theo
chu kỳ.

Luồng:

```text
AWS Secrets Manager -> SecretStore -> ExternalSecret -> Kubernetes Secret -> Pod
```

Các điểm cần nhớ:

- `SecretStore` mô tả provider và cách xác thực.
- `ExternalSecret` mô tả secret nguồn, secret đích và chu kỳ refresh.
- `refreshInterval: 30s` nghĩa là ESO reconcile thường xuyên hơn yêu cầu 60s.
- Trên minikube, lab có thể dùng Kubernetes Secret runtime để giữ AWS access
  key cho ESO. Secret này không được commit vào Git.
- Trên EKS production, nên dùng IRSA thay cho static key.
- Quyền AWS nên theo least privilege, chỉ `GetSecretValue` và `DescribeSecret`
  trên secret cần thiết.

## 3. Rotation và ứng dụng

Khi AWS secret đổi, ESO cập nhật Kubernetes Secret. Nhưng ứng dụng nhận giá trị
mới hay không phụ thuộc cách consume:

| Cách consume | Nhận secret mới? | Ghi chú |
| --- | --- | --- |
| Env var | Không tự cập nhật trong process đang chạy | Cần restart Pod |
| Volume mount | File có thể được kubelet cập nhật | App cần reload file |
| Sidecar/reloader | Có thể trigger reload hoặc rollout | Dùng khi app chưa hỗ trợ reload |

Vì vậy evidence của Day 2 nên tách rõ:

1. Kubernetes Secret được rotate dưới 60 giây.
2. App có chiến lược nhận config mới an toàn.

## 4. Supply chain security

Supply chain security bảo vệ đường đi từ source code đến runtime:

```text
source -> build -> scan -> publish -> sign -> verify -> run
```

Trivy giúp phát hiện vulnerability và misconfiguration. CI nên fail với
`HIGH` và `CRITICAL`, trừ khi có exception được review.

Cosign ký image để tạo bằng chứng image đến từ pipeline tin cậy. Keyless
signing dùng GitHub OIDC, giảm rủi ro quản lý private key dài hạn.

Admission verify signature đảm bảo cluster không chỉ tin tag image. Tag có thể
bị ghi đè, nhưng signature + digest + identity giúp kiểm soát nguồn gốc
artifact.

## 5. Kyverno verifyImages

Kyverno `verifyImages` kiểm tra image trước khi Pod được chấp nhận. Policy Day
2 yêu cầu image GHCR của repo phải được ký bởi workflow:

```text
trivy-cosign.yml@refs/heads/main
```

Nếu image không ký, ký bằng identity khác, hoặc không có digest hợp lệ, request
bị từ chối.

## 6. Exception CVE

Exception phải là quyết định tạm thời có hạn, không phải ignore vĩnh viễn.
Một exception tốt phải có:

- CVE ID,
- package và image bị ảnh hưởng,
- severity,
- business reason,
- mitigation,
- owner,
- ngày hết hạn,
- kế hoạch fix.

Nếu thiếu owner hoặc expiration date, exception không đủ điều kiện.

## 7. Artifact trong repo

- `cloud/w10/day-b/eso/`: SecretStore, ExternalSecret và workload demo.
- `cloud/w10/day-b/signing/`: Kyverno verifyImages policy và workload mẫu.
- `cloud/w10/day-b/ci-trivy/`: workflow mẫu Trivy + Cosign và template CVE
  exception.
- `cloud/w10/day-b/scripts/verify-day-b.ps1`: kiểm tra nhanh artifact Day 2.

## 8. Câu hỏi mentor hay hỏi

### Vì sao không commit Kubernetes Secret trực tiếp?

Vì Secret trong YAML chỉ là base64, không phải encryption. Commit secret vào
Git làm lộ secret trong lịch sử repo và khó rotate sạch.

### IRSA khác static AWS key trong Pod như thế nào?

IRSA cấp credential tạm thời thông qua ServiceAccount và IAM role. Static key
trong Pod là credential dài hạn, khó rotate và dễ bị lộ.

### Trivy và Cosign giải quyết hai vấn đề khác nhau thế nào?

Trivy kiểm tra rủi ro trong artifact. Cosign chứng minh artifact được tạo bởi
identity tin cậy. Một image có thể sạch nhưng không đáng tin nếu không biết nó
đến từ đâu.

### Vì sao verify ở admission nếu CI đã ký?

CI là điểm tạo artifact, còn admission là điểm quyết định runtime. Verify ở
admission chặn image ngoài luồng, image bị thay tag hoặc deploy thủ công không
qua pipeline.
