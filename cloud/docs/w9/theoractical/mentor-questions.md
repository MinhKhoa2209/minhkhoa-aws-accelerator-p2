# W9 Mentor Questions

## Mục Đích

Tài liệu này tổng hợp các câu hỏi vấn đáp với mentor cho W9 - Deliver Smartly. Trọng tâm là GitOps, CI/CD, observability, SLO/SLI, Prometheus/Grafana/Loki, progressive delivery, canary rollout và load testing.

Mỗi câu hỏi gồm:

- Mentor muốn kiểm tra gì
- Trả lời ngắn để nói trực tiếp
- Follow-up có thể bị hỏi thêm

---

## 1. Tổng Quan W9

### W9 tập trung vào vấn đề gì?

Mentor muốn kiểm tra:

- Bạn có nắm theme "Deliver Smartly" không
- Bạn có nói được liên kết giữa GitOps, observability và canary không

Trả lời ngắn:

W9 tập trung vào việc đưa ứng dụng W8 lên một workflow vận hành an toàn hơn: Git là desired state, Argo CD sync cluster, CI validate trước khi merge, observability đo SLI/SLO, và rollout mới được bảo vệ bằng canary auto-abort nếu metric xấu.

Follow-up:

- Vì sao W9 không còn ưu tiên `kubectl apply` tay?
- Nếu chỉ có CI/CD mà không có observability thì canary có đáng tin không?

### Kết quả cuối W9 cần chứng minh được gì?

Mentor muốn kiểm tra:

- Bạn có biết output cuối tuần không
- Bạn có biết evidence nào cần có không

Trả lời ngắn:

Cần chứng minh W8 app được Argo CD quản lý, các manifest render được qua CI, có dashboard/alert dựa trên SLI/SLO, có Argo Rollouts canary, có Prometheus analysis để tiếp tục hoặc abort rollout, và có k6 output tạo traffic/kiểm tra threshold.

Follow-up:

- Evidence nào cho thấy Argo CD đang synced?
- Evidence nào cho thấy canary bị abort hoặc promoted?

---

## 2. GitOps Và CI/CD

### GitOps là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu desired state và reconcile không
- Bạn có phân biệt GitOps với deploy truyền thống không

Trả lời ngắn:

GitOps là mô hình vận hành trong đó Git chứa desired state của hệ thống, còn controller như Argo CD liên tục so sánh Git với live cluster và sync cluster về đúng trạng thái trong Git.

Follow-up:

- Desired state nằm ở đâu?
- Live state nằm ở đâu?
- Reconciliation nghĩa là gì?

### GitOps khác CI/CD truyền thống ở điểm nào?

Mentor muốn kiểm tra:

- Bạn có nhìn được vấn đề của pipeline chạy `kubectl apply` không

Trả lời ngắn:

CI/CD truyền thống thường đẩy thay đổi từ pipeline vào cluster. GitOps thì controller trong cluster kéo desired state từ Git về và apply. Như vậy Git trở thành source of truth, dễ audit, dễ rollback và giảm việc thay đổi cluster bằng tay.

Follow-up:

- Ai là thành phần sync cluster trong W9?
- Vì sao pull-based CD phù hợp với GitOps?

### Trong W9, CI làm gì và CD làm gì?

Mentor muốn kiểm tra:

- Bạn có phân định đúng ranh giới CI/CD không

Trả lời ngắn:

CI trả lời câu hỏi thay đổi có đủ an toàn để merge không, ví dụ render kustomize, validate YAML và chạy test. CD là việc Argo CD phát hiện commit mới sau merge và sync cluster về desired state đã được chấp thuận.

Follow-up:

- PR nên chạy những check nào?
- Sau merge thì ai apply manifest vào cluster?

### Drift là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu rủi ro khi sửa cluster trực tiếp không

Trả lời ngắn:

Drift là khi live state trong cluster khác với desired state trong Git. Ví dụ Git khai báo 2 replicas nhưng ai đó scale trực tiếp lên 5 replicas bằng `kubectl`.

