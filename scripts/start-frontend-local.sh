#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/scripts/local.env}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a && source "$ENV_FILE" && set +a
fi

cd "$ROOT_DIR/frontend"

if [[ ! -d node_modules ]]; then
  npm ci
fi

exec npm run dev -- --host 0.0.0.0
