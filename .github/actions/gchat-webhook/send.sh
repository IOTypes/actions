#!/usr/bin/env bash
set -euo pipefail

msg="${INPUT_MESSAGE}"
title="${INPUT_TITLE:-}"
include_ctx="${INPUT_INCLUDE_JOB_CONTEXT:-true}"
webhook_url="${INPUT_WEBHOOK_URL}"

if [[ -n "$title" ]]; then
  msg="$(printf "%s\n%s" "$title" "$msg")"
fi

if [[ "${include_ctx,,}" == "true" ]]; then
  footer="$(printf '\n\nRepository: %s \n Ref: %s\n' \
    "$GITHUB_REPOSITORY" \
    "$GITHUB_REF")"
  msg="${msg}\n${footer}"
fi

# EXPORT FIRST
export MSG="$msg"

payload="$(python3 - <<'PY'
import json, os
print(json.dumps({"text": os.environ["MSG"]}, ensure_ascii=False))
PY
)"

curl -sS -X POST \
  -H "Content-Type: application/json; charset=utf-8" \
  --data-binary "$payload" \
  "$webhook_url"
