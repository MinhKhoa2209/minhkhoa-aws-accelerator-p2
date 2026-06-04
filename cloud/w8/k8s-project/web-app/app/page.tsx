import Link from "next/link";
import { MetricCard } from "@/components/metric-card";
import { StatusBadge } from "@/components/status-badge";
import { appConfig } from "@/lib/config";
import {
  readinessSignals,
  deploymentMetrics,
  stackTechnologies
} from "@/lib/content";

export default function OverviewPage() {
  const metrics = deploymentMetrics(appConfig);

  return (
    <main className="flex flex-col gap-14">
      {/* ── Hero ── */}
      <section className="relative overflow-hidden rounded-2xl border border-white/[0.07] bg-navy-800/50 p-8 sm:p-12">
        {/* Glow background */}
        <div
          className="pointer-events-none absolute inset-0 hero-glow"
          aria-hidden="true"
        />

        <div className="relative flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between">
          {/* Text */}
          <div className="max-w-2xl">
            <span className="eyebrow">AWS Kubernetes Deployment</span>
            <h1 className="mt-3 text-4xl font-black leading-tight tracking-tight text-slate-50 sm:text-5xl lg:text-6xl">
              CloudScope
              <span className="mt-1 block bg-gradient-to-r from-cyan-400 to-cyan-300 bg-clip-text text-transparent">
                Your Stack, Live.
              </span>
            </h1>
            <p className="mt-5 text-base text-slate-400 leading-relaxed sm:text-lg">
              A focused dashboard for cloud engineers and learners to verify
              their web experience is running in Kubernetes, exposed through
              the Application Load Balancer, and reproducible via Terraform.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/evidence" className="btn-primary">
                Review Evidence →
              </Link>
              <Link href="/architecture" className="btn-secondary">
                Trace Traffic Flow
              </Link>
            </div>
          </div>

          {/* Status */}
          <div className="flex flex-col items-start gap-3 lg:items-end">
            <StatusBadge label="All systems operational" tone="success" />
            <StatusBadge label="ALB health checks passing" tone="info" />
          </div>
        </div>
      </section>

      {/* ── Infrastructure signals ── */}
      <section aria-labelledby="signals-heading">
        <div className="mb-5 flex items-end justify-between gap-4">
          <div>
            <span className="eyebrow">Infrastructure</span>
            <h2
              id="signals-heading"
              className="mt-1 text-2xl font-bold text-slate-100"
            >
              Readiness signals
            </h2>
          </div>
          <StatusBadge label="Live" tone="success" />
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {readinessSignals.map((signal) => (
            <MetricCard key={signal.label} {...signal} />
          ))}
        </div>
      </section>

      {/* ── Deployment config ── */}
      <section aria-labelledby="config-heading">
        <div className="mb-5">
          <span className="eyebrow">Runtime snapshot</span>
          <h2
            id="config-heading"
            className="mt-1 text-2xl font-bold text-slate-100"
          >
            Current deployment config
          </h2>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {metrics.map((metric) => (
            <MetricCard key={metric.label} {...metric} />
          ))}
        </div>
      </section>

      {/* ── Technology stack ── */}
      <section aria-labelledby="stack-heading">
        <div className="mb-5">
          <span className="eyebrow">Technology stack</span>
          <h2
            id="stack-heading"
            className="mt-1 text-2xl font-bold text-slate-100"
          >
            Built with
          </h2>
        </div>
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
          {stackTechnologies.map((tech) => (
            <div
              key={tech.name}
              className="glass-card flex flex-col items-center gap-2 p-4 text-center"
            >
              <span className="text-2xl" aria-hidden="true">
                {tech.icon}
              </span>
              <p className="text-sm font-semibold text-slate-200">{tech.name}</p>
              <p className="text-xs text-slate-500">{tech.role}</p>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
