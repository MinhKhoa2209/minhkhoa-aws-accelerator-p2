# W10-D2 Evidence

Run date: 2026-06-16

Cluster context:

```text
minikube
```

AWS account and region:

```text
Account: 058114477594
Region: us-east-1
User: terraform-admin
```

## 1. AWS Secrets Manager

Created secret:

```text
Name: w10/announcement-app
ARN: arn:aws:secretsmanager:us-east-1:058114477594:secret:w10/announcement-app-XcJvk5
Initial ROTATION_VERSION: v1
Rotated ROTATION_VERSION: v2
```

## 2. External Secrets Operator

Installed by Helm:

```text
Release: external-secrets
Namespace: external-secrets
Status: deployed
```

Ready checks passed:

```text
deployment.apps/external-secrets condition met
deployment.apps/external-secrets-webhook condition met
deployment.apps/external-secrets-cert-controller condition met
```

Day-B ESO resources:

```text
secretstore.external-secrets.io/aws-secrets-manager   Valid          True
externalsecret.external-secrets.io/announcement-app-runtime   SecretSynced   True
secret/announcement-app-runtime   Opaque   2
secret/aws-credentials            Opaque   2
pod/secret-rotation-client-...    1/1 Running
```

Rotation result:

```text
ROTATION_VERSION=v1
ROTATION_VERSION=v2 elapsed=0s
```

After restarting the demo Deployment, the new pod received the rotated secret:

```text
ROTATION_VERSION=v2
```

Note: the first running pod kept `v1` because environment variables do not hot
reload inside an already-running process. Kubernetes Secret rotation succeeded;
the app process needed restart because the demo consumes the secret through env
vars.

## 3. Kyverno Image Signature Admission

Installed by Helm:

```text
Release: kyverno
Namespace: kyverno
Chart version: 3.8.1
Kyverno version: v1.18.1
```

Applied policy:

```text
clusterpolicy.kyverno.io/require-signed-ghcr-images created
```

Policy status:

```text
NAME                         ADMISSION   BACKGROUND   READY   MESSAGE
require-signed-ghcr-images   true        false        True    Ready
```

Unsigned image test:

```text
kubectl apply -f cloud\w10\day-b\signing\examples\unsigned-image.yaml
```

Result:

```text
Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request
resource Deployment/w10-supply-chain-lab/unsigned-image-demo was blocked
failed to verify image ghcr.io/minhkhoa2209/minhkhoa-aws-accelerator-p2/w8-announcement-app:unsigned-demo
```

This proves admission enforcement is active and blocks an image that cannot be
verified against the configured Sigstore/Kyverno policy.

## 4. Local Trivy Evidence

Trivy filesystem scan:

```text
trivy fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 cloud\w8\day-2
No issues detected.
```

Trivy image scan:

```text
docker build -t w10-day-b-local:w8-day-2 cloud\w8\day-2\app
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 w10-day-b-local:w8-day-2
```

Result:

```text
w10-day-b-local:w8-day-2 (alpine 3.24.1)   0 vulnerabilities
pip-25.0.1.dist-info/METADATA              0 vulnerabilities
```

## 5. CI Signing Evidence

GitHub Actions workflow:

```text
Workflow: trivy-cosign
Run: 27622430245
URL: https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2/actions/runs/27622430245
Commit: 460f4459ab46435d37bce8bfbdcc3901bdff9069
Status: success
```

The successful workflow completed:

- Trivy filesystem scan.
- Docker build from `cloud/w8/day-2/app`.
- Trivy image scan with `--severity HIGH,CRITICAL --ignore-unfixed --exit-code 1`.
- GHCR push.
- Cosign keyless signing with GitHub OIDC.

Published image:

```text
ghcr.io/minhkhoa2209/minhkhoa-aws-accelerator-p2/w8-announcement-app:460f4459ab46435d37bce8bfbdcc3901bdff9069
```

Cosign verification:

```text
Issuer: https://token.actions.githubusercontent.com
Subject: https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2/.github/workflows/trivy-cosign.yml@refs/heads/main
Digest: sha256:c083cb068552fa00d61f8cc686b0dab5654f80457cc4517cf6cd3f7edfc9d0f3
Transparency log: verified offline
```

Signed image admission test:

```text
kubectl apply -f cloud\w10\day-b\signing\examples\signed-image-template.yaml
deployment.apps/signed-image-demo created
```

Rollout result:

```text
deployment.apps/signed-image-demo   1/1   1   1
pod/signed-image-demo-...           1/1   Running   0
```

No CVE exception was required because local and CI Trivy scans did not report
HIGH or CRITICAL findings.

## 6. Tool Notes

Local tools:

```text
trivy: 0.69.3
cosign in PATH: 1.3.1
cosign verification used container: gcr.io/projectsigstore/cosign:v3.1.1
```

The workflow template for these steps is:

```text
cloud/w10/day-b/ci-trivy/trivy-cosign.yml
```
