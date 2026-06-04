# W8 K8s Project: Kubernetes on AWS with Terraform

This project builds a one-node Kubernetes lab on AWS:

- Terraform creates the VPC, EC2 host, ALB, security groups, IAM role, and private artifact bucket.
- EC2 runs Docker and minikube.
- A static Next.js Cloud Launch Console runs as Pods inside Kubernetes.
- Internet traffic reaches the app through an AWS Application Load Balancer.

## Prerequisites

- AWS CLI credentials configured for an IAM user/role that can create EC2, VPC, ALB, IAM, and S3 resources.
- Terraform installed.
- PowerShell available for the provided deploy and destroy scripts.
- Optional local checks: Node.js, npm, Docker, and kubectl.

## One-Click Deploy

From repo:

```powershell
cd k8s-project
.\deploy.ps1
```

The script runs `terraform init`, `terraform apply -auto-approve`, prints the ALB URL, and waits until `/healthz` returns HTTP 200.

Open the final URL in a browser:

```powershell
terraform output -raw alb_url
```

## Destroy

```powershell
cd cloud\w8\k8s-project
.\destroy.ps1
```

The S3 artifact bucket uses `force_destroy = true`, so Terraform can remove staged files during destroy.

## Architecture

![Architecture Diagram](<architecture_diagram.png>)

## Terraform Provider Wiring

This repo wires multiple Terraform providers in one configuration:

- `hashicorp/aws`: creates VPC, subnets, ALB, EC2, IAM, S3 artifact staging, and security groups.
- `hashicorp/cloudinit`: renders the EC2 bootstrap script as multipart cloud-init user data.

The wiring happens through `aws_instance.user_data`:

```hcl
data "cloudinit_config" "minikube" {
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/user_data.sh.tpl", ...)
  }
}

module "ec2_web" {
  user_data = data.cloudinit_config.minikube.rendered
}
```

Terraform first uploads `web-app/` and `k8s/` files to the private artifact bucket, then creates EC2 with an IAM instance profile that can read those objects. Cloud-init downloads the files, builds the Next.js static Docker image, starts minikube with `--driver=docker --ports=30080:30080`, loads the image into minikube, and applies the Kubernetes manifests.

## Key Files

```text
k8s-project/
  web-app/             Next.js source and Dockerfile
  k8s/                 Namespace, Deployment, NodePort Service
  modules/             VPC, EC2, security group modules
  main.tf              ALB, EC2 wiring, artifact bucket, IAM, cloud-init
  user_data.sh.tpl     EC2 bootstrap for Docker + minikube + kubectl
  deploy.ps1           One-click deploy
  destroy.ps1          Clean destroy
```

## Optional Checks

Static checks:

```powershell
terraform fmt -recursive
terraform validate
```

Local app build checks:

```powershell
cd web-app
npm install
npm run build
docker build -t k8s-project-next:0.1.0 .
```

The image tag `k8s-project-next:0.1.0` matches the Next.js app source and is loaded into minikube by the existing EC2 bootstrap flow.

After deploy, if SSH is enabled with `allowed_ssh_cidrs`, verify Kubernetes on EC2:

```bash
kubectl get pods,svc -n k8s-project
curl http://127.0.0.1:30080/healthz
```

## Variables

Defaults are in `terraform.tfvars.example`.

- `instance_type`: defaults to `t3.small`; use `t3.medium` if minikube startup needs more headroom.
- `root_volume_size`: defaults to `30` GB for Docker images and the minikube node.
- `node_port`: defaults to `30080`.
- `allowed_web_cidrs`: defaults to `0.0.0.0/0` for public ALB access.
- `allowed_ssh_cidrs`: defaults to `[]`, so SSH ingress is disabled unless explicitly enabled.
- `key_name`: optional EC2 key pair name for SSH.

## Evidence To Submit

- The repo code.
- Evidence screenshots in `evidence/`.
- Short explanation of the provider wiring and the ALB -> EC2 NodePort -> minikube Service path.

Current evidence files:

```text
evidence/
  alb-browser-home.png             Browser opens the app through the ALB DNS.
  terraform-apply-success.png      One-click deploy completed and health check became ready.
  kubernetes-pods-service.png      App is running as Kubernetes Pods with a NodePort Service.
  terraform-plan-no-changes.png    Re-running Terraform shows the stack is reproducible.
  terraform-destroy-success.png    Terraform destroy completed after grading/evidence capture.
```

Optional extra evidence: capture `http://<alb-dns>/healthz` returning `ok`. The existing deploy screenshot already proves `/healthz` became healthy, but a dedicated screenshot is useful if the trainer wants direct browser evidence.
