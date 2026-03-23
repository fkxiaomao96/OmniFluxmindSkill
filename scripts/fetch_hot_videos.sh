#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/category_utils.sh"

base_url="${OMNIFLUXMIND_BASE_URL:-http://114.55.91.177/api}"
referer="${OMNIFLUXMIND_REFERER:-http://114.55.91.177/hot-videos}"
api_key="${OMNIFLUXMIND_API_KEY:-}"

category=""
time_range="all"
favorite_status="ALL"
sort_by="COMPREHENSIVE"
page="1"
size="12"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category)
      category="${2:-}"
      shift 2
      ;;
    --time-range)
      time_range="${2:-}"
      shift 2
      ;;
    --favorite-status)
      favorite_status="${2:-}"
      shift 2
      ;;
    --sort-by)
      sort_by="${2:-}"
      shift 2
      ;;
    --page)
      page="${2:-}"
      shift 2
      ;;
    --size)
      size="${2:-}"
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

validate_category "$category"

curl_args=(
  --fail
  --silent
  --show-error
  --get
  "${base_url%/}/insight/hot-videos"
  -H "Accept: application/json, text/plain, */*"
  -H "Referer: ${referer}"
  -H "Cookie: sid=${api_key}"
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
  --data-urlencode "timeRange=${time_range}"
  --data-urlencode "favoriteStatus=${favorite_status}"
  --data-urlencode "sortBy=${sort_by}"
  --data-urlencode "page=${page}"
  --data-urlencode "size=${size}"
)

if [[ -n "$category" ]]; then
  curl_args+=(--data-urlencode "category=${category}")
fi

curl "${curl_args[@]}"
