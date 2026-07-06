#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/scripts/local.env}"
JAR_PATH="$ROOT_DIR/backend/target/cash-register-backend.jar"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a && source "$ENV_FILE" && set +a
fi

if [[ ! -f "$JAR_PATH" ]]; then
  echo "Backend jar not found: $JAR_PATH" >&2
  echo "Run ./scripts/build-release.sh first." >&2
  exit 1
fi

cd "$ROOT_DIR/backend"
exec java -jar "$JAR_PATH"
