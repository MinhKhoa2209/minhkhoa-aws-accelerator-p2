export function EmptyState({
  title,
  message,
  icon = "📭"
}: {
  title: string;
  message: string;
  icon?: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-white/10 bg-white/[0.02] px-8 py-14 text-center">
      <span className="text-3xl" aria-hidden="true">
        {icon}
      </span>
      <h3 className="text-base font-semibold text-slate-200">{title}</h3>
      <p className="max-w-sm text-sm text-slate-500 leading-relaxed">{message}</p>
    </div>
  );
}
