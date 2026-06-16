# Kịch bản giải thích W10 Day A

## 1. Mở đầu

### Nội dung trình bày

Day A giải quyết hai câu hỏi bảo mật khác nhau trong Kubernetes:

1. **RBAC:** danh tính này có được thực hiện hành động hay không?
2. **Admission Policy:** object mà danh tính gửi lên có đáp ứng tiêu chuẩn của
   cluster hay không?

Luồng xử lý:

```text
User hoặc ServiceAccount
        |
        v
Authentication: Bạn là ai?
        |
        v
RBAC Authorization: Bạn có quyền làm việc này không?
        |
        v
Admission Policy: Object có hợp lệ không?
        |
        v
Lưu vào Kubernetes API
```

Ví dụ: developer có quyền tạo Deployment theo RBAC, nhưng Deployment vẫn bị
Admission Policy từ chối nếu thiếu label `owner`.

## 2. Cấu trúc lab

```text
cloud/w10/day-a/
  rbac/
    namespace-serviceaccounts.yaml
    developer-role.yaml
    viewer-clusterrole.yaml
    sre-clusterrole.yaml
    kustomization.yaml
  policies/
    gatekeeper/
    native/
  examples/
    compliant-deployment.yaml
    noncompliant-deployment.yaml
  scripts/
    verify-rbac.ps1
```

Lab dùng namespace riêng:

```text
w10-rbac-lab
```

Ba ServiceAccount đại diện cho ba nhóm người dùng:

| ServiceAccount | Phạm vi | Mục đích |
| --- | --- | --- |
| `developer` | Một namespace | Triển khai và quản lý workload |
| `viewer` | Một namespace | Chỉ xem workload |
| `sre` | Toàn cluster | Quan sát cluster, log, event và metrics |

## 3. Giải thích RBAC

### 3.1 Role và ClusterRole

`Role` khai báo quyền trong một namespace. Role `developer` cho phép thao tác
với workload, Service và ConfigMap trong `w10-rbac-lab`.

```yaml
kind: Role
metadata:
  name: developer
  namespace: w10-rbac-lab
```

Developer có các verb:

```text
get, list, watch, create, update, patch, delete
```

Developer không được cấp quyền với:

```text
secrets
roles
rolebindings
clusterroles
clusterrolebindings
```

Đây là nguyên tắc least privilege: chỉ cấp quyền cần thiết cho công việc.

`ClusterRole` không bị giới hạn vào một namespace khi định nghĩa. Tuy nhiên,
cách bind ClusterRole quyết định phạm vi quyền thực tế.

### 3.2 RoleBinding và ClusterRoleBinding

RoleBinding `viewer` tham chiếu ClusterRole `w10-viewer`:

```yaml
roleRef:
  kind: ClusterRole
  name: w10-viewer
```

Vì đây là RoleBinding trong `w10-rbac-lab`, viewer chỉ có quyền đọc trong
namespace này. Đây là cách tái sử dụng một ClusterRole nhưng vẫn giới hạn phạm
vi.

SRE dùng ClusterRoleBinding:

```yaml
kind: ClusterRoleBinding
roleRef:
  kind: ClusterRole
  name: w10-sre
```

Vì vậy quyền đọc của SRE có hiệu lực trên toàn cluster, bao gồm Node,
Namespace, workload, event, volume, NetworkPolicy và metrics.

### 3.3 ServiceAccount

ServiceAccount là danh tính Kubernetes dành cho Pod hoặc automation:

```text
system:serviceaccount:w10-rbac-lab:developer
system:serviceaccount:w10-rbac-lab:viewer
system:serviceaccount:w10-rbac-lab:sre
```

RBAC không tự cấp quyền khi tạo ServiceAccount. Quyền chỉ xuất hiện sau khi
ServiceAccount được thêm vào RoleBinding hoặc ClusterRoleBinding.

### 3.4 Triển khai RBAC

```powershell
kubectl apply -k cloud/w10/day-a/rbac
```

Kustomize đọc `kustomization.yaml` và áp dụng toàn bộ namespace, ServiceAccount,
Role, ClusterRole và binding.

Kiểm tra resource:

