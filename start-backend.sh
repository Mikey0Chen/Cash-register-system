#!/bin/bash

echo "=========================================="
echo "🚀 启动后端服务（Docker 方式）"
echo "=========================================="

cd "$(dirname "$0")"

# 检查镜像是否存在
if ! docker images | grep -q "cocktail-backend"; then
    echo "❌ 后端镜像不存在，请先构建："
    echo "   cd backend && docker build -t cocktail-backend ."
    exit 1
fi

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q "cocktail-backend"; then
    echo "🗑️  删除旧容器..."
    docker rm -f cocktail-backend
fi

# 启动后端容器
echo "🚀 启动后端容器..."
docker run -d \
  --name cocktail-backend \
  -p 8080:8080 \
  --network cocktail-bar-system_cocktail-network \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/cocktail_bar?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai \
  -e SPRING_DATASOURCE_USERNAME=cocktail \
  -e SPRING_DATASOURCE_PASSWORD=cocktail123 \
  -e SPRING_REDIS_HOST=redis \
  -e SPRING_REDIS_PORT=6379 \
  -e SPRING_REDIS_PASSWORD=redis123 \
  cocktail-backend

echo ""
echo "⏳ 等待后端启动（约30秒）..."
sleep 10

# 检查容器状态
if docker ps | grep -q "cocktail-backend"; then
    echo "✅ 后端容器运行中"

    # 等待健康检查
    echo "🔍 检查健康状态..."
    for i in {1..20}; do
        if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
            echo "✅ 后端服务就绪！"
            break
        fi
        echo -n "."
        sleep 3
    done
    echo ""
else
    echo "❌ 后端容器启动失败"
    echo "查看日志："
    echo "  docker logs cocktail-backend"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ 后端服务启动成功！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  健康检查: http://localhost:8080/actuator/health"
echo "  API示例:  http://localhost:8080/recipe/page?current=1&size=10"
echo ""
echo "查看日志："
echo "  docker logs -f cocktail-backend"
echo ""
echo "停止服务："
echo "  docker stop cocktail-backend"
echo ""
echo "=========================================="
