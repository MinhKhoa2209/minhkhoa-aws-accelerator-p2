# Luồng hoạt động W9 Lab

## 1. Mục tiêu lab

Lab week 9 biến ứng dụng từ week 8 thành một nền tảng triển khai theo hướng GitOps.

Các mục tiêu chính:

- Argo CD quản lý manifest Kubernetes từ Git.
- Ứng dụng chạy trong namespace `w8-day-2`.
- Observability chạy trong namespace `observability`.
- Prometheus scrape metric từ ứng dụng qua endpoint `/metrics`.
- Argo Rollouts triển khai canary release.
- Canary được kiểm tra bằng Prometheus query trước khi promote.
- Release lỗi có thể bị abort thay vì đẩy toàn bộ traffic sang version mới.

Viết ngắn gọn:

`Git -> Argo CD -> Kubernetes -> App -> Metrics -> Prometheus -> Argo Rollouts Analysis -> Promote/Abort`

## 2. Các nhóm manifest chính

### Argo CD applications

Thư mục:

- `cloud/w9/day-a/argocd`

Vai trò:

- `app-of-apps.yaml` tạo root application `w9-root`.
- `w8-platform-app.yaml` sync phần platform.
- `w9-observability-app.yaml` sync phần observability.
- `w9-rollout-app.yaml` sync phần rollout.

Root app dùng mô hình app-of-apps. Nghĩa là mình chỉ apply một app gốc, sau đó Argo CD tự tạo và quản lý các app con.

Thứ tự sync:

1. `w8-platform`, sync wave `0`
2. `w9-observability`, sync wave `1`
3. `w9-rollout`, sync wave `2`

Thứ tự này giúp nền tảng và monitoring có trước, sau đó rollout mới chạy app.

### Platform

Thư mục:

- `cloud/w9/lab/platform`

Vai trò:

- Tạo namespace `w8-day-2`.
- Tạo `ConfigMap` chứa cấu hình app.
- Tạo `Secret` chứa giá trị nhạy cảm giả lập.
- Tạo `Service` tên `announcement-service`.
- Tạo `NetworkPolicy` giới hạn ingress vào app.
- Tạo `smoke-test-client` để test nội bộ trong cluster.

Platform không trực tiếp tạo workload chính của app. Workload chính nằm trong phần rollout để Argo Rollouts quản lý.

### Rollout

Thư mục:

- `cloud/w9/lab/rollout`

Vai trò:

- Tạo `Rollout` tên `announcement-app`.
- Chạy image `w8-announcement-app:0.1.1`.
- Chạy 2 replicas.
- Dùng readiness probe `/readyz`.
- Dùng liveness probe `/healthz`.
- Dùng canary strategy.
- Dùng `AnalysisTemplate` để kiểm tra success rate từ Prometheus.

Canary steps hiện tại:

1. Chuyển 20% traffic sang version mới.
2. Pause 60 giây.
3. Chạy analysis kiểm tra success rate.
4. Nếu đạt, tăng lên 50%.
5. Pause 60 giây.
6. Nếu ổn, promote lên 100%.

Điều kiện analysis:

```text
success rate >= 99%
```

Nếu metric không đạt, rollout có thể fail hoặc abort thay vì promote toàn bộ version mới.

### Observability

Thư mục:

- `cloud/w9/lab/observability`

Vai trò:

- Tạo namespace `observability`.
- Tạo OpenTelemetry Collector config.
- Tạo Prometheus config.
- Deploy Prometheus.
- Tạo SLO burn-rate alert rules.

Prometheus scrape app tại:

```text
announcement-service.w8-day-2.svc.cluster.local:80/metrics
```

Metric chính được dùng trong lab:

```text
http_server_requests_total
```

Metric này được dùng cho hai mục đích:

- Tính SLO burn-rate alert.
- Làm điều kiện analysis cho Argo Rollouts canary.

## 3. Luồng GitOps

Luồng triển khai chuẩn:

1. Developer chỉnh manifest trong Git.
2. Commit và push thay đổi lên repository.
3. Argo CD theo dõi repository.
4. Khi Git thay đổi, Argo CD phát hiện desired state mới.
5. Argo CD sync manifest vào Kubernetes cluster.
6. Nếu có drift trong cluster, Argo CD tự self-heal về đúng trạng thái trong Git.

Với lab này, không nên chỉnh workload bằng `kubectl apply` trực tiếp như đường chính. Cách đúng là đổi manifest trong Git, sau đó để Argo CD sync.

Luồng gọn:

`Commit -> Push -> Argo CD detects change -> Sync -> Kubernetes state updated`

## 4. Luồng chạy ứng dụng

