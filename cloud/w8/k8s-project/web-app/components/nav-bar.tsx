"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { appConfig } from "@/lib/config";

const navItems = [
  { href: "/", label: "Overview" },
  { href: "/architecture", label: "Architecture" },
  { href: "/runbook", label: "Runbook" },
  { href: "/evidence", label: "Evidence" }
];

export function NavBar() {
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-50 border-b border-white/[0.06] bg-navy-900/80 backdrop-blur-md">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 py-3">
        {/* Brand */}
        <Link
          href="/"
          aria-label="CloudScope home"
          className="flex items-center gap-3 group"
        >
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-cyan-500 to-cyan-600 shadow-glow text-navy-900 font-black text-sm select-none">
            CS
          </div>
          <div className="hidden sm:block">
            <p className="eyebrow leading-none">{appConfig.projectName}</p>
            <p className="text-sm font-semibold text-slate-100 mt-0.5 group-hover:text-cyan-400 transition-colors">
              CloudScope
            </p>
          </div>
        </Link>

        {/* Nav links */}
        <nav
          className="flex items-center gap-1 rounded-xl border border-white/[0.07] bg-white/[0.03] p-1"
          aria-label="Primary navigation"
        >
          {navItems.map((item) => {
            const isActive =
              item.href === "/"
                ? pathname === "/"
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={[
                  "rounded-lg px-3.5 py-1.5 text-sm font-medium transition-all duration-200",
                  isActive
                    ? "bg-cyan-500/10 text-cyan-400 shadow-sm"
                    : "text-slate-400 hover:text-slate-100 hover:bg-white/[0.05]"
                ].join(" ")}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </div>
    </header>
  );
}
