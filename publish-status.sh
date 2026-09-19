#!/usr/bin/env bash
# Overwrite status.json on david-vsco/spd-paywall-live and push to main (GitHub Pages).
# Usage:
#   ./publish-status.sh path/to/status.json
#   ./publish-status.sh   # uses ./status.json in cwd
# Env:
#   REPO=david-vsco/spd-paywall-live  BRANCH=main
# Needs: gh auth (repo scope) or git credentials for push.
set -euo pipefail

REPO="${REPO:-david-vsco/spd-paywall-live}"
BRANCH="${BRANCH:-main}"
SRC="${1:-status.json}"

if [[ ! -f "$SRC" ]]; then
  echo "usage: $0 [status.json]" >&2
  exit 1
fi

# Ensure updated_at is fresh if missing (caller should set it)
if ! grep -q '"updated_at"' "$SRC"; then
  echo "warn: status.json has no updated_at" >&2
fi

# Prefer gh Contents API (single-file overwrite, no full clone)
OWNER="${REPO%%/*}"
NAME="${REPO##*/}"
SHA=$(gh api "repos/${OWNER}/${NAME}/contents/status.json?ref=${BRANCH}" --jq .sha 2>/dev/null || true)
CONTENT_B64=$(base64 < "$SRC" | tr -d '\n')

ARGS=( -X PUT "repos/${OWNER}/${NAME}/contents/status.json"
  -f message="chore: update paywall live status"
  -f branch="$BRANCH"
  -f content="$CONTENT_B64"
)
if [[ -n "${SHA}" ]]; then
  ARGS+=( -f sha="$SHA" )
fi

gh api "${ARGS[@]}" --jq '.content.html_url // .commit.html_url'
echo "Published status.json → https://${OWNER}.github.io/${NAME}/live.html"
