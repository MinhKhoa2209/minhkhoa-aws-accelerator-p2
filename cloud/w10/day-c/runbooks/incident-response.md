# W10-D3 Runbook - Incident Response

## Khi nào dùng

Dùng runbook này khi `announcement-app` lỗi rollout, SLO burn-rate báo động,
hoặc guardrail Day C chặn một thay đổi không hợp lệ.

## Triage nhanh

```powershell
kubectl get applications -n argocd
kubectl get rollout announcement-app -n w8-day-2
kubectl get pods,svc,pdb,resourcequota,limitrange -n w8-day-2
kubectl get events -n w8-day-2 --sort-by=.lastTimestamp
```

Nếu lỗi nằm ở Argo CD:

```powershell
kubectl describe application -n argocd w9-rollout
kubectl describe application -n argocd w10-day-c-guardrails
```

Nếu lỗi nằm ở rollout:

```powershell
kubectl argo rollouts get rollout announcement-app -n w8-day-2
kubectl argo rollouts abort announcement-app -n w8-day-2
```

## Quyết định rollback

| Tình huống | Hành động |
| --- | --- |
| Canary đang fail analysis | `kubectl argo rollouts abort` để dừng version lỗi |
| Desired state trong Git sai | Revert commit rồi để Argo CD sync lại |
| Guardrail reject vì thiếu label | Sửa manifest, commit và sync lại |
| ResourceQuota đầy | Giảm replica/request hoặc cleanup workload tạm |

## Kiểm tra SLO

Alert W9 cần quan sát:

- `W8ServiceFastBurn`: lỗi nhanh, cần phản ứng ngay.
- `W8ServiceSlowBurn`: lỗi kéo dài, cần tạo ticket và theo dõi.

Prometheus query tham khảo:

```promql
sum(rate(http_server_requests_total{service_name="announcement-app",status_code=~"2.."}[5m]))
/
sum(rate(http_server_requests_total{service_name="announcement-app"}[5m]))
```

## Hoàn tất incident

1. Ghi lại commit hoặc image tag gây lỗi.
2. Ghi lại lệnh abort/revert đã dùng.
3. Kiểm tra Argo CD trở lại `Synced`.
4. Kiểm tra rollout `Healthy`.
5. Cập nhật exception hoặc guardrail nếu đây là thay đổi hợp lệ.
