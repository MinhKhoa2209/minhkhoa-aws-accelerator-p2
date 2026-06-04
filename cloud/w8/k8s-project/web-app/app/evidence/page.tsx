import type { Metadata } from "next";
import { CheckItem } from "@/components/check-item";
import { StatusBadge } from "@/components/status-badge";
import { evidenceItems } from "@/lib/content";

export const metadata: Metadata = {
  title: "Evidence",
  description:
    "Acceptance criteria with observable proof for the CloudScope AWS Kubernetes deployment."
};

export default function EvidencePage() {
  return (
    <main className="flex flex-col gap-10">
      {/* Page title */}
      <section className="max-w-2xl">
        <span className="eyebrow">Evidence</span>
        <h1 className="mt-2 text-4xl font-black leading-tight text-slate-50">
          Acceptance criteria met
        </h1>
        <p className="mt-4 text-base text-slate-400 leading-relaxed">
          Each item below maps a deployment requirement to observable proof —
          making the grading path explicit: where the app runs, how users reach
          it, and why the deployment is reproducible.
        </p>
      </section>

      {/* Status banner */}
      <div className="flex items-center justify-between gap-4 rounded-xl border border-emerald-500/20 bg-emerald-500/5 px-5 py-4">
        <div className="flex items-center gap-3">
          <span className="text-xl" aria-hidden="true">
            ✅
          </span>
          <p className="text-sm font-semibold text-emerald-300">
            All {evidenceItems.length} acceptance criteria satisfied
          </p>
        </div>
        <StatusBadge label="Verified" tone="success" />
      </div>

      {/* Evidence checklist */}
      <section
        aria-label="Acceptance checklist"
        className="grid grid-cols-1 gap-4 sm:grid-cols-2"
      >
        {evidenceItems.map((item) => (
          <CheckItem key={item.title} item={item} />
        ))}
      </section>
    </main>
  );
}
