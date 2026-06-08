# W9-D1 - GitOps & CI/CD Handbook

## Mục Tiêu Ngày 1

Sau D1, bạn cần nắm được:

- GitOps là gì và vì sao Git là desired state.
- GitHub Actions nên làm gì trong GitOps workflow.
- Argo CD hoạt động như thế nào trong Kubernetes.
- Argo CD khác Flux ở điểm nào.
- App-of-apps và sync waves dùng khi nào.
- Rollback đúng GitOps khác `kubectl rollout undo` như thế nào.
- Cần làm gì trong repo W9 để GitOps-ify W8 platform.

## Kết Quả Cần Đạt

Cuối D1, repo nên có:

- GitHub Actions workflow validate manifest.
- Argo CD root Application.
- Argo CD child Applications cho platform, observability, rollout.
- Các W9 kustomize overlays render được.
- Ghi chú ngắn trong reflection về workflow mới.

Liên quan trong repo:

```text
cloud/w9/day-a/
  .github/workflows/k8s-validate.yml
  argocd/
    app-of-apps.yaml
    w8-platform-app.yaml
    w9-observability-app.yaml
    w9-rollout-app.yaml
```

---

## 1. GitOps Là Gì?

GitOps là cách vận hành hệ thống bằng Git. Tất cả desired state của hệ thống được khai báo trong Git, sau đó một controller trong cluster tự động đồng bộ live state theo Git.

### Traditional CI/CD

```text
Developer
  -> Git Repository
  -> CI Pipeline
  -> kubectl apply / helm upgrade
  -> Kubernetes Cluster
```

Vấn đề:

- Ai có quyền pipeline hoặc kubeconfig có thể thay đổi cluster.
- Cluster có thể khác với Git.
- Khó audit ai đã apply thay đổi nào.
- Rollback phụ thuộc vào thao tác thủ công.
- Khó khôi phục cluster mới nếu không biết live state hiện tại.

### GitOps

```text
Developer
  -> Pull Request
  -> Review
  -> Merge to Git
  -> Argo CD / Flux reconcile
  -> Kubernetes Cluster
```

Nguyên tắc:

- Cấu hình hệ thống nằm trong Git.
- Git là single source of truth.
- Thay đổi đi qua PR và review.
- Controller liên tục so sánh Git với cluster.
- Drift được phát hiện và có thể tự sửa.
- Rollback ưu tiên bằng Git revert.

## 2. Desired State, Live State, Drift

Desired state là trạng thái mong muốn được khai báo trong Git.

Ví dụ:

```yaml
replicas: 2
image: w8-announcement-app:0.1.0
```

Live state là trạng thái thật đang chạy trong cluster.

Drift xảy ra khi live state khác desired state.

Ví dụ:

```powershell
kubectl scale deployment announcement-app -n w8-day-2 --replicas=5
```

Nếu Git vẫn khai báo `replicas: 2`, Argo CD sẽ thấy ứng dụng `OutOfSync`.

## 3. CI/CD Trong GitOps

### CI Nên Làm Gì?

CI trả lời câu hỏi: "Thay đổi này có đủ an toàn để merge không?"

Trong W9, CI nên:

- render kustomize overlays
- validate YAML
- chạy test nếu có
- build image nếu thay đổi app
- scan cơ bản nếu có tool
- báo lỗi ngay trên PR

Ví dụ workflow trong repo:

```text
cloud/w9/day-a/.github/workflows/k8s-validate.yml
```

Workflow này render:

- `cloud/w8/day-2/manifests`
- `cloud/w9/lab/platform`
- `cloud/w9/lab/observability`
- `cloud/w9/lab/rollout`

### CD Nên Làm Gì?

Trong GitOps, CD không nên là laptop chạy `kubectl apply`.

CD nên là:

```text
Git changed
  -> Argo CD detects new commit
  -> Argo CD renders manifests
  -> Argo CD applies desired state
  -> Argo CD reports sync and health
```

## 4. Plan-on-PR Và Apply-on-Merge

Pattern production thường gặp:

```text
Pull Request
  -> plan / validate / test
  -> review
  -> merge
  -> apply / sync
```

Với Terraform:

- PR chạy `terraform plan`.
- Merge mới được `terraform apply`.

Với Kubernetes GitOps:

- PR chạy render/validate manifests.
- Merge làm Argo CD sync.

Trong W9:

```text
PR
  -> GitHub Actions render kustomize
  -> Merge
  -> Argo CD sync app-of-apps
```

## 5. GitHub Actions Cần Biết

Một workflow có các thành phần chính:

- `name`: tên workflow.
- `on`: event kích hoạt workflow, ví dụ `pull_request`, `push`.
- `jobs`: danh sách job.
- `runs-on`: runner, ví dụ `ubuntu-latest`.
- `steps`: các bước trong job.
- `uses`: dùng action có sẵn.
- `run`: chạy command shell.

