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
