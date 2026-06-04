import type { EvidenceItem } from "@/lib/content";

export function CheckItem({ item }: { item: EvidenceItem }) {
  return (
    <article className="glass-card flex items-start gap-4 p-5">
      {/* Check icon */}
      <div
        className="flex-shrink-0 w-8 h-8 rounded-full bg-emerald-500/10 border border-emerald-500/25 flex items-center justify-center"
        aria-hidden="true"
      >
        <svg
          className="w-4 h-4 text-emerald-400"
          viewBox="0 0 20 20"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <polyline points="4 10 8 14 16 6" />
        </svg>
      </div>
      {/* Text */}
      <div>
        <h3 className="font-semibold text-slate-100 text-sm leading-snug">
          {item.title}
        </h3>
        <p className="mt-1 text-sm text-slate-400 leading-relaxed">
          {item.description}
        </p>
      </div>
    </article>
  );
}