Ví dụ rút gọn:

```yaml
name: k8s-validate

on:
  pull_request:
    paths:
      - "cloud/w9/**"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - run: kubectl kustomize cloud/w9/lab/platform
```

Cần hiểu:

- Workflow trên PR chỉ validate, chưa deploy.
- Workflow trên merge có thể build image hoặc update manifest.
- Argo CD mới là thành phần sync cluster.

## 6. Argo CD

Argo CD là GitOps controller chạy trong Kubernetes. Nó watch Git repo, render manifest, so sánh với cluster, và sync live state theo desired state.

### Luồng Hoạt Động

```text
Git repo path
  -> Argo CD Application
  -> Kubernetes API
  -> Namespace/resources
```

### Trạng Thái Quan Trọng

`Synced`:

```text
Git state == cluster state
```

`OutOfSync`:

```text
Git state != cluster state
```

`Healthy`:

```text
Resource đang chạy tốt theo health check của Argo CD
```

`Degraded`:

```text
Resource có vấn đề, ví dụ pod CrashLoopBackOff hoặc rollout failed
```

## 7. Argo CD Application Anatomy

Một `Application` có 4 phần quan trọng:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: w8-platform
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/OWNER/REPO.git
    targetRevision: HEAD
    path: cloud/w9/lab/platform
  destination:
    server: https://kubernetes.default.svc
    namespace: w8-day-2
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Cần nhớ:

- `repoURL`: repo Git chứa manifests.
- `targetRevision`: branch, tag, hoặc commit.
- `path`: folder manifest/kustomize trong repo.
- `destination.server`: cluster đích.
- `destination.namespace`: namespace đích.
- `prune`: xóa resource đã bị xóa khỏi Git.
- `selfHeal`: sửa drift khi live state bị đổi thủ công.

## 8. App-of-Apps Pattern

Việc tạo từng Application bằng tay không scale tốt.

App-of-apps dùng một root app để quản lý các child apps:

```text
w9-root
  -> w8-platform
  -> w9-observability
  -> w9-rollout
```

Trong repo:

```text
cloud/w9/day-a/argocd/app-of-apps.yaml
```

Root app đọc các child app YAML trong cùng folder `argocd`.

Lợi ích:

- Bootstrap nhanh.
- Một entry point cho cả platform.
- Child apps cũng được version trong Git.
- Dễ thêm app mới sau này.

## 9. Sync Waves

Sync waves dùng để sắp xếp thứ tự apply.

Ví dụ:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

Quy tắc:

- wave số nhỏ sync trước
- mặc định là wave `0`
- dùng khi có dependency giữa resource/app

Trong W9:

```text
wave 0: w8-platform
wave 1: w9-observability
wave 2: w9-rollout
```

Lý do:

- Platform tạo namespace, config, secret, service.
- Observability tạo metric/alert resources.
- Rollout cần platform và Prometheus analysis.

## 10. Argo CD vs Flux

| Tiêu chí | Argo CD | Flux |
|---|---|---|
| UI | Có UI mạnh | Chủ yếu CLI/Git-first |
| Dễ demo | Rất tốt | Tốt nhưng ít trực quan hơn |
| App-of-apps | Phổ biến | Có thể làm bằng Kustomization/HelmRelease |
| Multi-cluster | Hỗ trợ tốt | Hỗ trợ tốt |
| Learning curve | Dễ tiếp cận cho người mới | Cần quen GitOps controller model hơn |
| CNCF | Graduated | Graduated |

Dùng Argo CD khi:

- cần UI để học và demo
- team mới làm GitOps
- muốn nhìn sync/health trực quan

Dùng Flux khi:

- muốn Git-first, nhẹ, automation cao
- team quen Kubernetes controllers
- không cần UI mạnh

## 11. Rollback Trong GitOps

### Cách Khuyến Nghị: Git Revert

```powershell
git revert <bad-commit>
git push
```

Sau đó:

```text
Argo CD sees new commit
  -> sync
  -> cluster quay về desired state trước đó
```

Ưu điểm:

- đúng GitOps
- có audit trail
- cluster và Git không bị lệch
- reviewer thấy rollback commit

### Cách Khẩn Cấp: kubectl rollout undo

```powershell
kubectl rollout undo deployment/announcement-app -n w8-day-2
```

Nhanh, nhưng có rủi ro:

```text
Cluster đã rollback
Git vẫn đang là version lỗi
Argo CD có thể sync lại version lỗi
```

Nếu phải dùng `kubectl rollout undo`, cần fix Git ngay sau đó.

## 12. W9 D1 Hands-On Checklist

### Đọc Và Hiểu

