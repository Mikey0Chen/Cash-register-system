#!/bin/bash

echo "=========================================="
echo "🍸 鸡尾酒收银系统 - 启动数据库服务"
echo "=========================================="

cd "$(dirname "$0")"

# 创建数据目录
mkdir -p data/mysql data/redis

# 只启动 MySQL 和 Redis
echo "🚀 启动 MySQL 和 Redis..."
docker compose up -d mysql redis

echo ""
echo "⏳ 等待数据库初始化..."
sleep 10

echo ""
echo "✅ 数据库服务启动完成！"
echo ""
echo "连接信息："
echo "  MySQL: localhost:3306"
echo "    数据库: cocktail_bar"
echo "    用户名: cocktail"
echo "    密码: cocktail123"
echo ""
echo "  Redis: localhost:6379"
echo "    密码: redis123"
echo ""
echo "查看日志："
echo "  docker compose logs -f mysql"
echo "  docker compose logs -f redis"
echo ""
echo "=========================================="
