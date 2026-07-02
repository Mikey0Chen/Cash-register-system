#!/bin/bash

echo "=========================================="
echo "🚀 本地启动后端服务（Maven 方式）"
echo "=========================================="

cd "$(dirname "$0")"/backend

# 检查 Maven
if ! command -v mvn &> /dev/null && ! /opt/maven/bin/mvn --version &> /dev/null; then
    echo "❌ Maven 未安装"
    exit 1
fi

# 使用正确的 Maven 路径
if command -v mvn &> /dev/null; then
    MVN=mvn
else
    MVN=/opt/maven/bin/mvn
fi

echo "✅ Maven 已就绪"
echo ""

# 检查数据库
echo "🔍 检查数据库连接..."
if ! docker ps | grep -q "cocktail-mysql"; then
    echo "❌ MySQL 未运行，请先启动："
    echo "   cd .. && ./start-db-only.sh"
    exit 1
fi

echo "✅ 数据库运行中"
echo ""

# 启动后端
echo "🚀 启动 Spring Boot 应用..."
echo "   (首次运行需要下载依赖，请耐心等待...)"
echo ""

$MVN spring-boot:run