```powershell
kubectl get serviceaccounts -n w10-rbac-lab
kubectl get role,rolebinding -n w10-rbac-lab
kubectl get clusterrole w10-viewer w10-sre
kubectl get clusterrolebinding w10-sre
```

## 4. Giải thích `kubectl auth can-i`

`kubectl auth can-i` gửi SubjectAccessReview đến API server để hỏi một danh
tính có quyền thực hiện action hay không.

Ví dụ:

```powershell
kubectl auth can-i create deployments.apps `
  -n w10-rbac-lab `
  --as system:serviceaccount:w10-rbac-lab:developer
```

Các thành phần:

- `create`: verb cần kiểm tra.
- `deployments.apps`: resource và API group.
- `-n w10-rbac-lab`: namespace đích.
- `--as`: impersonate ServiceAccount cần kiểm tra.

Chạy toàn bộ test:

```powershell
.\cloud\w10\day-a\scripts\verify-rbac.ps1
```

Kết quả quan trọng:

| Danh tính | Kiểm tra | Kết quả |
| --- | --- | --- |
| Developer | Create Deployment | `yes` |
| Developer | Read Secret | `no` |
| Developer | Create RoleBinding | `no` |
| Viewer | Read Deployment | `yes` |
| Viewer | Create Deployment | `no` |
| SRE | Read Node toàn cluster | `yes` |
| SRE | Create Deployment | `no` |

Script coi cả `yes` và `no` là kết quả hợp lệ. `kubectl auth can-i` trả exit
code `1` khi câu trả lời là `no`, nên script đánh giá nội dung output thay vì
coi exit code `1` là lỗi chương trình.

## 5. Admission Policy với Gatekeeper

### 5.1 OPA và Rego

OPA là policy engine. Rego là ngôn ngữ dùng để mô tả policy. Gatekeeper đưa OPA
vào luồng admission của Kubernetes và cung cấp khả năng audit resource hiện có.

Policy của lab yêu cầu workload phải có label:

```yaml
metadata:
  labels:
    owner: platform-team
```

### 5.2 ConstraintTemplate

ConstraintTemplate là phần định nghĩa policy có thể tái sử dụng:

- Tạo custom resource kind `K8sRequiredOwnerLabel`.
- Khai báo parameter `labels`.
- Chứa code Rego kiểm tra object.

Code Rego:

```rego
violation[{"msg": msg}] {
  required := input.parameters.labels[_]
  labels := object.get(input.review.object.metadata, "labels", {})
  not labels[required]
  msg := sprintf("missing required label: %s", [required])
}
```

Giải thích:

1. Lấy từng label bắt buộc từ `input.parameters.labels`.
2. Đọc `metadata.labels` của object đang được review.
3. Nếu label bắt buộc không tồn tại thì tạo một violation.
4. Trả thông báo `missing required label: owner`.

### 5.3 Constraint

Constraint là instance của ConstraintTemplate. Nó xác định:

- Policy áp dụng cho namespace nào.
- Policy kiểm tra loại resource nào.
- Parameter thực tế là gì.
- Chạy audit hay enforce.

Lab áp dụng cho:

```text
Pod
Deployment
StatefulSet
DaemonSet
Job
CronJob
```

Parameter:

```yaml
parameters:
  labels:
    - owner
```

### 5.4 Audit mode

Audit mode dùng:

```yaml
enforcementAction: dryrun
```

Resource vi phạm vẫn được tạo. Gatekeeper định kỳ quét cluster và ghi violation
vào status của Constraint.

```powershell
kubectl apply -f cloud/w10/day-a/policies/gatekeeper/constraint-template.yaml

kubectl wait --for=condition=Established `
  crd/k8srequiredownerlabel.constraints.gatekeeper.sh `
  --timeout=120s

kubectl apply `
  -f cloud/w10/day-a/policies/gatekeeper/constraint-audit.yaml

kubectl apply `
  -f cloud/w10/day-a/examples/noncompliant-deployment.yaml

Start-Sleep -Seconds 70

kubectl get k8srequiredownerlabel required-owner-label -o yaml
```

Kết quả đã kiểm thử:

```text
totalViolations: 2
Deployment owner-label-missing: missing required label: owner
Pod owner-label-missing-...: missing required label: owner
```

Có hai violation vì Deployment thiếu label và Pod được Deployment tạo ra cũng
thiếu label.

