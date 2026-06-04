import type { ArchitectureStep } from "@/lib/content";

export function FlowStep({
  step,
  isLast
}: {
  step: ArchitectureStep;
  isLast: boolean;
}) {
  return (
    <div className="flex flex-col items-center gap-0">
      {/* Card */}
      <article className="glass-card w-full p-5 flex flex-col gap-3">
        {/* Header */}
        <div className="flex items-center gap-3">
          <div className="step-circle">{step.number}</div>
          <span
            className="text-lg"
            aria-hidden="true"
          >
            {step.icon}
          </span>
        </div>
        {/* Body */}
        <div>
          <h3 className="font-bold text-slate-100 text-base">{step.title}</h3>
          <p className="eyebrow mt-0.5">{step.subtitle}</p>
          <p className="mt-2 text-sm text-slate-400 leading-relaxed">
            {step.description}
          </p>
        </div>
      </article>

      {/* Connector arrow */}
      {!isLast && (
        <div
          className="flex flex-col items-center py-2"
          aria-hidden="true"
        >
          <div className="w-px h-5 bg-gradient-to-b from-cyan-500/40 to-transparent" />
          <svg
            width="12"
            height="8"
            viewBox="0 0 12 8"
            fill="none"
            className="text-cyan-500/50"
          >
            <path d="M6 8L0 0h12L6 8z" fill="currentColor" />
          </svg>
        </div>
      )}
    </div>
  );
}
