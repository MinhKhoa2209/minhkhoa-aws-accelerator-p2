import type { AppConfig } from "@/lib/config";

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────

export type MetricItem = {
  label: string;
  value: string;
  detail: string;
  icon: string;
};

export type ArchitectureStep = {
  number: string;
  title: string;
  subtitle: string;
  description: string;
  icon: string;
};

export type RunbookStep = {
  number: string;
  title: string;
  description: string;
  command: string;
};

export type EvidenceItem = {
  title: string;
  description: string;
};

export type StackTech = {
  name: string;
  role: string;
  icon: string;
};

// ─────────────────────────────────────────────
// Overview — readiness signals
// ─────────────────────────────────────────────

export const readinessSignals: MetricItem[] = [
  {
    label: "Runtime",
    value: "Kubernetes Pods",
    detail: "The app runs as containerised workloads inside a K8s namespace.",
    icon: "⎈"
  },
  {
    label: "Exposure",
    value: "AWS ALB",
    detail: "Public traffic enters exclusively through the Application Load Balancer.",
    icon: "☁"
  },
  {
    label: "Cluster",
    value: "Minikube on EC2",
    detail: "A single-node learning cluster bootstrapped by Terraform on EC2.",
    icon: "🖥"
  },
  {
    label: "Automation",
    value: "Terraform IaC",
    detail: "All cloud resources are declared and reproducible from source.",
    icon: "⚡"
  }
];

// ─────────────────────────────────────────────
// Overview — dynamic deployment metrics
// ─────────────────────────────────────────────

export function deploymentMetrics(config: AppConfig): MetricItem[] {
  return [
    {
      label: "Project",
      value: config.projectName,
      detail: "Used for resource names, IAM tags, and the app identity.",
      icon: "📦"
    },
    {
      label: "Region",
      value: config.awsRegion,
      detail: "AWS region where the ALB and EC2 host are provisioned.",
      icon: "🌏"
    },
    {
      label: "Cluster",
      value: config.clusterName,
      detail: "Local Kubernetes cluster spun up inside the EC2 host.",
      icon: "⎈"
    },
    {
      label: "NodePort",
      value: config.nodePort,
      detail: "Port targeted by ALB health checks and inbound user traffic.",
      icon: "🔌"
    }
  ];
}

// ─────────────────────────────────────────────
// Overview — technology stack
// ─────────────────────────────────────────────

export const stackTechnologies: StackTech[] = [
  { name: "Terraform", role: "Infrastructure as Code", icon: "⚡" },
  { name: "AWS ALB", role: "Load Balancer / Edge", icon: "☁" },
  { name: "Kubernetes", role: "Container Orchestration", icon: "⎈" },
  { name: "Docker", role: "Container Runtime", icon: "🐳" },
  { name: "Next.js", role: "React Framework", icon: "▲" },
  { name: "Nginx", role: "Static File Server", icon: "🌐" }
];

// ─────────────────────────────────────────────
// Architecture — traffic flow steps
// ─────────────────────────────────────────────

export const architectureSteps: ArchitectureStep[] = [
  {
    number: "01",
    title: "Internet",
    subtitle: "Public Request",
    description:
      "A browser opens the ALB DNS name. DNS resolves to the Load Balancer's public IP.",
    icon: "🌍"
  },
  {
    number: "02",
    title: "AWS ALB",
    subtitle: "Application Load Balancer",
    description:
      "HTTP traffic and /healthz probes are forwarded on port 80 to the registered EC2 target.",
    icon: "☁"
  },
  {
    number: "03",
    title: "EC2 Host",
    subtitle: "Virtual Machine",
    description:
      "Docker runs Minikube inside EC2. Minikube maps the K8s NodePort to the host network.",
    icon: "🖥"
  },
  {
    number: "04",
    title: "K8s Service",
    subtitle: "NodePort Service",
    description:
      "The NodePort Service routes inbound traffic across all healthy Next.js web Pods.",
    icon: "⎈"
  },
  {
    number: "05",
    title: "Next.js App",
    subtitle: "Nginx + Static Export",
    description:
      "Nginx serves the pre-built static Next.js site and responds to /healthz probes.",
    icon: "▲"
  }
];

// ─────────────────────────────────────────────
// Runbook — deployment steps
// ─────────────────────────────────────────────

export const runbookSteps: RunbookStep[] = [
  {
    number: "01",
    title: "Deploy the full stack",
    description:
      "Run the one-click PowerShell script from the project root. It executes Terraform and waits for ALB health.",
    command: ".\\deploy.ps1"
  },
  {
    number: "02",
    title: "Retrieve the public URL",
    description:
      "Use the Terraform output to get the ALB DNS name and open it in a browser.",
    command: "terraform output -raw alb_url"
  },
  {
    number: "03",
    title: "Verify ALB health probe",
    description:
      "The ALB and Kubernetes liveness probes expect this path to return 200 OK with body 'ok'.",
    command: "curl -v http://<alb-dns>/healthz"
  },
  {
    number: "04",
    title: "Inspect Kubernetes workloads",
    description:
      "SSH into the EC2 host and confirm all Pods are Running and the NodePort Service is exposed.",
    command: "kubectl get pods,svc -n k8s-project"
  },
  {
    number: "05",
    title: "Tear down resources",
    description:
      "After review, destroy all AWS resources to avoid ongoing charges.",
    command: ".\\destroy.ps1"
  }
];

// ─────────────────────────────────────────────
// Evidence — acceptance checklist
// ─────────────────────────────────────────────

export const evidenceItems: EvidenceItem[] = [
  {
    title: "One-command deploy",
    description:
      "The documented PowerShell script runs Terraform end-to-end and waits for ALB health to pass."
  },
  {
    title: "App runs in Kubernetes",
    description:
      "The container image is loaded into Minikube and rolled out as Pods in the k8s-project namespace."
  },
  {
    title: "Public access through ALB",
    description:
      "The browser accesses the app over HTTP using the Application Load Balancer DNS name."
  },
  {
    title: "AWS provider wiring",
    description:
      "All AWS resources (VPC, ALB, EC2, SG) are created by the Terraform AWS provider with proper tagging."
  },
  {
    title: "Reproducible from source",
    description:
      "The Docker image is built from staged source code during EC2 bootstrap via cloud-init."
  },
  {
    title: "Clean destroy path",
    description:
      "The destroy script cleanly removes all provisioned AWS resources to control cost post-review."
  }
];
