import Link from "next/link";

export default function NotFound() {
  return (
    <main className="flex min-h-[60vh] items-center justify-center p-6">
      <div className="glass-card max-w-md w-full p-10 text-center flex flex-col items-center gap-6">
        {/* Number */}
        <div className="flex h-20 w-20 items-center justify-center rounded-full border border-cyan-500/20 bg-cyan-500/5">
          <span className="text-3xl font-black text-cyan-400">404</span>
        </div>
        {/* Text */}
        <div>
          <h1 className="text-2xl font-black text-slate-100">Page not found</h1>
          <p className="mt-3 text-sm text-slate-400 leading-relaxed">
            CloudScope only exposes four pages: Overview, Architecture, Runbook,
            and Evidence. This route doesn't exist.
          </p>
        </div>
        {/* Action */}
        <Link href="/" className="btn-primary">
          ← Back to Overview
        </Link>
      </div>
    </main>
  );
}
