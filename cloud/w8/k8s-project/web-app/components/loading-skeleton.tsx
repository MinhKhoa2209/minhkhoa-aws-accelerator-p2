export function LoadingSkeleton() {
  return (
    <main className="mx-auto max-w-6xl px-5 py-10" aria-label="Loading…">
      {/* Page title skeleton */}
      <div className="mb-10 space-y-3">
        <div className="skeleton h-3 w-20 rounded" />
        <div className="skeleton h-8 w-64 rounded-lg" />
        <div className="skeleton h-4 w-96 rounded" />
      </div>

      {/* Cards skeleton grid */}
      <div
        className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4"
        aria-hidden="true"
      >
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="skeleton h-28 rounded-xl" />
        ))}
      </div>

      {/* Section skeleton */}
      <div className="mt-10 space-y-4">
        <div className="skeleton h-6 w-48 rounded-lg" />
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="skeleton h-24 rounded-xl" />
          ))}
        </div>
      </div>
    </main>
  );
}
