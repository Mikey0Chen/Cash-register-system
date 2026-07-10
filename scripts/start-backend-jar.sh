#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/scripts/local.env}"
JAR_PATH="$ROOT_DIR/backend/target/cash-register-backend.jar"

if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    export "$key=$value"
  done < "$ENV_FILE"
fi

if [[ ! -f "$JAR_PATH" ]]; then
  echo "Backend jar not found: $JAR_PATH" >&2
  echo "Run ./scripts/build-release.sh first." >&2
  exit 1
fi

read -r -a JAVA_ARGS <<< "${JAVA_OPTS:--Xms128m -Xmx256m -XX:+UseG1GC}"

cd "$ROOT_DIR/backend"
exec java "${JAVA_ARGS[@]}" -jar "$JAR_PATH"
