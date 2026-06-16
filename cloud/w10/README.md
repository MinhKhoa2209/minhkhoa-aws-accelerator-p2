# W10 - Secure & Operate

W10 hardening nền tảng W8-W9 bằng phân quyền ở cấp cluster, admission policy,
quản lý secret, bảo vệ supply chain và các guardrail vận hành.

## Cấu trúc

```text
cloud/w10/
  day-a/    RBAC và admission policy
  day-b/    Secrets rotation và supply-chain security
  day-c/    Platform integration, runbook và cost guard
  lab/      Khắc phục 6 rủi ro và enforce ở cấp cluster
  reflection.md
```

## Day 1

Day 1 đã triển khai:

- RBAC theo namespace và toàn cluster
- ba ServiceAccount `developer`, `viewer`, `sre`
- kiểm tra quyền bằng `kubectl auth can-i`
- policy OPA Rego chạy qua Gatekeeper
- policy tương đương bằng `ValidatingAdmissionPolicy` native
- quy trình bật audit trước, enforce sau

Thực hành tại [`day-a/README.md`](day-a/README.md).

## Day 2

Day 2 đã scaffold và kiểm tra artifact cho:

- AWS Secrets Manager + External Secrets Operator
- secret refresh mỗi 30 giây
- workload demo đọc Kubernetes Secret runtime
- Trivy filesystem scan và image scan trong CI
- Cosign keyless signing bằng GitHub OIDC
- Kyverno `verifyImages` enforce image đã ký
- template exception CVE có owner và ngày hết hạn

Thực hành tại [`day-b/README.md`](day-b/README.md).