### 5.5 Enforce mode

Enforce mode dùng:

```yaml
enforcementAction: deny
```

```powershell
kubectl apply `
  -f cloud/w10/day-a/policies/gatekeeper/constraint-enforce.yaml

kubectl delete deployment owner-label-missing `
  -n w10-rbac-lab `
  --ignore-not-found

kubectl apply `
  -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Kết quả mong đợi:

```text
admission webhook "validation.gatekeeper.sh" denied the request:
[required-owner-label] missing required label: owner
```

RBAC có thể cho phép user tạo Deployment, nhưng Gatekeeper vẫn chặn vì nội dung
Deployment vi phạm policy.

## 6. ValidatingAdmissionPolicy native

Kubernetes 1.30+ hỗ trợ admission validation native bằng CEL, không cần cài
webhook bên ngoài.

### 6.1 ValidatingAdmissionPolicy

Policy xác định:

- Operation: `CREATE`, `UPDATE`.
- Resource cần kiểm tra.
- Biểu thức CEL.
- Thông báo khi validation thất bại.

Biểu thức CEL:

```text
has(object.metadata.labels) &&
'owner' in object.metadata.labels &&
object.metadata.labels['owner'] != ''
```

Biểu thức yêu cầu:

1. `metadata.labels` tồn tại.
2. Key `owner` tồn tại.
3. Giá trị của `owner` không rỗng.

`failurePolicy: Fail` có nghĩa là request sẽ bị từ chối nếu policy không thể
được đánh giá an toàn.

### 6.2 ValidatingAdmissionPolicyBinding

Policy chỉ chứa rule. Binding xác định nơi áp dụng và action:

```yaml
namespaceSelector:
  matchLabels:
    kubernetes.io/metadata.name: w10-rbac-lab
```

Namespace tự động có label `kubernetes.io/metadata.name`, nên policy chỉ áp
dụng cho `w10-rbac-lab`.

### 6.3 Audit và warning

```yaml
validationActions:
  - Warn
  - Audit
```

- `Warn`: trả cảnh báo về cho `kubectl`, nhưng vẫn cho phép request.
- `Audit`: thêm thông tin validation vào API audit event nếu cluster bật audit
  logging.

Trước khi test native policy, chuyển Gatekeeper về audit để không chặn request:

```powershell
kubectl apply `
  -f cloud/w10/day-a/policies/gatekeeper/constraint-audit.yaml

kubectl apply -k cloud/w10/day-a/policies/native

kubectl delete deployment owner-label-missing `
  -n w10-rbac-lab `
  --ignore-not-found

kubectl apply `
  -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Kết quả đã kiểm thử:

```text
Warning: Validation failed for ValidatingAdmissionPolicy
'required-owner-label' with binding 'required-owner-label':
workloads must define a non-empty owner label
```

Deployment vẫn được tạo vì action chưa có `Deny`.

### 6.4 Enforce native policy

```yaml
validationActions:
  - Deny
  - Audit
```

```powershell
kubectl apply `
  -f cloud/w10/day-a/policies/native/binding-enforce.yaml

kubectl delete deployment owner-label-missing `
  -n w10-rbac-lab `
  --ignore-not-found

kubectl apply `
  -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Kết quả đã kiểm thử:

```text
ValidatingAdmissionPolicy 'required-owner-label'
with binding 'required-owner-label' denied request:
workloads must define a non-empty owner label
```

## 7. Workload hợp lệ và không hợp lệ

### Workload hợp lệ

Deployment có label ở cả Deployment metadata và Pod template:

```yaml
metadata:
  labels:
    owner: platform-team
spec:
  template:
    metadata:
      labels:
        owner: platform-team
```

Cần đặt label ở cả hai vị trí vì policy kiểm tra cả Deployment lẫn Pod.

```powershell
kubectl apply `
  -f cloud/w10/day-a/examples/compliant-deployment.yaml

kubectl get deployment,pod `
  -n w10-rbac-lab `
  --show-labels
```

Kết quả đã kiểm thử:

```text
Deployment: owner=platform-team
Pod: app=owner-label-compliant,owner=platform-team
```

### Workload không hợp lệ

