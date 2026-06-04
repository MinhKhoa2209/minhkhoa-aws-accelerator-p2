"use client";

export function ErrorState({
  title,
  message,
  onRetry
}: {
  title: string;
  message: string;
  onRetry: () => void;
}) {
  return (
    <main className="flex min-h-[60vh] items-center justify-center p-6">
      <div className="glass-card max-w-md w-full p-8 text-center flex flex-col items-center gap-5">
        {/* Icon */}
        <div className="flex h-14 w-14 items-center justify-center rounded-full bg-red-500/10 border border-red-500/20">
          <svg
            className="w-7 h-7 text-red-400"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <circle cx="12" cy="12" r="10" />
            <line x1="12" y1="8" x2="12" y2="12" />
            <line x1="12" y1="16" x2="12.01" y2="16" />
          </svg>
        </div>
        {/* Text */}
        <div>
          <span className="eyebrow">Error</span>
          <h1 className="mt-2 text-xl font-bold text-slate-100">{title}</h1>
          <p className="mt-2 text-sm text-slate-400 leading-relaxed">
            {message || "An unexpected error occurred while rendering this page."}
          </p>
        </div>
        {/* Action */}
        <button type="button" onClick={onRetry} className="btn-primary">
          Try again
        </button>
      </div>
    </main>
  );
}
