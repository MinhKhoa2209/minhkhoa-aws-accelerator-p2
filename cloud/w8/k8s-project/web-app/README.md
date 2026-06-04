# Cloud Launch Console

This folder contains the app that is built into the Kubernetes image contract
`k8s-project-next:0.1.0`. The source is a static-export Next.js App Router
project served by Nginx in the final Docker image.

## Local Commands

```powershell
npm install
npm run build
docker build -t k8s-project-next:0.1.0 .
```

`npm run build` validates the static export and then removes local `.next/` and
`out/` artifacts so Terraform does not stage generated build output by accident.
The Dockerfile sets `KEEP_NEXT_OUTPUT=1`, so the same build command keeps `out/`
inside the Docker build stage for Nginx.

For local development:

```powershell
npm run dev
```

## Environment Variables

The Dockerfile provides defaults, so the EC2 bootstrap can build without extra
arguments:

- `NEXT_PUBLIC_PROJECT_NAME`
- `NEXT_PUBLIC_AWS_REGION`
- `NEXT_PUBLIC_CLUSTER_NAME`
- `NEXT_PUBLIC_NODE_PORT`

## Deployment Contract

- Container listens on port `80`.
- `/healthz` is exported from `public/healthz` and returns `ok`.
- Static pages are emitted to `out/` and copied into Nginx.
- Terraform and Kubernetes manifests are not required to change for this app
  refactor.

## Structure

```text
app/
  app/                 App Router pages, layouts, loading/error states
  components/          Reusable UI blocks
  lib/                 Environment config and typed content
  public/healthz       ALB and Kubernetes health endpoint
  scripts/             Local build cleanup helpers
  Dockerfile           Next.js static export + Nginx runtime image
```
