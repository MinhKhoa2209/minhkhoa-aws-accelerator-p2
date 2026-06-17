# W10-D3 - Platform Integration, Runbook và Cost Guard

Day C gom các phần đã làm ở W8-W10 thành một lớp vận hành có kiểm soát:

```text
GitOps -> guardrails -> rollout/observability -> runbook -> cost response
```

## Nội dung

- `guardrails/`: ResourceQuota, LimitRange, PodDisruptionBudget và
  ValidatingAdmissionPolicy để giữ workload trong giới hạn chi phí.
- `integration/`: Argo CD Application mẫu để đưa guardrails vào GitOps.
- `runbooks/`: quy trình xử lý incident, rollout lỗi và chi phí tăng bất thường.
- `scripts/verify-day-c.ps1`: kiểm tra nhanh artifact Day C.

## Guardrails chính

| Guardrail | Mục đích |
| --- | --- |
| ResourceQuota | Chặn namespace vượt request/limit CPU, memory, số Pod và số LoadBalancer tối đa |
| LimitRange | Gán default request/limit để Pod không chạy dạng best-effort |
| PodDisruptionBudget | Giữ ít nhất một replica `announcement-app` khi node drain |
| Required cost labels | Bắt workload có `owner`, `cost-center`, `environment` |
| Deny LoadBalancer | Chặn Service `LoadBalancer` nếu không có annotation exception |

Namespace mục tiêu là `w8-day-2`, vì đây là workload nền tảng đã được W9 đưa
vào GitOps, observability và rollout.

## Chạy lab

Render manifest để kiểm tra cú pháp:

```powershell
kubectl kustomize cloud/w10/day-c/guardrails
```

Apply guardrails trực tiếp khi cần test nhanh:

```powershell
kubectl apply -k cloud/w10/day-c/guardrails
kubectl get resourcequota,limitrange,pdb -n w8-day-2
kubectl get validatingadmissionpolicy,validatingadmissionpolicybinding
```

Đường GitOps khuyến nghị là tạo Application Day C trong Argo CD:

```powershell
kubectl apply -f cloud/w10/day-c/integration/w10-day-c-guardrails-app.yaml
kubectl get applications -n argocd w10-day-c-guardrails
```

## Test chính sách

Workload thiếu label chi phí phải bị reject:

```powershell
kubectl apply -f cloud/w10/day-c/tests/workload-missing-cost-labels.yaml
```

Service `LoadBalancer` không có exception phải bị reject:

```powershell
kubectl apply -f cloud/w10/day-c/tests/loadbalancer-service-denied.yaml
```

Workload hợp lệ có đủ label chi phí phải được chấp nhận:

```powershell
kubectl apply -f cloud/w10/day-c/tests/workload-with-cost-labels.yaml
kubectl get deploy -n w8-day-2 day-c-cost-label-pass --show-labels
```

## Kiểm tra artifact

```powershell
.\cloud\w10\day-c\scripts\verify-day-c.ps1
```

Script kiểm tra file chính, policy fail-closed, quota chặn LoadBalancer, label
chi phí bắt buộc, Argo CD path đúng và runbook có đủ luồng xử lý.

## Evidence

1. `kubectl kustomize cloud/w10/day-c/guardrails` render thành công.
2. `ResourceQuota`, `LimitRange`, `PodDisruptionBudget` tồn tại trong
   namespace `w8-day-2`.
3. Workload thiếu `cost-center` hoặc `environment` bị admission reject.
4. Service `LoadBalancer` không có exception bị admission reject.
5. Runbook chỉ rõ khi nào dùng Argo Rollouts abort và khi nào dùng Git revert.

## Tài liệu

- [Kịch bản giải thích chi tiết Day C](../../docs/w10/DAY_C_SCRIPT.md)
- [Tài liệu self-study](../../docs/w10/day3-platform-runbook-cost-guard.md)
