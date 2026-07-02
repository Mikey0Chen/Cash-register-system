#!/bin/bash

echo "=========================================="
echo "🍸 鸡尾酒收银系统 - 完整安装指南"
echo "=========================================="

cd "$(dirname "$0")"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

echo "✅ Docker 已安装"
echo ""

# 步骤 1: 启动数据库
echo "📦 步骤 1/3: 启动数据库服务..."
mkdir -p data/mysql data/redis
docker compose up -d mysql redis

echo "⏳ 等待数据库初始化（30秒）..."
sleep 30

# 验证数据库
echo "🔍 验证数据库..."
RECIPE_COUNT=$(docker exec cocktail-mysql mysql -ucocktail -pcocktail123 -e "SELECT COUNT(*) FROM cocktail_bar.cocktail_recipe" -sN 2>/dev/null)

if [ "$RECIPE_COUNT" == "6" ]; then
    echo "✅ 数据库初始化成功！（6个配方，32种原料）"
else
    echo "⚠️  数据库可能未完全初始化，稍后手动检查"
fi

echo ""
echo "=========================================="
echo "✅ 数据库服务已就绪！"
echo "=========================================="
echo ""
echo "数据库连接信息："
echo "  MySQL: localhost:3306"
echo "    数据库: cocktail_bar"
echo "    用户名: cocktail"
echo "    密码: cocktail123"
echo ""
echo "  Redis: localhost:6379"
echo "    密码: redis123"
echo ""
echo "=========================================="
echo "📝 下一步操作："
echo "=========================================="
echo ""
echo "方式一：使用 Docker 运行后端（推荐）"
echo "  cd backend"
echo "  docker build -t cocktail-backend ."
echo "  docker run -d -p 8080:8080 --network cocktail-bar-system_cocktail-network cocktail-backend"
echo ""
echo "方式二：本地运行（需要 Maven）"
echo "  # 安装 Maven 后执行："
echo "  cd backend"
echo "  mvn spring-boot:run"
echo ""
echo "前端开发："
echo "  cd frontend"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "查看日志："
echo "  docker compose logs -f mysql"
echo "  docker compose logs -f redis"
echo ""
echo "=========================================="