Follow-up:

- Argo CD hiện trạng thái gì khi drift?
- `selfHeal` xử lý drift như thế nào?

### `prune` và `selfHeal` trong Argo CD có tác dụng gì?

Mentor muốn kiểm tra:

- Bạn có hiểu automated sync policy không

Trả lời ngắn:

`prune` xóa resource khỏi cluster nếu resource đó đã bị xóa khỏi Git. `selfHeal` đưa live cluster về lại desired state nếu ai đó sửa cluster trực tiếp làm phát sinh drift.

Follow-up:

- Khi nào `prune` có thể nguy hiểm?
- Có nên bật automated sync ở mọi môi trường không?

### Argo CD `Synced` khác `Healthy` như thế nào?

Mentor muốn kiểm tra:

- Bạn có đọc đúng status của Argo CD không

Trả lời ngắn:

`Synced` nói về việc Git state và cluster state đã khớp nhau. `Healthy` nói về trạng thái runtime của resource, ví dụ pod ready, deployment available, rollout không failed. Một app có thể Synced nhưng chưa Healthy nếu resource apply đúng nhưng pod đang lỗi.

Follow-up:

- Ví dụ nào có thể `Synced` nhưng `Degraded`?
- Khi debug Argo CD, nên xem sync status hay health status trước?

### Argo CD `Application` gồm những phần quan trọng nào?

Mentor muốn kiểm tra:

- Bạn có hiểu manifest Argo CD không

Trả lời ngắn:

Một `Application` nối Git source với Kubernetes destination. Các phần quan trọng là `repoURL`, `targetRevision`, `path`, `destination.server`, `destination.namespace` và `syncPolicy`.

Follow-up:

- Nếu sai `path` thì Argo CD lỗi gì?
- `targetRevision: HEAD` có nghĩa là gì?

### App-of-apps dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu cách bootstrap nhiều app bằng Argo CD không

Trả lời ngắn:

App-of-apps dùng một root Application để quản lý nhiều child Applications. Trong W9, root app `w9-root` quản lý `w8-platform`, `w9-observability` và `w9-rollout`, giúp bootstrap cả platform từ một entry point.

Follow-up:

- Lợi ích so với apply từng Application bằng tay?
- Khi nào app-of-apps trở nên khó quản lý?

### Sync waves dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu ordering khi apply resource/app không

Trả lời ngắn:

Sync waves là annotation để sắp xếp thứ tự sync. Wave số nhỏ chạy trước. Trong W9, platform là wave 0, observability là wave 1, rollout là wave 2 vì rollout và analysis phụ thuộc vào service/platform và Prometheus.

Follow-up:

- Nếu rollout sync trước Prometheus thì có thể lỗi gì?
- Wave mặc định là bao nhiêu?

### Argo CD khác Flux như thế nào?

Mentor muốn kiểm tra:

- Bạn có biết high-level trade-off giữa hai GitOps tool không

Trả lời ngắn:

Cả Argo CD và Flux đều là GitOps controller CNCF. Argo CD mạnh về UI, dễ demo và dễ học với người mới. Flux thiên về Git-first, nhẹ và controller model sâu hơn. W9 dùng Argo CD vì trực quan và phù hợp demo sync/health.

Follow-up:

- Nếu team không cần UI thì có thể chọn gì?
- Cả hai tool đều giải quyết vấn đề cốt lõi nào?

### Rollback đúng GitOps nên làm thế nào?

Mentor muốn kiểm tra:

- Bạn có ưu tiên Git source of truth không

Trả lời ngắn:

Rollback chuẩn trong GitOps là `git revert` commit lỗi, push lên repo, rồi để Argo CD sync cluster về desired state mới. Cách này giữ audit trail và không làm Git lệch với cluster.

Follow-up:

- Khi nào dùng `kubectl rollout undo`?
- Nếu đã `kubectl rollout undo` khẩn cấp thì cần làm gì sau đó?

---

## 3. Observability, SLI, SLO Và OpenTelemetry

