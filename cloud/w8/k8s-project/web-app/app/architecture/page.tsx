import type { Metadata } from "next";
import { FlowStep } from "@/components/flow-step";
import { architectureSteps } from "@/lib/content";

export const metadata: Metadata = {
  title: "Architecture",
  description:
    "How internet traffic flows from the ALB through EC2, Kubernetes, and into the Next.js app."
};

export default function ArchitecturePage() {
  return (
    <main className="flex flex-col gap-10">
      {/* Page title */}
      <section className="max-w-2xl">
        <span className="eyebrow">Architecture</span>
        <h1 className="mt-2 text-4xl font-black leading-tight text-slate-50">
          Traffic flow end-to-end
        </h1>
        <p className="mt-4 text-base text-slate-400 leading-relaxed">
          From a browser request to an Nginx-served page — follow every hop
          through the AWS Application Load Balancer, EC2 host, Kubernetes
          NodePort Service, and into the containerised Next.js application.
        </p>
      </section>

      {/* Flow diagram */}
      <section aria-label="Architecture topology" className="flex flex-col gap-0">
        <div className="grid grid-cols-1 gap-0 sm:grid-cols-1 lg:grid-cols-5 lg:gap-4 lg:items-start">
          {architectureSteps.map((step, i) => (
            <FlowStep
              key={step.number}
              step={step}
              isLast={i === architectureSteps.length - 1}
            />
          ))}
        </div>
      </section>

      {/* Layer summary */}
      <section aria-labelledby="layers-heading">
        <div className="mb-5">
          <span className="eyebrow">Layer breakdown</span>
          <h2
            id="layers-heading"
            className="mt-1 text-2xl font-bold text-slate-100"
          >
            What each layer does
          </h2>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {[
            {
              title: "AWS Application Load Balancer",
              detail:
                "Terminates HTTP connections, performs health probes on /healthz at regular intervals, and forwards valid traffic to the registered EC2 target on port 30080."
            },
            {
              title: "EC2 Instance (Terraform-provisioned)",
              detail:
                "A t3.small instance bootstrapped by cloud-init. It installs Docker, starts Minikube inside Docker, builds the app image, and applies K8s manifests."
            },
            {
              title: "Minikube Kubernetes Cluster",
              detail:
                "A single-node cluster running inside Docker on EC2. Hosts the k8s-project namespace with a Deployment and NodePort Service exposing port 30080."
            },
            {
              title: "Next.js + Nginx Pods",
              detail:
                "The app image contains a pre-built static Next.js export served by Nginx on port 80. Nginx also handles the /healthz route, returning 'ok'."
            }
          ].map((layer) => (
            <article key={layer.title} className="glass-card p-5">
              <h3 className="font-semibold text-slate-100 text-sm">
                {layer.title}
              </h3>
              <p className="mt-2 text-sm text-slate-400 leading-relaxed">
                {layer.detail}
              </p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
