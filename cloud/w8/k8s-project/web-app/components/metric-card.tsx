import type { MetricItem } from "@/lib/content";

export function MetricCard({ label, value, detail, icon }: MetricItem) {
  return (
    <article className="glass-card flex flex-col gap-2 p-5">
      <div className="flex items-center justify-between">
        <span className="eyebrow">{label}</span>
        <span className="text-xl" aria-hidden="true">
          {icon}
        </span>
      </div>
      <p className="text-lg font-bold text-slate-100 leading-snug">{value}</p>
      <p className="text-xs text-slate-400 leading-relaxed">{detail}</p>
    </article>
  );
}
