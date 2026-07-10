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

RUN_MODE="${BACKEND_RUN_MODE:-jar}"
read -r -a JAVA_ARGS <<< "${JAVA_OPTS:--Xms128m -Xmx256m -XX:+UseG1GC}"

cd "$ROOT_DIR/backend"

if [[ "$RUN_MODE" == "maven" ]]; then
  exec mvn -q -DskipTests -Dmaven.test.skip=true spring-boot:run
fi

if [[ ! -f "$JAR_PATH" ]] || [[ -n "$(find "$ROOT_DIR/backend/src" "$ROOT_DIR/backend/pom.xml" -newer "$JAR_PATH" -print -quit)" ]]; then
  echo "Building backend jar..."
  mvn -q -DskipTests -Dmaven.test.skip=true package
fi

exec java "${JAVA_ARGS[@]}" -jar "$JAR_PATH"
