# W10 Tasklist

## D1 - RBAC và Admission Policy

### Self-study

- [x] Phân biệt authentication, authorization và admission.
- [x] Hiểu Role, RoleBinding, ClusterRole và ClusterRoleBinding.
- [x] Hiểu ServiceAccount là danh tính trong Kubernetes.
- [x] Dùng `kubectl auth can-i` và impersonation để kiểm tra quyền.
- [x] Hiểu cấu trúc Rego và cách Gatekeeper dùng OPA.
- [x] Phân biệt ConstraintTemplate và Constraint.
- [x] Hiểu ValidatingAdmissionPolicy native và CEL.
- [x] Phân biệt audit mode và enforce mode.

### Thực hành

- [x] Tạo ServiceAccount `developer`, `viewer`, `sre`.
- [x] Tạo quyền developer trong một namespace.
- [x] Bind ClusterRole viewer vào một namespace.
- [x] Bind ClusterRole SRE trên toàn cluster.
- [x] Viết script kiểm tra quyền RBAC.
- [x] Viết Gatekeeper policy bắt buộc label `owner`.
- [x] Viết ValidatingAdmissionPolicy tương đương.
- [x] Tạo cấu hình audit và enforce.
- [x] Tạo workload hợp lệ và không hợp lệ để kiểm thử.

### Evidence cần hoàn thành trên cluster

- [x] Kết quả `kubectl auth can-i` của ba role.
- [x] Gatekeeper phát hiện vi phạm trong audit mode.
- [x] Workload thiếu label bị từ chối trong enforce mode.
- [x] Workload có label `owner` được chấp nhận.
- [x] Cảnh báo của ValidatingAdmissionPolicy native.

### Commit

- [ ] `[W10-D1] rbac admission policy`

## D2 - Secrets Rotation và Supply Chain Security

### Self-study

- [x] Hiểu Kubernetes Secret không thay thế secret manager.
- [x] Hiểu AWS Secrets Manager và External Secrets Operator.
- [x] Hiểu `SecretStore`, `ExternalSecret` và `refreshInterval`.
- [x] Phân biệt secret consume qua env var và volume mount.
- [x] Hiểu Trivy filesystem scan và image scan.
- [x] Hiểu Cosign keyless signing bằng GitHub OIDC.
- [x] Hiểu admission verify signature bằng Kyverno `verifyImages`.
- [x] Hiểu exception CVE có hạn và có owner.

### Thực hành

- [x] Tạo manifest namespace và ServiceAccount cho ESO.
- [x] Tạo `SecretStore` trỏ tới AWS Secrets Manager ở `us-east-1`.
- [x] Tạo `ExternalSecret` với `refreshInterval: 30s`.
- [x] Tạo workload demo đọc secret runtime.
- [x] Tạo workflow mẫu Trivy scan filesystem và image.
- [x] Tạo workflow mẫu Cosign keyless signing.
- [x] Tạo Kyverno policy enforce signed image.
- [x] Tạo workload mẫu để chứng minh unsigned image bị reject.
- [x] Tạo template CVE exception.
- [x] Viết script kiểm tra nhanh artifact Day B.

### Evidence cần hoàn thành trên cluster và CI

- [x] `ExternalSecret` ready và tạo Secret `announcement-app-runtime`.
- [x] Secret rotate sang version mới trong vòng dưới 60 giây.
- [ ] Trivy CI fail khi có HIGH/CRITICAL.
- [ ] Image publish lên GHCR có Cosign signature hợp lệ.
- [x] Kyverno reject unsigned image.
- [ ] CVE exception, nếu có, ghi rõ owner và ngày hết hạn.

### Commit

- [ ] `[W10-D2] secrets supply chain security`