### Observability là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu mục tiêu đo hệ thống, không chỉ cài tool không

Trả lời ngắn:

Observability là khả năng hiểu hành vi hệ thống từ các tín hiệu như metrics, logs và traces. Mục tiêu là biết service đang khỏe hay lỗi, lỗi ảnh hưởng người dùng thế nào, và cần debug ở đâu.

Follow-up:

- Monitoring và observability khác nhau thế nào?
- Tín hiệu nào phù hợp nhất để alert?

### Metrics, logs và traces khác nhau như thế nào?

Mentor muốn kiểm tra:

- Bạn có biết dùng đúng loại telemetry không

Trả lời ngắn:

Metrics là số liệu theo thời gian, tốt cho dashboard và alert. Logs là event chi tiết theo timestamp, tốt cho debug lỗi cụ thể. Traces cho thấy đường đi của một request qua nhiều service, tốt cho distributed debugging.

Follow-up:

- Ví dụ metrics cho W8 app?
- Khi nào dùng logs thay vì metrics?

### SLI là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu "đo cái gì" không

Trả lời ngắn:

SLI là Service Level Indicator, tức chỉ số đo hành vi service. Ví dụ availability SLI là successful requests chia cho total requests; latency SLI là tỷ lệ request thành công có latency dưới 500 ms.

Follow-up:

- SLI nên gắn với user impact hay resource usage?
- CPU có phải SLI tốt cho user-facing service không?

### SLO là gì?

Mentor muốn kiểm tra:

- Bạn có phân biệt target và measurement không

Trả lời ngắn:

SLO là Service Level Objective, mục tiêu mong muốn cho một SLI. Ví dụ availability SLO 99% trong 30 ngày, hoặc 95% request thành công có latency dưới 500 ms.

Follow-up:

- SLO khác SLA như thế nào?
- Vì sao không nên đặt SLO 100%?

### Error budget là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu cách SLO liên kết với release risk không

Trả lời ngắn:

Error budget là phần lỗi được phép trong SLO. Nếu availability SLO là 99%, error budget là 1%. Khi budget bị đốt quá nhanh, team nên giảm release rủi ro và ưu tiên ổn định.

Follow-up:

- Error budget giúp cân bằng giữa feature và reliability như thế nào?
- Nếu budget sắp hết thì có nên tiếp tục rollout lớn không?

### Burn rate là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu alert dựa trên tốc độ tiêu thụ error budget không

Trả lời ngắn:

Burn rate đo tốc độ service tiêu thụ error budget. Burn rate cao nghĩa là nếu tình trạng hiện tại tiếp tục, service sẽ nhanh chóng vi phạm SLO.

Follow-up:

- Vì sao burn-rate alert tốt hơn chỉ alert theo error rate cố định?
- Burn rate có liên quan gì đến canary abort?

### Vì sao cần multi-window burn-rate alert?

Mentor muốn kiểm tra:

- Bạn có hiểu fast burn và slow burn không

Trả lời ngắn:

Fast burn với cửa sổ ngắn như 5m và 1h bắt sự cố nghiêm trọng nhanh. Slow burn với cửa sổ dài như 30m và 6h bắt suy giảm kéo dài nhưng ít ồn ào hơn. Dùng cả hai để vừa nhanh vừa giảm false positive.

Follow-up:

- Fast page và slow ticket khác nhau thế nào?
- Vì sao không chỉ dùng cửa sổ 5 phút?

### OpenTelemetry SDK và Collector khác nhau thế nào?

Mentor muốn kiểm tra:

- Bạn có hiểu pipeline telemetry không

Trả lời ngắn:

SDK nằm trong application để instrument và tạo telemetry. Collector là thành phần nhận, xử lý, batch, enrich và export telemetry sang backend như Prometheus, logging backend hoặc tracing backend.

Follow-up:

- Receiver, processor, exporter là gì?
- Vì sao không cho app export trực tiếp đến tất cả backend?

### W9 OpenTelemetry flow đi như thế nào?