Sau khi Argo CD sync xong:

1. Namespace `w8-day-2` được tạo.
2. ConfigMap, Secret, Service và NetworkPolicy được tạo.
3. Argo Rollouts tạo các Pod của `announcement-app`.
4. Pod lấy cấu hình từ ConfigMap và Secret.
5. Container expose HTTP port `8080`.
6. Service `announcement-service` expose app trong cluster qua port `80`.
7. Người dùng hoặc tester port-forward service ra local để truy cập.

Luồng request khi port-forward:

```text
Browser/curl -> localhost:8080 -> Kubernetes Service announcement-service:80 -> Pod:8080 -> app
```

Các endpoint kiểm tra:

- `/`
- `/healthz`
- `/readyz`
- `/metrics`

## 5. Luồng observability

Ứng dụng expose metric ở endpoint `/metrics`.

Prometheus được cấu hình scrape:

```text
announcement-service.w8-day-2.svc.cluster.local:80
```

Luồng metric:

```text
App /metrics -> Prometheus scrape -> Prometheus stores time series -> Alert rules and rollout analysis query metrics
```

SLO trong lab tập trung vào availability 99%.

Prometheus rule kiểm tra error budget burn theo hai nhóm:

- Fast burn: cửa sổ 5 phút và 1 giờ.
- Slow burn: cửa sổ 30 phút và 6 giờ.

Mục tiêu là phát hiện service đang trả lỗi nhiều hơn mức chấp nhận được so với SLO.

## 6. Luồng canary release

Khi muốn release version mới:

1. Build image mới.
2. Load image vào cluster runtime nếu dùng local cluster.
3. Cập nhật image tag trong `cloud/w9/lab/rollout/rollout.yaml`.
4. Commit và push thay đổi.
5. Argo CD sync manifest mới.
6. Argo Rollouts bắt đầu canary.
7. Một phần traffic được chuyển sang ReplicaSet mới.
8. Argo Rollouts gọi Prometheus query trong `AnalysisTemplate`.
9. Nếu success rate đạt yêu cầu, rollout tiếp tục promote.
10. Nếu success rate không đạt, rollout bị fail hoặc abort.

Luồng quyết định:

```text
New image tag -> Argo CD sync -> Argo Rollouts canary -> Prometheus analysis -> Promote or Abort
```

Điểm quan trọng là quyết định promote không dựa vào cảm giác. Nó dựa vào metric thực tế từ Prometheus.

## 7. Luồng rollback

Có hai khái niệm rollback cần phân biệt:

### Rollback desired state

Nếu manifest trong Git sai, cách rollback chuẩn là revert commit.

Luồng:

```text
Git revert -> Push -> Argo CD sync -> Cluster quay về desired state cũ
```

### Abort canary

Nếu version mới đang canary nhưng metric xấu, Argo Rollouts có thể abort rollout.

Luồng:

```text
Bad version receives traffic -> Metrics fail analysis -> Rollout aborts -> Stable version remains active
```

Git revert xử lý desired state. Argo Rollouts abort xử lý progressive delivery trong lúc release.

## 8. Luồng kiểm chứng lab

Các bước kiểm chứng chính:

1. Kiểm tra Argo CD applications:

```powershell
kubectl get applications -n argocd
```

2. Kiểm tra workload app:

```powershell
kubectl get all -n w8-day-2
kubectl get rollout announcement-app -n w8-day-2
```

3. Kiểm tra observability:

```powershell
kubectl get all -n observability
kubectl get prometheusrule -n observability
```

4. Port-forward app:

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

5. Test endpoint:

```powershell
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/healthz
curl http://127.0.0.1:8080/readyz
curl http://127.0.0.1:8080/metrics
```

6. Chạy load test:

```powershell
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

## 9. Cách giải thích ngắn với mentor

Lab week 9 dùng GitOps để quản lý deployment của app week 8. Em dùng Argo CD theo mô hình app-of-apps: root app tạo ba app con gồm platform, observability và rollout. Platform tạo namespace, config, secret, service và network policy. Observability deploy Prometheus và rules để scrape metric từ `/metrics`. Rollout dùng Argo Rollouts để triển khai app theo canary strategy. Khi đổi image tag trong Git, Argo CD sync thay đổi vào cluster, Argo Rollouts chuyển traffic từng phần sang version mới và dùng Prometheus query để kiểm tra success rate. Nếu metric tốt thì promote, nếu metric xấu thì abort canary.

## 10. Tóm tắt một dòng

`Git là source of truth, Argo CD sync desired state, Kubernetes chạy app, Prometheus đo sức khỏe, Argo Rollouts dùng metric để quyết định release mới có được promote hay không.`
