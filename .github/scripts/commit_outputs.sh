#!/usr/bin/env bash
# Commit whatever the worker produced (reports, drafts, charts, ledgers) and push.
# Retries with a rebase so workers finishing at the same time don't collide.
set -euo pipefail

label="${1:-AI Employee run}"

git config user.name "github-actions[bot]"
git config user.email "41898708+github-actions[bot]@users.noreply.github.com"

git add -A
if git diff --cached --quiet; then
  echo "No new output to save."
  exit 0
fi

git commit -m "${label} - $(date '+%Y-%m-%d %H:%M %Z')"

for attempt in 1 2 3 4 5; do
  if git pull --rebase --quiet && git push --quiet; then
    echo "Saved output (attempt ${attempt})."
    exit 0
  fi
  echo "Push failed, retrying in $((attempt * 5))s..."
  sleep $((attempt * 5))
done

echo "Could not push output after 5 attempts." >&2
exit 1
