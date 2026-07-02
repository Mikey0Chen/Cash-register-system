#!/bin/bash

echo "停止鸡尾酒收银系统..."

cd "$(dirname "$0")"

docker compose down

echo "✅ 服务已停止"
