#!/usr/bin/env bash
set -euo pipefail

base_url="${OMNIFLUXMIND_BASE_URL:-http://114.55.91.177/api}"
referer="${OMNIFLUXMIND_REFERER:-http://114.55.91.177/leads}"
api_key="${OMNIFLUXMIND_API_KEY:-}"

if [[ -z "$api_key" ]]; then
  echo "OMNIFLUXMIND_API_KEY is required. Configure it manually with the current sid value." >&2
  exit 1
fi

curl --fail --silent --show-error \
  "${base_url%/}/insight/leads/meta" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Referer: ${referer}" \
  -H "Cookie: sid=${api_key}"
