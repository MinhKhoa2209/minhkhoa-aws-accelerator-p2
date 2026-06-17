# W10-D3 Runbook - Cost Response

## Tín hiệu cần kiểm tra

- ResourceQuota gần đầy hoặc bị vượt.
- Service `LoadBalancer` được yêu cầu ngoài kế hoạch.
- Replica hoặc request CPU/memory tăng bất thường.
- AWS Cost Explorer hiển thị chi phí EC2, NAT, ELB hoặc CloudWatch tăng.

## Lệnh kiểm tra Kubernetes

```powershell
kubectl describe resourcequota w10-cost-guard -n w8-day-2
kubectl get deploy,rollout,pod,svc -n w8-day-2 -o wide
kubectl top pod -n w8-day-2
kubectl top node
```

Nếu namespace bị chặn bởi quota:

```powershell
kubectl get events -n w8-day-2 --sort-by=.lastTimestamp
kubectl describe pod -n w8-day-2 <pod-name>
```

## Lệnh kiểm tra AWS

Luôn chỉ định region khi kiểm tra tài nguyên lab:

```powershell
aws ce get-cost-and-usage `
  --time-period Start=<yyyy-mm-01>,End=<yyyy-mm-dd> `
  --granularity DAILY `
  --metrics UnblendedCost

aws elbv2 describe-load-balancers --region us-east-1
aws ec2 describe-instances --region us-east-1
aws logs describe-log-groups --region us-east-1
```

## Hướng xử lý

| Nguyên nhân | Hành động |
| --- | --- |
| Replica tăng quá mức | Giảm replica trong Git, commit và để Argo CD sync |
| Request/limit quá cao | Điều chỉnh manifest theo nhu cầu thật |
| Service cần LoadBalancer thật | Thêm annotation exception và ghi owner/ngày hết hạn |
| Tài nguyên AWS còn sót | Cleanup theo script lab tương ứng và xác minh lại |

## Exception LoadBalancer

Chỉ dùng exception khi có lý do rõ ràng:

```yaml
metadata:
  annotations:
    platform.aws.accelerator/allow-load-balancer: "true"
    platform.aws.accelerator/exception-owner: "platform-team"
    platform.aws.accelerator/exception-expiry: "2026-06-30"
```

Exception phải có owner, ngày hết hạn và ticket/lý do trong commit message.
