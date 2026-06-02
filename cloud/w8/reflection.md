# W8 Reflection

## W8-D1 — 01/06/2026

### Muc tieu

- dung repo portfolio cho Phase 2
- nam duoc overview cua Infrastructure as Code
- viet va doc duoc HCL syntax co ban

### Evidence da hoan thanh

- tao structure repo dung format mentor yeu cau
- viet note tong hop cho W8-D1 trong `cloud/w8/day-1/README.md`
- tao sandbox Terraform co `variable`, `locals`, `outputs`, validation va `for` expression

### Dieu da hoc

- Terraform mo ta desired state va so sanh voi current state de tinh ra execution plan
- HCL co cu phap de doc hon JSON, phu hop cho human review trong Git
- `locals` giup giam lap expression, `outputs` giup quan sat gia tri tinh toan
- state la thanh phan quan trong va can duoc quan ly can than o cac bai production sau

### Khoang trong can hoc tiep

- `init`, `plan`, `apply`, `destroy` theo workflow day du
- local state vs remote state
- module structure va convention cho production

### Ke hoach ngay tiep theo

- hoc sau hon ve workflow va state
- neu co Terraform local, chay `fmt`, `init -backend=false`, `validate`, `console` tren thu muc `cloud/w8/day-1/terraform-basics`
- bat dau note them cho W8-D2 sau buoi live Terraform ngay 02/06/2026

## W8-D2 — 02/06/2026

### Muc tieu

- cuong co them workflow Terraform, state, module va best practices
- chuan bi artifact Kubernetes foundation cho buoi container/orchestration
- bo sung evidence cho portfolio truoc khi push repo

### Evidence da hoan thanh

- bo sung module `portfolio_summary` cho sandbox Terraform va noi output len root module
- cap nhat note W8-D1 de cover workflow, state management, module composition va best practices
- tao app Python + Dockerfile + manifest Kubernetes trong `cloud/w8/day-2/`

### Dieu da hoc

- `terraform init -backend=false` hop voi sandbox provider-free de hoc ngon nguoc va module wiring
- module giup tach logic va output ro rang hon truoc khi dung resource that
- Kubernetes can tach config thuong (`ConfigMap`) va gia tri nhay cam (`Secret`), dong thoi dung probes de the hien trang thai app

### Khoang trong can hoc tiep

- chay full `plan/apply/destroy` voi provider that o bai sau
- deploy thu tren minikube de quan sat pod lifecycle, service routing va network policy
- mo rong sang scaling/networking va lab platform cho W8-D3/T5-T6
