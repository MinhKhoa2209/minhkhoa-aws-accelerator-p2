# Kịch bản giải thích W10-D3 - Platform Integration, Runbook và Cost Guard

## Câu trả lời ngắn

Day C không tạo thêm một app mới. Mục tiêu là nối các phần đã làm ở W8, W9 và
W10 thành một lớp vận hành có guardrail rõ ràng: Argo CD quản lý manifest,
Rollouts kiểm soát release, Prometheus báo SLO, còn Day C thêm quota, label chi
phí, runbook và chặn tài nguyên dễ gây tốn tiền.

## Luồng hoạt động

```text
Developer commit
  -> Argo CD sync
  -> ValidatingAdmissionPolicy kiểm tra label và LoadBalancer
  -> ResourceQuota/LimitRange kiểm soát tài nguyên
  -> Rollout chạy canary
  -> Prometheus cảnh báo SLO
  -> Runbook hướng dẫn abort, revert hoặc cleanup cost
```

## Vì sao cần Day C

Day A đã trả lời câu hỏi "ai được làm gì". Day B trả lời câu hỏi "secret và
image có đáng tin không". Day C trả lời câu hỏi vận hành: nếu thay đổi đi vào
cluster thì nó có vượt ngân sách, có thiếu owner, có phá rollout, và khi có sự
cố thì xử lý theo quy trình nào.

## File quan trọng

| File | Vai trò |
| --- | --- |
| `cloud/w10/day-c/guardrails/resource-quota.yaml` | Giới hạn request, limit, Pod và LoadBalancer |
| `cloud/w10/day-c/guardrails/limit-range.yaml` | Gán default request/limit cho container |
| `cloud/w10/day-c/guardrails/required-cost-labels-policy.yaml` | Bắt workload có `owner`, `cost-center`, `environment` |
| `cloud/w10/day-c/guardrails/deny-loadbalancer-policy.yaml` | Chặn Service `LoadBalancer` nếu không có exception |
| `cloud/w10/day-c/integration/w10-day-c-guardrails-app.yaml` | Đưa guardrails vào Argo CD |
| `cloud/w10/day-c/runbooks/incident-response.md` | Hướng dẫn xử lý rollout/SLO/admission issue |
| `cloud/w10/day-c/runbooks/cost-response.md` | Hướng dẫn xử lý chi phí tăng hoặc quota đầy |

## Giải thích cho mentor

"Ở Day C em không chỉ apply thêm manifest, mà gom pipeline vận hành lại. Nếu
developer commit manifest thiếu owner hoặc cost-center, admission policy sẽ
chặn trước khi workload vào cluster. Nếu ai tạo Service LoadBalancer trực tiếp,
policy cũng chặn vì tài nguyên này dễ phát sinh chi phí. Nếu workload hợp lệ
nhưng request quá lớn, ResourceQuota và LimitRange sẽ giới hạn ở namespace
`w8-day-2`. Khi rollout lỗi, em không sửa tay trong cluster theo hướng lâu dài:
em dùng Argo Rollouts abort để dừng canary đang lỗi, sau đó revert commit trong
Git nếu desired state sai. Như vậy Git vẫn là nguồn sự thật."

## Evidence nên chụp

1. `kubectl kustomize cloud/w10/day-c/guardrails` render thành công.
2. `kubectl get resourcequota,limitrange,pdb -n w8-day-2`.
3. Apply workload thiếu label bị reject.
4. Apply Service `LoadBalancer` bị reject.
5. Argo CD Application `w10-day-c-guardrails` hiển thị `Synced`.
