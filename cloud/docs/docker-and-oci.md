# Docker and OCI

## Purpose

This note clarifies the concepts beginners confuse most often: `image`, `container`, `Docker`, and `OCI`.

## What To Remember

- An `image` is the packaged application artifact.
- A `container` is a running instance of an image.
- Docker is a widely used toolchain for building, shipping, and running containers.
- OCI is the open standard that keeps image formats from being tied to one implementation.
- Before you can deploy to Kubernetes, you need a valid image.

## How To Think About It

- Changing source code does not automatically change a running container.
- After changing application code, you must rebuild the image.
- A Kubernetes pod ultimately runs one or more container images.
- Docker is a practical build and runtime toolchain. OCI explains why the image model is standardized across tools.

## How It Applies to W8

- `cloud/w8/day-2/app/server.py`
  - the application code
- `cloud/w8/day-2/app/Dockerfile`
  - the packaging definition for the image
- `cloud/w8/day-2/manifests/deployment.yaml`
  - where that image is referenced by Kubernetes

## Lab Discipline To Keep

- change code -> rebuild image
- build locally -> load the image into minikube if needed
- use clear tags instead of relying on `latest`

## Self-Check

- What is the difference between an `image` and a `container`?
- Why can Kubernetes keep running an old version after you edit the source code?
- Even if you never read the full OCI spec, why is the concept still useful?

## Official Sources

- `https://docs.docker.com`
- `https://github.com/opencontainers/image-spec`
