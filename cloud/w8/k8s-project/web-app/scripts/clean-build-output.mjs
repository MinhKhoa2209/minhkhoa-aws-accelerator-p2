import { rm } from "node:fs/promises";

if (process.env.KEEP_NEXT_OUTPUT === "1") {
  process.exit(0);
}

await Promise.allSettled([
  rm(".next", { recursive: true, force: true }),
  rm("out", { recursive: true, force: true }),
]);