`noncompliant-deployment.yaml` không khai báo `owner` ở Deployment và Pod
template. Nó được dùng để chứng minh:

- Audit mode chỉ phát hiện và báo cáo.
- Warn mode cảnh báo nhưng vẫn cho phép.
- Enforce mode từ chối request.

## 8. So sánh Gatekeeper và native policy

| Nội dung | Gatekeeper | Native policy |
| --- | --- | --- |
| Ngôn ngữ | Rego | CEL |
| Thành phần ngoài cluster core | Có webhook Gatekeeper | Không |
| Policy definition | ConstraintTemplate | ValidatingAdmissionPolicy |
| Policy instance | Constraint | ValidatingAdmissionPolicyBinding |
| Audit không chặn | `dryrun` | `Warn, Audit` |
| Enforce | `deny` | `Deny, Audit` |
| Audit resource hiện có | Có | Không theo cách Gatekeeper audit |
| Phù hợp | Policy library, Rego, platform lớn | Validation native, rule đơn giản |

Không nên enforce cùng một rule bằng cả hai engine trong lúc demo vì request có
thể bị engine đầu tiên chặn, làm thông báo evidence không rõ ràng.

Trạng thái cuối của lab:

```text
Gatekeeper: dryrun
Native policy: Deny, Audit
```

## 9. Evidence cần trình bày

### Evidence 1 - RBAC

Chụp output:

```powershell
.\cloud\w10\day-a\scripts\verify-rbac.ps1
```

Yêu cầu: toàn bộ dòng là `PASS` và cuối cùng có:

```text
RBAC verification passed.
```

### Evidence 2 - Gatekeeper audit

Chụp phần:

```text
totalViolations: 2
message: missing required label: owner
```

### Evidence 3 - Gatekeeper enforce

Chụp lỗi:

```text
admission webhook "validation.gatekeeper.sh" denied the request
```

### Evidence 4 - Native warning

Chụp warning của ValidatingAdmissionPolicy trong chế độ `Warn, Audit`.

### Evidence 5 - Native enforce và workload hợp lệ

Chụp:

- Native policy từ chối workload thiếu label.
- Deployment và Pod hợp lệ ở trạng thái Running với `owner=platform-team`.

## 10. Kết luận trình bày

Day A tạo hai lớp kiểm soát:

1. RBAC áp dụng least privilege cho `developer`, `viewer` và `sre`.
2. Admission Policy bảo đảm workload tuân thủ yêu cầu quản trị của cluster.

Kết quả quan trọng nhất là developer không thể vượt quyền, đồng thời một
Deployment dù được developer phép tạo vẫn bị từ chối nếu thiếu label `owner`.
Audit-first giúp phát hiện vi phạm mà không làm gián đoạn workload; sau khi sửa
vi phạm mới chuyển policy sang enforce.

## 11. Câu hỏi thường gặp

### Vì sao viewer dùng ClusterRole nhưng chỉ có quyền trong một namespace?

Vì ClusterRole được bind bằng RoleBinding nằm trong `w10-rbac-lab`.

### Vì sao SRE dùng ClusterRoleBinding?

SRE cần xem Node, Namespace và workload trên toàn cluster. RoleBinding không
thể cấp phạm vi toàn cluster.

### RBAC có thể chặn Deployment thiếu label không?

Không. RBAC chỉ kiểm tra identity, verb và resource. Kiểm tra nội dung object là
trách nhiệm của admission policy.

### Vì sao audit trước enforce?

Enforce ngay có thể làm hỏng pipeline và chặn workload hiện tại. Audit cho biết
blast radius trước khi bật chặn.

### ConstraintTemplate khác Constraint như thế nào?

ConstraintTemplate là code và schema của policy. Constraint là cấu hình áp dụng
policy đó cho resource cụ thể.

### Gatekeeper khác ValidatingAdmissionPolicy như thế nào?

Gatekeeper dùng Rego và webhook, có audit resource hiện có. Native policy dùng
CEL trực tiếp trong Kubernetes và phù hợp với validation đơn giản.

### Vì sao workload hợp lệ cần label ở cả Deployment và Pod template?

Deployment và Pod đều nằm trong phạm vi policy. Label trên Deployment không tự
động trở thành label của Pod nếu Pod template không khai báo nó.
