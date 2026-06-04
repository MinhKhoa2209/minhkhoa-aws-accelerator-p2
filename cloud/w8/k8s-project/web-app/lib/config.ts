export type AppConfig = {
  projectName: string;
  awsRegion: string;
  clusterName: string;
  nodePort: string;
};

export const appConfig: AppConfig = {
  projectName: process.env.NEXT_PUBLIC_PROJECT_NAME ?? "k8s-project",
  awsRegion: process.env.NEXT_PUBLIC_AWS_REGION ?? "ap-southeast-1",
  clusterName: process.env.NEXT_PUBLIC_CLUSTER_NAME ?? "minikube",
  nodePort: process.env.NEXT_PUBLIC_NODE_PORT ?? "30080"
};
