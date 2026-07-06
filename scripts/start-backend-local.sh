#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/scripts/local.env}"

if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    export "$key=$value"
  done < "$ENV_FILE"
fi

cd "$ROOT_DIR/backend"
exec mvn spring-boot:run
