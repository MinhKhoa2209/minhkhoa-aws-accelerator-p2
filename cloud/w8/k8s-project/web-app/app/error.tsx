"use client";

import { ErrorState } from "@/components/error-state";

export default function ErrorPage({
  error,
  reset
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <ErrorState
      title="Something went wrong"
      message={error.message}
      onRetry={reset}
    />
  );
}
