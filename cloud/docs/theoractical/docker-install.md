# Docker Install

## Purpose

This note answers a practical question: is your machine actually ready to use Docker? If this step is unstable, most local W8-D2 and W8-D3 work will stall immediately.

## What To Remember

- On Windows and macOS, `Docker Desktop` is usually the right choice.
- On Linux, `Docker Engine` is usually the right choice.
- Docker must be stable before you try to start minikube.
- Verification should come from real commands, not from seeing the Docker UI open.
- A successful local image build is one of the best signals that the environment is usable.

## Minimum Verification Checklist

```powershell
docker version
docker info
docker run hello-world
```

If these commands are not working, stop there and fix Docker first.

## How It Applies to W8

Once Docker is verified:

```powershell
docker build -t w8-announcement-app:0.1.0 cloud/w8/day-2/app
```

Only after this succeeds should you continue to:
- `minikube image load`
- `kubectl apply -k cloud/w8/day-2/manifests`

## Common Failure Points

- Docker Desktop is installed but not running
- virtualization, WSL, or Hyper-V is not configured correctly on Windows
- the machine does not have enough CPU, RAM, or disk for local build and cluster work

## Self-Check

- Why is `docker run hello-world` more useful than just opening Docker Desktop?
- Why does an unstable Docker setup often cause minikube problems as well?
- What is the clearest sign that your machine is ready for W8-D2?

## Official Sources

- `https://docs.docker.com/get-docker`
