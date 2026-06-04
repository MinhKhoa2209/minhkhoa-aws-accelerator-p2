"use client";

import { useState } from "react";
import type { RunbookStep } from "@/lib/content";

export function RunbookStepCard({ step }: { step: RunbookStep }) {
  const [copied, setCopied] = useState(false);

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(step.command);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // clipboard not available in all environments
    }
  }

  return (
    <article className="glass-card p-5 flex flex-col gap-4">
      {/* Header */}
      <div className="flex items-start gap-3">
        <div className="step-circle flex-shrink-0">{step.number}</div>
        <div>
          <h3 className="font-bold text-slate-100 text-base leading-snug">
            {step.title}
          </h3>
          <p className="mt-1 text-sm text-slate-400 leading-relaxed">
            {step.description}
          </p>
        </div>
      </div>

      {/* Command block */}
      <div className="relative">
        <pre className="code-block pr-20">{step.command}</pre>
        <button
          type="button"
          onClick={handleCopy}
          aria-label={`Copy command: ${step.command}`}
          className="absolute right-2.5 top-2.5 rounded-md border border-white/10 bg-white/[0.06] px-2.5 py-1 text-xs font-medium text-slate-400 transition-all hover:bg-white/10 hover:text-slate-200"
        >
          {copied ? "✓ Copied" : "Copy"}
        </button>
      </div>
    </article>
  );
}
