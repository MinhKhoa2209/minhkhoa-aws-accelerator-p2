# W10-D1 - RBAC và Admission Policy

## Mục tiêu

Tạo ba mức quyền Kubernetes và bắt buộc workload có label `owner`.

```text
identity -> RBAC authorization -> admission policy -> Kubernetes API
```

## Mô hình RBAC

| Danh tính | Phạm vi | Quyền |
| --- | --- | --- |
| `developer` | `w10-rbac-lab` | Quản lý workload, Service và ConfigMap |
| `viewer` | `w10-rbac-lab` | Chỉ đọc workload và cấu hình |
| `sre` | Cluster | Đọc resource cấp cluster, event, workload và log |

Developer không được đọc Secret hoặc thay đổi RBAC. Viewer không được tạo hay
xóa workload.

## 1. Áp dụng và kiểm tra RBAC

```powershell
kubectl apply -k cloud/w10/day-a/rbac
.\cloud\w10\day-a\scripts\verify-rbac.ps1
```

## 2. Chọn admission policy engine

Hai phương án bên dưới cùng yêu cầu label `owner` khác rỗng. Chỉ nên enforce
một phương án tại một thời điểm để thông báo reject dễ xác định.

### Phương án A - Gatekeeper

Cài Gatekeeper `v3.22.2`, sau đó bắt đầu bằng audit:

```powershell
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.22.2/deploy/gatekeeper.yaml
kubectl wait --for=condition=Established crd/constrainttemplates.templates.gatekeeper.sh --timeout=180s

kubectl apply -f cloud/w10/day-a/policies/gatekeeper/constraint-template.yaml
kubectl wait --for=condition=Established `
  crd/k8srequiredownerlabel.constraints.gatekeeper.sh `
  --timeout=120s
kubectl apply -f cloud/w10/day-a/policies/gatekeeper/constraint-audit.yaml
```

Tạo workload vi phạm rồi xem kết quả audit:

```powershell
kubectl apply -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
kubectl get k8srequiredownerlabel required-owner-label -o yaml
```

Sau khi xử lý vi phạm, chuyển cùng Constraint sang enforce:

```powershell
kubectl apply -f cloud/w10/day-a/policies/gatekeeper/constraint-enforce.yaml
kubectl delete deployment owner-label-missing -n w10-rbac-lab
kubectl apply -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Lệnh cuối phải bị từ chối.

### Phương án B - Kubernetes native

Yêu cầu Kubernetes 1.30 trở lên:

```powershell
kubectl version
kubectl apply -k cloud/w10/day-a/policies/native
kubectl apply -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Audit mode trả warning cho `kubectl`. Action `Audit` chỉ ghi audit annotation
nếu API audit logging của cluster đã được bật.

Chuyển sang enforce:

```powershell
kubectl apply -f cloud/w10/day-a/policies/native/binding-enforce.yaml
kubectl delete deployment owner-label-missing -n w10-rbac-lab
kubectl apply -f cloud/w10/day-a/examples/noncompliant-deployment.yaml
```

Lệnh cuối phải bị từ chối.

## 3. Test workload hợp lệ

Workload có label phải được chấp nhận:

```powershell
kubectl apply -f cloud/w10/day-a/examples/compliant-deployment.yaml
kubectl get deployments -n w10-rbac-lab --show-labels
```

## Audit và enforce

| Engine | Audit | Enforce |
| --- | --- | --- |
| Gatekeeper | `dryrun` | `deny` |
| Native policy | `Warn, Audit` | `Deny, Audit` |

Luôn chạy audit trước để phát hiện vi phạm hiện có mà không làm hỏng deployment.
Chỉ enforce sau khi đã sửa workload và rà soát exception.

## Evidence

1. Terminal hiển thị toàn bộ test trong `verify-rbac.ps1` đều `PASS`.
2. Constraint Gatekeeper có violation trong `status`.
3. Terminal hiển thị workload thiếu `owner` bị reject khi enforce.
4. Deployment hợp lệ được tạo và hiển thị label `owner`.
5. Terminal hiển thị warning của ValidatingAdmissionPolicy native.

## Tài liệu

- [Kịch bản giải thích chi tiết Day A](../../docs/w10/DAY_A_SCRIPT.md)
- [Tài liệu self-study](../../docs/w10/day1-rbac-admission-policy.md)