Mentor muốn kiểm tra:

- Bạn có gắn lý thuyết với repo không

Trả lời ngắn:

Flow là app instrumentation gửi OTLP đến Collector, Collector dùng receiver nhận telemetry, processor xử lý batch/memory, exporter đưa metrics ra endpoint Prometheus scrape, sau đó Grafana dashboard và alert rules dùng dữ liệu đó.

Follow-up:

- File config Collector nằm ở đâu?
- Prometheus lấy metrics bằng push hay scrape?

### Lỗi thường gặp khi làm observability là gì?

Mentor muốn kiểm tra:

- Bạn có biết tránh dashboard/alert kém giá trị không

Trả lời ngắn:

Lỗi thường gặp là tạo dashboard trước khi chọn SLI, alert theo CPU thay vì user impact, thiếu label nhất quán, dùng label cardinality cao, và xem logs là tín hiệu duy nhất.

Follow-up:

- Label nào có nguy cơ cardinality cao?
- Vì sao alert theo CPU không đủ để quyết định abort canary?

---

## 4. Prometheus, Grafana Và Loki

### Prometheus dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu vai trò Prometheus trong stack W9 không

Trả lời ngắn:

Prometheus là hệ thống thu thập, lưu trữ và truy vấn metrics. Nó scrape target theo interval, lưu time series với labels, dùng PromQL để tạo dashboard query và alert rules.

Follow-up:

- Target là gì?
- Scrape interval ảnh hưởng điều gì?

### PromQL `rate()` dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có đọc được query cơ bản không

Trả lời ngắn:

`rate()` tính tốc độ tăng trung bình mỗi giây của counter trong một time window. Ví dụ `rate(http_server_requests_total[5m])` cho request rate trong 5 phút gần nhất.

Follow-up:

- Vì sao counter nên dùng `rate()` thay vì lấy giá trị raw?
- `sum(rate(...))` khác gì `rate(...)` riêng từng series?

### Labels trong Prometheus có vai trò gì?

Mentor muốn kiểm tra:

- Bạn có hiểu cách lọc/nhóm metrics và rủi ro cardinality không

Trả lời ngắn:

Labels là metadata gắn với metric, giúp filter và group theo service, route, method, status code. Những label có giá trị không giới hạn như user ID, request ID hoặc full URL sẽ tạo high cardinality và làm Prometheus chậm/tốn tài nguyên.

Follow-up:

- Label nào nên có cho HTTP metrics?
- Vì sao full URL là label rủi ro?

### Grafana dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có hiểu Grafana không phải nơi sinh metrics không

Trả lời ngắn:

Grafana dùng để visualize dữ liệu từ datasource như Prometheus và Loki. Dashboard gồm nhiều panel, mỗi panel chạy query để hiển thị request rate, error rate, latency p95, availability SLI hoặc log trends.

Follow-up:

- Datasource là gì?
- Dashboard W9 nên có những panel nào?

### Loki dùng để làm gì?

Mentor muốn kiểm tra:

- Bạn có phân biệt log aggregation với metrics không

Trả lời ngắn:

Loki dùng để lưu và truy vấn logs, thường xem qua Grafana. Loki dùng labels để tìm log stream và LogQL để query, ví dụ tìm log lỗi của app theo label `app="announcement-app"`.

Follow-up:

- Loki có thay thế Prometheus không?
- Khi nào dùng LogQL thay PromQL?

### Metrics và logs nên dùng trong tình huống nào?

Mentor muốn kiểm tra:

- Bạn có chọn đúng tín hiệu cho đúng việc không

Trả lời ngắn:

Dùng metrics cho alert, trends, SLO và canary analysis. Dùng logs khi cần chi tiết lỗi, stack trace, request context hoặc bằng chứng debug sau khi metrics báo có vấn đề.

Follow-up:

- Canary auto-abort nên dựa vào metrics hay logs?
- Sau khi alert firing, logs giúp gì?

### PrometheusRule trong W9 có vai trò gì?

