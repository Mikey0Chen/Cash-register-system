#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/2] Build backend jar"
(
  cd "$ROOT_DIR/backend"
  mvn clean package -DskipTests
)

echo "[2/2] Build frontend dist"
(
  cd "$ROOT_DIR/frontend"
  npm ci
  npm run build
)

echo
echo "Build completed:"
echo "  Backend jar: $ROOT_DIR/backend/target/cash-register-backend.jar"
echo "  Frontend dist: $ROOT_DIR/frontend/dist"
