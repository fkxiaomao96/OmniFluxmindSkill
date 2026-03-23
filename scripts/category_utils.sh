#!/usr/bin/env bash

supported_categories=(
  "keyboard"
  "mouse"
  "memory"
  "monitor"
  "dress"
)

supported_categories_csv() {
  local IFS=", "
  printf '%s' "${supported_categories[*]}"
}

validate_category() {
  local category="${1:-}"
  if [[ -z "$category" ]]; then
    return 0
  fi

  local supported
  for supported in "${supported_categories[@]}"; do
    if [[ "$category" == "$supported" ]]; then
      return 0
    fi
  done

  echo "Unsupported category: ${category}. Supported values: $(supported_categories_csv)" >&2
  exit 1
}