Mentor muốn kiểm tra:

- Bạn có biết alert rule trong repo dùng làm gì không

Trả lời ngắn:

PrometheusRule định nghĩa các alert dựa trên PromQL, đặc biệt là burn-rate alerts. Nó giúp phát hiện service đang tiêu thụ error budget quá nhanh và có thể làm tín hiệu cho dashboard/vận hành.

Follow-up:

- File burn-rate rule nằm ở đâu?
- Alert nên dựa vào availability hay CPU?

---

## 5. Progressive Delivery Và Canary

### Progressive delivery là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu release dần dần dựa trên tín hiệu không

Trả lời ngắn:

Progressive delivery là cách release thay đổi từng bước, mỗi bước quan sát metrics để quyết định tiếp tục, pause, promote hay abort. Các pattern gồm canary, blue-green, feature flags và traffic shadowing.

Follow-up:

- Progressive delivery khác rolling update bình thường thế nào?
- Tín hiệu nào nên dùng để quyết định tiếp tục?

### Canary release là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu giảm blast radius không

Trả lời ngắn:

Canary release đưa một phần nhỏ traffic hoặc replicas sang version mới trước. Nếu metrics tốt thì tăng dần exposure và promote. Nếu metrics xấu thì abort, giữ stable version phục vụ người dùng và điều tra version mới.

Follow-up:

- Canary giảm rủi ro như thế nào?
- Khi nào canary không đủ bảo vệ?

### Argo Rollouts khác Kubernetes Deployment ở điểm nào?

Mentor muốn kiểm tra:

- Bạn có hiểu lý do dùng CRD Rollout không

Trả lời ngắn:

Deployment hỗ trợ rollout cơ bản. Argo Rollouts mở rộng bằng strategy nâng cao như canary/blue-green, steps, pause, analysis, promotion và abort dựa trên metrics.

Follow-up:

- `Rollout` có thể thay thế `Deployment` trong lab không?
- Nếu thiếu Argo Rollouts CRD thì apply Rollout bị gì?

### Các resource chính của Argo Rollouts là gì?

Mentor muốn kiểm tra:

- Bạn có nắm object model không

Trả lời ngắn:

`Rollout` định nghĩa workload và strategy. `AnalysisTemplate` định nghĩa metric query và điều kiện thành công. `AnalysisRun` là một lần chạy cụ thể của analysis trong quá trình rollout.

Follow-up:

- `AnalysisRun` được tạo khi nào?
- `AnalysisTemplate` có thể tái sử dụng không?

### `setWeight`, `pause` và `analysis` trong canary steps có ý nghĩa gì?

Mentor muốn kiểm tra:

- Bạn có đọc được rollout strategy không

Trả lời ngắn:

`setWeight` đặt tỷ lệ exposure cho canary, `pause` dừng lại để quan sát metric hoặc đợi manual approval, `analysis` chạy metric check để quyết định có tiếp tục rollout hay không.

Follow-up:

- Nếu analysis fail thì rollout sẽ làm gì?
- Pause có thể manual hay timed không?

### AnalysisTemplate trong W9 kiểm tra gì?

Mentor muốn kiểm tra:

- Bạn có liên kết Argo Rollouts với Prometheus không

Trả lời ngắn:

AnalysisTemplate dùng provider Prometheus để query success rate. Nếu result đạt ngưỡng, ví dụ >= 0.99, rollout được tiếp tục. Nếu fail quá failure limit, canary bị abort.

Follow-up:

- Success rate tính từ metric nào?
- Vì sao success rate tốt hơn pod count cho auto-abort?

### Auto-abort là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu hành vi khi canary xấu không

Trả lời ngắn:

Auto-abort là việc rollout tự động dừng và quay về/giữ stable version khi analysis metric fail. Điều kiện abort nên dựa trên user-impact metrics như success rate, error ratio, latency p95/p99 hoặc SLO burn rate.

Follow-up:

- CPU cao có nên là điều kiện abort chính không?
- Sau khi abort cần làm gì?

