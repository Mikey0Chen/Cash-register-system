#!/bin/bash

echo "=========================================="
echo "🍸 鸡尾酒收银系统 - 一键启动"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 docker compose 是否可用
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose 不可用"
    exit 1
fi

echo "✅ Docker 环境检查通过"
echo ""

# 进入项目目录
cd "$(dirname "$0")"

# 创建数据目录
echo "📁 创建数据目录..."
mkdir -p data/mysql data/redis

# 启动服务
echo "🚀 启动服务..."
docker compose up -d

# 等待服务启动
echo ""
echo "⏳ 等待服务启动（约30秒）..."
sleep 5

# 显示进度
for i in {1..6}; do
    echo -n "."
    sleep 5
done
echo ""

# 检查服务状态
echo ""
echo "📊 检查服务状态..."
docker compose ps

echo ""
echo "=========================================="
echo "✅ 启动完成！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  前端：http://localhost"
echo "  后端：http://localhost:8080"
echo "  MySQL：localhost:3306"
echo "  Redis：localhost:6379"
echo ""
echo "默认账号："
echo "  用户名：admin"
echo "  密码：admin123"
echo ""
echo "常用命令："
echo "  查看日志：docker compose logs -f"
echo "  停止服务：docker compose down"
echo "  重启服务：docker compose restart"
echo "  查看状态：docker compose ps"
echo "=========================================="
