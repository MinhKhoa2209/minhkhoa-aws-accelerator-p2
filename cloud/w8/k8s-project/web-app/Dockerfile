FROM node:20-alpine AS build

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_PROJECT_NAME=k8s-project
ENV NEXT_PUBLIC_AWS_REGION=ap-southeast-1
ENV NEXT_PUBLIC_CLUSTER_NAME=minikube
ENV NEXT_PUBLIC_NODE_PORT=30080
ENV KEEP_NEXT_OUTPUT=1

COPY package.json package-lock.json ./
RUN npm ci

COPY next.config.mjs ./
COPY tsconfig.json ./
COPY next-env.d.ts ./
COPY postcss.config.mjs ./
COPY tailwind.config.ts ./
COPY scripts ./scripts
COPY app ./app
COPY components ./components
COPY lib ./lib
COPY public ./public

RUN npm run build

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/out /usr/share/nginx/html

EXPOSE 80