### Vì sao metric canary phải đại diện user impact?

Mentor muốn kiểm tra:

- Bạn có tránh abort theo symptom yếu không

Trả lời ngắn:

Vì mục tiêu của rollout là bảo vệ người dùng. Pod count, CPU, memory chỉ là symptom hạ tầng; chúng không nói chắc request có thành công hay latency có đạt SLO không. Success rate, error ratio và latency gắn trực tiếp hơn với trải nghiệm người dùng.

Follow-up:

- Một canary CPU cao nhưng user vẫn ổn thì có nên abort ngay không?
- Một canary CPU bình thường nhưng 5xx tăng thì sao?

### W9 dùng traffic routing canary như production chưa?

Mentor muốn kiểm tra:

- Bạn có hiểu giới hạn lab không

Trả lời ngắn:

Chưa đầy đủ như production. Argo Rollouts có thể tích hợp ingress controller hoặc service mesh để split traffic thật, nhưng W9 starter dùng canary step model đơn giản để render/chạy local mà không bắt buộc Istio, NGINX, ALB controller hay traffic router.

Follow-up:

- Nếu lên production trên EKS, cần thêm thành phần nào để split traffic?
- Replica weight khác traffic weight như thế nào?

---

## 6. Load Testing Với k6

### Vì sao W9 cần load testing?

Mentor muốn kiểm tra:

- Bạn có hiểu load test trong lab không phải capacity test lớn không

Trả lời ngắn:

W9 dùng load testing để tạo traffic cho Prometheus/Grafana, kiểm tra health/readiness endpoints, quan sát error rate/latency threshold và tạo dữ liệu cho canary analysis. Mục tiêu là evidence và behavior validation, không phải capacity planning production.

Follow-up:

- Vì sao không nên bắn quá nhiều traffic vào minikube?
- Load test tạo dữ liệu gì cho dashboard?

### k6 VU là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu khái niệm test cơ bản không

Trả lời ngắn:

VU là virtual user, đại diện cho một user ảo lặp lại hành vi request trong kịch bản test. Ví dụ `vus: 5` nghĩa là có 5 virtual users chạy đồng thời.

Follow-up:

- VU khác request per second như thế nào?
- Duration ảnh hưởng kết quả như thế nào?

### k6 `check` và `threshold` khác nhau thế nào?

Mentor muốn kiểm tra:

- Bạn có hiểu assertion và pass/fail rule không

Trả lời ngắn:

`check` là assertion trên từng response, ví dụ status phải là 200. `threshold` là rule pass/fail trên metric tổng hợp, ví dụ `http_req_failed` phải dưới 1% hoặc p95 latency phải dưới 500 ms.

Follow-up:

- Nếu threshold fail thì CI nên xử lý thế nào?
- Check pass hết có đảm bảo threshold pass không?

### `http_req_failed: rate<0.01` có nghĩa là gì?

Mentor muốn kiểm tra:

- Bạn có đọc được k6 threshold không

Trả lời ngắn:

Nó có nghĩa là tỷ lệ request failed phải nhỏ hơn 1%. Nếu 1% request trở lên bị failed, test bị xem là không đạt.

Follow-up:

- Failed request được tính dựa trên gì?
- Threshold này liên quan gì đến availability SLI?

### `http_req_duration: p(95)<500` có nghĩa là gì?

Mentor muốn kiểm tra:

- Bạn có hiểu percentile latency không

Trả lời ngắn:

Nó có nghĩa là 95% request phải có thời gian phản hồi dưới 500 ms. Đây là một latency objective phù hợp để kiểm tra trải nghiệm phần lớn request.

Follow-up:

- p95 khác average latency thế nào?
- Vì sao average có thể che dấu lỗi latency?

### Sau khi chạy k6 cần chụp evidence nào?

Mentor muốn kiểm tra:

- Bạn có biết thu thập bằng chứng lab không

Trả lời ngắn:

