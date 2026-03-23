#!/usr/bin/env bash
set -euo pipefail

base_url="${OMNIFLUXMIND_BASE_URL:-http://114.55.91.177/api}"
referer="${OMNIFLUXMIND_REFERER:-http://114.55.91.177/leads}"
api_key="${OMNIFLUXMIND_API_KEY:-}"

category=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category)
      category="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$api_key" ]]; then
  echo "OMNIFLUXMIND_API_KEY is required. Configure it manually with the current sid value." >&2
  exit 1
fi

curl_args=(
  --fail
  --silent
  --show-error
  --get
  "${base_url%/}/insight/leads/overview"
  -H "Accept: application/json, text/plain, */*"
  -H "Referer: ${referer}"
  -H "Cookie: sid=${api_key}"
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
)

if [[ -n "$category" ]]; then
  curl_args+=(--data-urlencode "category=${category}")
fi

curl "${curl_args[@]}"
