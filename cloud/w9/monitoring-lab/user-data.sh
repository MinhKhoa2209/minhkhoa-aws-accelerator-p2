#!/bin/bash
set -euo pipefail

# Wait for the alarm and SNS subscription to settle, then generate CPU load
# for longer than one five-minute CloudWatch evaluation period.
sleep 600

cpu_count="$(nproc)"
for _ in $(seq 1 "$cpu_count"); do
  timeout 420 yes > /dev/null &
done
wait