Cần lưu tổng số request, failure rate, p95 latency, thời lượng test, endpoint test, BASE_URL, và trạng thái rollout lúc test là stable, canarying, promoted hay aborted.

Follow-up:

- Nếu k6 fail threshold thì ghi nhận như thế nào?
- Nên test endpoint `/`, `/healthz` hay `/readyz`?

---

## 7. Câu Hỏi Tình Huống Mentor Hay Hỏi

### Nếu Argo CD báo `OutOfSync`, em làm gì?

Mentor muốn kiểm tra:

- Bạn có debug theo luồng GitOps không

Trả lời ngắn:

Em kiểm tra diff trong Argo CD hoặc `kubectl describe application`, xác định live state khác Git ở đâu, xem có phải thay đổi tay hay manifest mới chưa sync không. Nếu desired state đúng thì sync/self-heal. Nếu Git sai thì sửa Git bằng commit mới.

Follow-up:

- Có nên sửa trực tiếp resource bằng `kubectl edit` không?
- Nếu OutOfSync do resource đã xóa khỏi Git thì `prune` làm gì?

### Nếu Argo CD `Synced` nhưng app không chạy, em debug thế nào?

Mentor muốn kiểm tra:

- Bạn có phân biệt config sync và runtime health không

Trả lời ngắn:

Em xem health status, `kubectl get pods,svc`, events, rollout/deployment status, pod logs, readiness/liveness probes và service endpoints. `Synced` chỉ nói manifest khớp Git, không đảm bảo pod runtime khỏe.

Follow-up:

- Cần xem namespace nào trong W9?
- Nếu pod CrashLoopBackOff thì xem gì trước?

### Nếu canary bị abort, em giải thích với mentor thế nào?

Mentor muốn kiểm tra:

- Bạn có hiểu auto-abort dựa trên metric không

Trả lời ngắn:

Em sẽ nói rollout đang bảo vệ stable version. AnalysisTemplate query Prometheus thấy metric không đạt success condition, ví dụ success rate dưới 0.99 hoặc latency/error xấu, nên Argo Rollouts abort canary và không promote version mới.

Follow-up:

- Làm sao chứng minh metric nào gây abort?
- Sau abort có cần revert Git không?

### Nếu Prometheus không có data, em debug theo thứ tự nào?

Mentor muốn kiểm tra:

- Bạn có hiểu scrape pipeline không

Trả lời ngắn:

Em kiểm tra target có được scrape không, endpoint metrics có reachable không, Service/ServiceMonitor hoặc scrape config có đúng label/namespace không, Collector có expose Prometheus exporter không, và app có tạo metrics hay chưa.

Follow-up:

- Scrape target down khác với query không ra data như thế nào?
- Label sai có thể làm dashboard trống như thế nào?

### Nếu dashboard Grafana trống nhưng Prometheus có data, em xem gì?

Mentor muốn kiểm tra:

- Bạn có debug dashboard query/datasource không

Trả lời ngắn:

Em kiểm tra datasource Prometheus trong Grafana, query của từng panel, biến dashboard, time range, label filter và metric name. Có data trong Prometheus nhưng dashboard trống thường do query/label/time range không khớp.

Follow-up:

- Time range quá ngắn có ảnh hưởng gì?
- Đổi label `service_name` có làm panel mất data không?

### Nếu k6 fail latency threshold, có nên rollback ngay không?

Mentor muốn kiểm tra:

- Bạn có suy nghĩ theo mức độ ảnh hưởng không

Trả lời ngắn:

Nếu đang trong canary và latency threshold đại diện SLO/user impact thì nên pause hoặc abort rollout để bảo vệ stable. Sau đó xem Prometheus, logs, resource usage và code change để tìm nguyên nhân. Nếu chỉ là local minikube overload thì cần ghi rõ giới hạn môi trường.

Follow-up:

- Làm sao phân biệt app lỗi và minikube bị quá tải?
- Threshold có nên giống production không?

### Nếu ai đó sửa cluster bằng tay khi Argo CD self-heal bật, điều gì xảy ra?