- [ ] GitOps principles.
- [ ] Argo CD Application.
- [ ] Argo CD app-of-apps.
- [ ] Sync waves.
- [ ] GitHub Actions workflow basics.
- [ ] Argo CD vs Flux.
- [ ] Rollback: `git revert` vs `kubectl rollout undo`.

### Làm Trong Repo

- [ ] Update `repoURL` trong các file:
  - `cloud/w9/day-a/argocd/app-of-apps.yaml`
  - `cloud/w9/day-a/argocd/w8-platform-app.yaml`
  - `cloud/w9/day-a/argocd/w9-observability-app.yaml`
  - `cloud/w9/day-a/argocd/w9-rollout-app.yaml`
- [ ] Render W9 overlays:

```powershell
kubectl kustomize cloud\w9\lab\platform
kubectl kustomize cloud\w9\lab\observability
kubectl kustomize cloud\w9\lab\rollout
```

- [ ] Review workflow:

```text
cloud/w9/day-a/.github/workflows/k8s-validate.yml
```

- [ ] Install Argo CD nếu làm lab trên minikube.
- [ ] Apply root app.
- [ ] Xác nhận child apps được tạo.

## 13. Lệnh Thực Hành

### Install Argo CD

```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=180s
```

### Apply Root App

```powershell
kubectl apply -f cloud\w9\day-a\argocd\app-of-apps.yaml
```

### Check Applications

```powershell
kubectl get applications -n argocd
kubectl describe application w9-root -n argocd
```

### Check W8 Platform Resources

```powershell
kubectl get all -n w8-day-2
kubectl get configmap,secret,networkpolicy -n w8-day-2
```

### Detect Drift Test

Nếu muốn test self-heal:

```powershell
kubectl scale rollout announcement-app -n w8-day-2 --replicas=3
kubectl get applications -n argocd
```

Nếu Argo CD self-heal bật, nó sẽ đưa live state về Git.

## 14. Evidence Cần Chụp

Cần lưu evidence cho D1:

- Argo CD apps list: `w9-root`, `w8-platform`, `w9-observability`, `w9-rollout`.
- Sync status: `Synced`.
- Health status: `Healthy` nếu dependencies đã đủ.
- `kubectl get all -n w8-day-2`.
- Kết quả render kustomize overlays.
- Ghi chú ngắn: trước W9 apply tay, sau W9 Git là desired state.

Gợi ý lưu:

```text
cloud/w9/lab/evidence/
```

## 15. Lỗi Thường Gặp

`repoURL` còn `CHANGE-ME`:

- Argo CD không clone được repo.
- Sửa thành URL repo thật.

Sai `path`:

- Argo CD báo manifest generation error.
- Kiểm tra folder có `kustomization.yaml` hoặc YAML hợp lệ.

Thiếu CRD:

- `Application` không apply được nếu Argo CD chưa cài.
- `Rollout` không apply được nếu Argo Rollouts chưa cài.

Dùng `kubectl apply` để sửa app:

- Tạo drift.
- Nên commit thay đổi vào Git.

Secret hardcoded:

- Chấp nhận cho lab học tập.
- Không chấp nhận cho production.
- Production nên dùng External Secrets, Sealed Secrets, SOPS, hoặc cloud secret manager.

## 16. Câu Hỏi Tự Kiểm Tra

- GitOps khác CI/CD truyền thống ở điểm nào?
- Desired state nằm ở đâu?
- Live state nằm ở đâu?
- Drift là gì?
- Argo CD `Synced` khác `Healthy` như thế nào?
- `prune` và `selfHeal` có tác dụng gì?
- App-of-apps giải quyết vấn đề nào?
- Sync wave dùng khi nào?
- Vì sao `git revert` tốt hơn `kubectl rollout undo` trong GitOps?
- Trong W9, CI làm gì và Argo CD làm gì?

## 17. Câu Trả Lời Ngắn Để Vấn Đáp

GitOps là gì?

> GitOps là mô hình vận hành trong đó Git chứa desired state, còn controller như Argo CD tự động đồng bộ cluster theo Git.

Vì sao không apply tay?

> Apply tay làm cluster lệch Git, khó audit, khó rollback và có nguy cơ bị Argo CD sync ngược lại.

Argo CD khác Jenkins thế nào?

> Jenkins thường dùng cho CI/build/test. Argo CD là GitOps CD controller chạy trong cluster và sync desired state từ Git.

App-of-apps dùng để làm gì?

> Để một root Application quản lý nhiều child Applications, giúp bootstrap và quản lý platform tập trung.

Rollback chuẩn trong GitOps là gì?

> `git revert` commit lỗi, push lên Git, để Argo CD sync cluster về desired state mới.

## Official Sources

- Argo CD Docs: https://argo-cd.readthedocs.io
- GitHub Actions Docs: https://docs.github.com/en/actions
- Flux Docs: https://fluxcd.io/flux
- OpenGitOps Principles: https://opengitops.dev
