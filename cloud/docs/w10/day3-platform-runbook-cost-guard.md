# W10-D3 Self-study - Platform Integration, Runbook và Cost Guard

## Mục tiêu

Sau Day C, người học hiểu cách biến một cụm Kubernetes đã có GitOps,
observability và security thành một nền tảng vận hành có giới hạn rõ ràng.

## 1. Platform integration

Platform integration nghĩa là không để từng phần đứng riêng lẻ:

- W8 cung cấp ứng dụng và manifest nền tảng.
- W9 thêm Argo CD, Prometheus, Grafana, k6 và Argo Rollouts.
- W10 Day A thêm RBAC và admission policy.
- W10 Day B thêm secret rotation, image scan và image signing.
- W10 Day C nối chúng bằng guardrails và runbook.

Trong repo này, Day C dùng Argo CD Application
`w10-day-c-guardrails` để quản lý `cloud/w10/day-c/guardrails`.

## 2. Cost guard

Cost guard là các kiểm soát giảm rủi ro phát sinh chi phí ngoài ý muốn.

Các guardrail trong lab:

- `ResourceQuota`: giới hạn tổng CPU, memory, số Pod và số Service
  `LoadBalancer` tối đa.
- `LimitRange`: đặt default request/limit cho container.
- `ValidatingAdmissionPolicy`: bắt workload có label `owner`, `cost-center`,
  `environment`.
- Policy chặn `LoadBalancer`: chỉ cho phép khi có annotation exception.

Điểm quan trọng là guardrail phải fail-closed. Nếu admission policy lỗi hoặc
không chắc chắn, cluster nên từ chối thay đổi thay vì cho qua một thay đổi có
rủi ro.

## 3. Runbook

Runbook là hướng dẫn xử lý sự cố theo thứ tự cố định. Runbook tốt cần có:

- tín hiệu kích hoạt,
- lệnh kiểm tra nhanh,
- tiêu chí quyết định,
- hành động rollback hoặc cleanup,
- bước xác minh sau khi xử lý.

Trong Day C có hai runbook:

- `incident-response.md`: xử lý rollout lỗi, SLO burn-rate và admission reject.
- `cost-response.md`: xử lý quota đầy, tài nguyên tăng bất thường và exception.

## 4. Rollout abort và Git revert

Hai thao tác này giải quyết hai vấn đề khác nhau:

| Thao tác | Khi dùng |
| --- | --- |
| Argo Rollouts abort | Canary đang chạy và analysis fail |
| Git revert | Desired state trong Git sai và cần quay lại phiên bản trước |

Abort giúp dừng rollout xấu ngay trong runtime. Git revert sửa nguồn sự thật để
Argo CD không tiếp tục sync cấu hình sai.

## 5. Checklist tự học

- Giải thích được vì sao `LoadBalancer` cần exception.
- Giải thích được vì sao workload phải có `owner` và `cost-center`.
- Phân biệt được ResourceQuota và LimitRange.
- Biết đọc sự kiện namespace khi Pod bị quota reject.
- Biết khi nào dùng `kubectl argo rollouts abort`.
- Biết khi nào phải revert commit thay vì sửa tay trong cluster.
