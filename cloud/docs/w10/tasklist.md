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
- [x] Trivy CI chạy với policy fail khi có HIGH/CRITICAL.
- [x] Image publish lên GHCR có Cosign signature hợp lệ.
- [x] Kyverno reject unsigned image.
- [x] CVE exception không cần tạo vì scan không phát hiện HIGH/CRITICAL.

### Commit

- [ ] `[W10-D2] secrets supply chain security`

## D3 - Platform Integration, Runbook và Cost Guard

### Self-study

- [x] Hiểu platform integration giữa GitOps, rollout, observability và security.
- [x] Hiểu ResourceQuota dùng để giới hạn tổng tài nguyên namespace.
- [x] Hiểu LimitRange dùng để đặt default request/limit cho container.
- [x] Hiểu PodDisruptionBudget bảo vệ availability khi node drain.
- [x] Hiểu vì sao workload cần `owner`, `cost-center`, `environment`.
- [x] Hiểu vì sao Service `LoadBalancer` cần exception có owner và ngày hết hạn.
- [x] Phân biệt Argo Rollouts abort và Git revert.
- [x] Biết cấu trúc runbook xử lý incident và cost response.

### Thực hành

- [x] Tạo ResourceQuota cho namespace `w8-day-2`.
- [x] Tạo LimitRange default request/limit cho container.
- [x] Tạo PodDisruptionBudget cho `announcement-app`.
- [x] Viết ValidatingAdmissionPolicy bắt buộc label chi phí.
- [x] Viết ValidatingAdmissionPolicy chặn LoadBalancer chưa được duyệt.
- [x] Tạo Argo CD Application mẫu cho Day C guardrails.
- [x] Tạo workload hợp lệ và không hợp lệ để kiểm thử admission.
- [x] Viết runbook incident response.
- [x] Viết runbook cost response.
- [x] Viết script kiểm tra nhanh artifact Day C.

### Evidence cần hoàn thành trên cluster

- [x] `kubectl kustomize cloud/w10/day-c/guardrails` render thành công.
- [x] ResourceQuota, LimitRange và PodDisruptionBudget tồn tại trong `w8-day-2`.
- [x] Workload thiếu label chi phí bị reject.
- [x] Service `LoadBalancer` không có exception bị reject.
- [x] Argo CD Application `w10-day-c-guardrails` sync guardrails.
- [x] Runbook mô tả rõ khi nào abort rollout và khi nào Git revert.

### Commit

- [x] `[W10-D3] platform integration runbook cost guard`
