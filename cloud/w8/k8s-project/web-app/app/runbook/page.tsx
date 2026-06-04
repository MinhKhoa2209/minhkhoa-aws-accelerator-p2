import type { Metadata } from "next";
import { RunbookStepCard } from "@/components/runbook-step";
import { runbookSteps } from "@/lib/content";

export const metadata: Metadata = {
  title: "Runbook",
  description:
    "Step-by-step commands to deploy, verify, and tear down the CloudScope AWS Kubernetes stack."
};

export default function RunbookPage() {
  return (
    <main className="flex flex-col gap-10">
      {/* Page title */}
      <section className="max-w-2xl">
        <span className="eyebrow">Runbook</span>
        <h1 className="mt-2 text-4xl font-black leading-tight text-slate-50">
          Deploy, verify &amp; clean up
        </h1>
        <p className="mt-4 text-base text-slate-400 leading-relaxed">
          Follow these steps to stand up the full AWS stack, validate every
          layer is healthy, and tear it down cleanly after review — all without
          touching application code or the EC2 host directly.
        </p>
      </section>

      {/* Steps */}
      <section
        aria-label="Deployment runbook"
        className="flex flex-col gap-4"
      >
        {runbookSteps.map((step) => (
          <RunbookStepCard key={step.number} step={step} />
        ))}
      </section>

      {/* Tip callout */}
      <aside className="rounded-xl border border-cyan-500/20 bg-cyan-500/5 p-5 flex items-start gap-4">
        <span className="text-2xl flex-shrink-0" aria-hidden="true">
          💡
        </span>
        <div>
          <h2 className="text-sm font-semibold text-cyan-300">Pro tip</h2>
          <p className="mt-1 text-sm text-slate-400 leading-relaxed">
            All steps can be run from the project root directory on Windows
            using PowerShell. The deploy and destroy scripts wrap Terraform so
            you don't need to run <code className="text-cyan-400">terraform init</code> manually.
          </p>
        </div>
      </aside>
    </main>
  );
}
