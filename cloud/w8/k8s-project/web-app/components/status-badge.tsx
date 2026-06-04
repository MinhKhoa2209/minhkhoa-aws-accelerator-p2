type Tone = "success" | "warning" | "error" | "info";

const toneStyles: Record<Tone, { dot: string; badge: string }> = {
  success: {
    dot: "bg-emerald-400 text-emerald-400",
    badge: "border-emerald-500/20 bg-emerald-500/10 text-emerald-400"
  },
  warning: {
    dot: "bg-amber-400 text-amber-400",
    badge: "border-amber-500/20 bg-amber-500/10 text-amber-400"
  },
  error: {
    dot: "bg-red-400 text-red-400",
    badge: "border-red-500/20 bg-red-500/10 text-red-400"
  },
  info: {
    dot: "bg-cyan-400 text-cyan-400",
    badge: "border-cyan-500/20 bg-cyan-500/10 text-cyan-400"
  }
};

export function StatusBadge({
  label,
  tone = "success"
}: {
  label: string;
  tone?: Tone;
}) {
  const styles = toneStyles[tone];
  return (
    <span
      className={`inline-flex items-center gap-2 rounded-full border px-3.5 py-1 text-xs font-semibold ${styles.badge}`}
    >
      <span className="relative flex h-2 w-2">
        <span
          className={`absolute inline-flex h-full w-full animate-ping rounded-full opacity-75 ${styles.dot}`}
        />
        <span
          className={`relative inline-flex h-2 w-2 rounded-full ${styles.dot}`}
        />
      </span>
      {label}
    </span>
  );
}
