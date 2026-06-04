#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/k8s-project-bootstrap.log | logger -t k8s-project-bootstrap -s 2>/dev/console) 2>&1

PROJECT_DIR="/opt/k8s-project"
IMAGE="${image_name}:${image_tag}"

dnf update -y
dnf install -y awscli docker git tar gzip

systemctl enable --now docker
usermod -aG docker ec2-user

curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl"
chmod 0755 /usr/local/bin/kubectl

curl -fsSLo /usr/local/bin/minikube "https://storage.googleapis.com/minikube/releases/${minikube_version}/minikube-linux-amd64"
chmod 0755 /usr/local/bin/minikube

rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
aws s3 sync "s3://${artifact_bucket}/${artifact_prefix}" "$PROJECT_DIR" --region "${aws_region}"
chown -R ec2-user:ec2-user "$PROJECT_DIR"

docker build --pull -t "$IMAGE" "$PROJECT_DIR/web-app"

sudo -iu ec2-user bash -lc "minikube start --driver=docker --ports=${node_port}:${node_port} --kubernetes-version=${kubectl_version}"
sudo -iu ec2-user bash -lc "minikube image load $IMAGE"

sed -i "s|image: k8s-project-next:0.1.0|image: $IMAGE|g" "$PROJECT_DIR/k8s/deployment.yaml"

sudo -iu ec2-user bash -lc "kubectl apply -k $PROJECT_DIR/k8s"
sudo -iu ec2-user bash -lc "kubectl rollout status deployment/k8s-project-web -n k8s-project --timeout=300s"

for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${node_port}/healthz"; then
    echo "Application is healthy on NodePort ${node_port}"
    exit 0
  fi
  sleep 10
done

echo "Application did not become healthy on NodePort ${node_port}" >&2
exit 1
