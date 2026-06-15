# D1 Self-study - RBAC và Admission Policy

## Luồng xử lý request

Kubernetes xử lý một API request theo thứ tự:

```text
authentication -> authorization -> admission -> persistence
```

- Authentication xác định **ai** gửi request.
- RBAC authorization xác định danh tính đó **được làm gì**.
- Admission policy kiểm tra object sắp được tạo **có đạt yêu cầu hay không**.

RBAC không thể bắt workload phải có label hoặc security context. Admission
policy cũng không thể cấp quyền gọi API. Hai lớp giải quyết hai bài toán khác
nhau và cần được dùng cùng nhau.

## Các object RBAC

| Object | Phạm vi | Mục đích |
| --- | --- | --- |
| `Role` | Namespace | Khai báo quyền trong một namespace |
| `RoleBinding` | Namespace | Gán Role hoặc ClusterRole trong một namespace |
| `ClusterRole` | Cluster | Khai báo quyền dùng lại hoặc quyền với resource cấp cluster |
| `ClusterRoleBinding` | Cluster | Gán ClusterRole trên toàn cluster |
| `ServiceAccount` | Namespace | Danh tính Kubernetes cho Pod và automation |

Điểm cần nhớ:

- Quyền RBAC được cộng dồn; Kubernetes RBAC không có deny rule.
- Nên bind role cho group hoặc service account thay vì từng user.
- Tránh wildcard ở `verbs` và `resources`.
- RoleBinding có thể tham chiếu ClusterRole nhưng chỉ cấp quyền namespaced
  trong namespace của RoleBinding.
- ClusterRoleBinding cấp quyền trên toàn cluster.
- Username của service account có dạng
  `system:serviceaccount:<namespace>:<name>`.

## Kiểm tra quyền

Kiểm tra danh tính hiện tại:

```powershell
kubectl auth can-i get pods -n w10-rbac-lab
```

Giả lập request của service account:

```powershell
kubectl auth can-i create deployments `
  -n w10-rbac-lab `
  --as system:serviceaccount:w10-rbac-lab:developer
```

Liệt kê toàn bộ quyền hiệu lực trong namespace:

```powershell
kubectl auth can-i --list `
  -n w10-rbac-lab `
  --as system:serviceaccount:w10-rbac-lab:viewer
```

## OPA, Rego và Gatekeeper

OPA đánh giá policy viết bằng Rego. Gatekeeper tích hợp OPA vào admission và
quá trình audit của Kubernetes.

Policy Day 1 yêu cầu workload có label `owner`:

```rego
violation[{"msg": msg}] {
  required := input.parameters.labels[_]
  labels := object.get(input.review.object.metadata, "labels", {})
  not labels[required]
  msg := sprintf("missing required label: %s", [required])
}
```

Gatekeeper tách code policy và cấu hình áp dụng:

| Object | Chứa nội dung |
| --- | --- |
| `ConstraintTemplate` | CRD schema, tham số, target và code Rego |
| `Constraint` | Resource cần match, giá trị tham số và enforcement action |

Một ConstraintTemplate có thể được dùng cho nhiều Constraint với namespace,
tham số hoặc chế độ rollout khác nhau.

## ValidatingAdmissionPolicy native

Kubernetes hỗ trợ admission validation native bằng CEL:

- `ValidatingAdmissionPolicy` định nghĩa resource cần match và biểu thức kiểm
  tra.
- `ValidatingAdmissionPolicyBinding` xác định phạm vi áp dụng và action.
- Không cần cài admission webhook bên ngoài.

Biểu thức CEL tương đương:

```text
has(object.metadata.labels) &&
'owner' in object.metadata.labels &&
object.metadata.labels['owner'] != ''
```

Native policy phù hợp với validation CEL đơn giản. Gatekeeper phù hợp khi nền
tảng đã chuẩn hóa Rego, dùng policy library hoặc cần audit/inventory của
Gatekeeper.

## Audit trước, enforce sau

| Engine | Audit mode | Enforce mode |
| --- | --- | --- |
| Gatekeeper | `enforcementAction: dryrun` | `enforcementAction: deny` |
| Native | `validationActions: [Warn, Audit]` | `validationActions: [Deny, Audit]` |

`Warn` trả cảnh báo cho API client. `Audit` của native policy ghi annotation
vào Kubernetes audit event, vì vậy cluster phải bật API audit logging mới xem
được dữ liệu này.

Quy trình rollout:

1. Áp dụng policy ở audit mode.
2. Thống kê các object đang vi phạm.
3. Sửa workload và ghi nhận exception tạm thời.
4. Test object hợp lệ và không hợp lệ.
5. Chuyển sang enforce.
6. Theo dõi request bị reject và chuẩn bị cách rollback.

## So sánh nhanh

| Nội dung | RBAC | Admission policy |
| --- | --- | --- |
| Câu hỏi chính | Danh tính này có được thực hiện action không? | Object này có được chấp nhận không? |
| Input | User, group, service account, verb, resource | Nội dung object và request context |
| Ví dụ | Developer được tạo Deployment | Deployment phải có label `owner` |
| Kết quả | Cho phép hoặc từ chối request | Validate, cảnh báo, audit hoặc từ chối object |

## Tài liệu chính thức

- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/)
- [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/howto/)
- [OPA Rego](https://www.openpolicyagent.org/docs/policy-language)