Mentor muốn kiểm tra:

- Bạn có hiểu drift correction không

Trả lời ngắn:

Argo CD sẽ phát hiện live state lệch Git và tự động đưa resource về lại desired state trong Git. Thay đổi bằng tay có thể bị ghi đè, nên workflow đúng là sửa manifest trong Git và merge.

Follow-up:

- Nếu thay đổi tay là fix khẩn cấp thì cần làm gì với Git?
- Self-heal có phải lúc nào cũng nên bật không?

---

## 8. Câu Hỏi Nhanh Để Luyện Vấn Đáp

1. GitOps là gì trong một câu?
2. Desired state và live state khác nhau thế nào?
3. Drift là gì và vì sao nguy hiểm?
4. `prune` khác `selfHeal` như thế nào?
5. `Synced` khác `Healthy` như thế nào?
6. App-of-apps giải quyết vấn đề nào?
7. Sync waves dùng khi nào?
8. Trong W9, wave 0/1/2 lần lượt là gì?
9. Vì sao rollback nên bằng `git revert`?
10. Khi nào `kubectl rollout undo` được chấp nhận?
11. CI nên làm gì trong GitOps workflow?
12. Argo CD làm gì sau khi merge?
13. Metrics, logs, traces khác nhau thế nào?
14. SLI là gì? Cho một ví dụ.
15. SLO là gì? Cho một ví dụ.
16. Error budget là gì?
17. Burn rate là gì?
18. Vì sao cần fast burn và slow burn?
19. OpenTelemetry SDK khác Collector thế nào?
20. Receiver, processor, exporter là gì?
21. Prometheus scrape hay app push metrics?
22. PromQL `rate()` dùng để làm gì?
23. Label cardinality cao nguy hiểm như thế nào?
24. Grafana datasource, dashboard, panel là gì?
25. Loki dùng khi nào?
26. Metrics hay logs phù hợp hơn cho alert?
27. Progressive delivery là gì?
28. Canary release giảm blast radius như thế nào?
29. Argo Rollouts khác Deployment thế nào?
30. `Rollout`, `AnalysisTemplate`, `AnalysisRun` là gì?
31. `setWeight`, `pause`, `analysis` trong rollout steps là gì?
32. Auto-abort là gì?
33. Metric nào tốt cho canary abort?
34. Vì sao CPU không nên là abort metric chính?
35. k6 VU là gì?
36. k6 threshold khác check như thế nào?
37. `http_req_failed: rate<0.01` nghĩa là gì?
38. `http_req_duration: p(95)<500` nghĩa là gì?
39. Evidence nào cần chụp sau k6 run?
40. Nếu Prometheus không có data, debug từ đâu?

---

## 9. Bộ Câu Trả Lời Siêu Ngắn

GitOps:

> Git chứa desired state, Argo CD reconcile cluster theo Git.

CI/CD boundary:

> CI validate trước merge, CD sync desired state sau merge.

Drift:

> Live cluster khác với Git.

Rollback:

> Ưu tiên `git revert`, chỉ `kubectl rollout undo` khi khẩn cấp và phải cập nhật Git sau.

Observability:

> Hiểu hành vi hệ thống qua metrics, logs và traces.

SLI/SLO:

> SLI là chỉ số đo; SLO là mục tiêu cho chỉ số đó.

Error budget:

> Phần lỗi được phép theo SLO.

Burn rate:

> Tốc độ tiêu thụ error budget.

Prometheus:

> Scrape metrics, lưu time series, query bằng PromQL và chạy alert rules.

Grafana:

> Hiển thị dashboard từ datasource như Prometheus/Loki.

Loki:

> Lưu và query logs bằng labels và LogQL.

Canary:

> Đưa version mới ra từng phần nhỏ, tốt thì promote, xấu thì abort.

Argo Rollouts:

> CRD mở rộng Deployment với canary steps, analysis và auto-abort.

k6:

> Tạo traffic, check response và fail test nếu thresholds về error/latency không đạt.
