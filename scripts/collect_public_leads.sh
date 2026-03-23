#!/usr/bin/env bash
set -euo pipefail

base_url="${OMNIFLUXMIND_BASE_URL:-http://114.55.91.177/api}"
referer="${OMNIFLUXMIND_REFERER:-http://114.55.91.177/leads}"
api_key="${OMNIFLUXMIND_API_KEY:-}"

category=""
collect_type="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category)
      category="${2:-}"
      shift 2
      ;;
    --collect-type)
      collect_type="${2:-}"
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

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "$value"
}

payload="{\"collectType\":\"$(json_escape "$collect_type")\"}"
if [[ -n "$category" ]]; then
  payload="{\"category\":\"$(json_escape "$category")\",\"collectType\":\"$(json_escape "$collect_type")\"}"
fi

curl --fail --silent --show-error \
  "${base_url%/}/insight/leads/collect" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Content-Type: application/json" \
  -H "Referer: ${referer}" \
  -H "Cookie: sid=${api_key}" \
  --data "${payload}"
