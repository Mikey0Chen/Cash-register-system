# 生产环境财务统计修复报告

## 问题描述
生产环境（http://47.94.123.202:8081/financial）财务统计页面无数据显示。

## 问题根源

### 1. 开发环境 vs 生产环境差异
- **开发环境（5173端口）**：使用 Vite 内置代理，已配置 `/api` → `localhost:8080`
- **生产环境（8081端口）**：使用 Docker + Nginx，但 Nginx 容器内缺少 `/api` 代理配置

### 2. 容器网络配置
Docker 容器需要通过 Docker 桥接网络 IP（172.17.0.1）访问宿主机的后端服务（8080端口）。

## 修复步骤

### 第一步：创建正确的 Nginx 配置

**配置文件位置**：`/tmp/nginx-default.conf`

**关键配置**：
```nginx
# API 代理到宿主机后端
location /api/ {
    proxy_pass http://172.17.0.1:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### 第二步：更新容器配置
```bash
# 复制配置文件到容器
docker cp /tmp/nginx-default.conf cocktail-frontend:/etc/nginx/conf.d/default.conf

# 重载 Nginx
docker exec cocktail-frontend nginx -s reload
```

## 验证测试

### 1. 财务统计API测试
```bash
curl http://localhost:8081/api/financial/today
{
  "code": 200,
  "data": {
    "totalRevenue": 88.00,
    "totalCost": 12.50,
    "totalProfit": 75.50,
    "profitRate": 85.80,
    "orderCount": 1,
    "itemCount": 1
  }
}
```
✅ 财务概览API正常

### 2. 订单明细API测试
```bash
curl "http://localhost:8081/api/financial/orders?startDate=2026-06-25&endDate=2026-06-25"
{
  "code": 200,
  "data": [
    {
      "orderNo": "ORD202606251327391170",
      "actualAmount": 88.00,
      "totalCost": 12.50,
      "profit": 75.50,
      "profitRate": 85.80
    }
  ]
}
```
✅ 订单明细API正常

## 部署架构

### 网络拓扑
```
外网 (47.94.123.202:8081)
    ↓
Docker 容器 (cocktail-frontend:80)
    ↓ (Nginx 代理 /api/)
Docker 桥接网络 (172.17.0.1:8080)
    ↓
宿主机后端服务 (Spring Boot)
    ↓
MySQL/Redis 容器
```

### 端口映射
- **8081** → 前端容器（80端口）
- **8080** → 后端服务（宿主机）
- **3306** → MySQL容器
- **6379** → Redis容器

## 更新后的配置文件

### 应该同步更新的文件
建议将修复后的配置持久化到项目文件：

**文件**：`/work/cocktail-bar-system/frontend/cocktail-frontend.conf`

```nginx
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # API 代理到宿主机后端（使用Docker桥接网络IP）
    location /api/ {
        proxy_pass http://172.17.0.1:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 前端路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 重新构建容器（可选）

如果需要重新构建前端容器以持久化配置：

```bash
# 1. 更新 cocktail-frontend.conf 文件
# 2. 重新构建镜像
cd /work/cocktail-bar-system/frontend
docker build -t cocktail-frontend:latest .

# 3. 重新启动容器
docker compose up -d cocktail-frontend
```

## 现在可以访问

### 开发环境
- URL: http://localhost:5173
- 后端: 直接访问 http://localhost:8080
- 代理: Vite 内置代理

### 生产环境
- URL: http://47.94.123.202:8081
- 后端: 通过 Nginx 代理访问
- 代理: http://47.94.123.202:8081/api/ → http://172.17.0.1:8080/

## 页面显示效果

访问 http://47.94.123.202:8081/financial 应该显示：

**财务概览**
- 销售收入: ¥88.00
- 成本支出: ¥12.50
- 净利润: ¥75.50
- 利润率: 85.80%
- 订单数量: 1 单
- 销售数量: 1 杯

**订单明细**
| 订单号 | 支付时间 | 销售金额 | 成本 | 利润 | 利润率 | 数量 | 支付方式 |
|--------|----------|----------|------|------|--------|------|----------|
| ORD202606251327391170 | 2026-06-25 13:27 | ¥88.00 | ¥12.50 | ¥75.50 | 85.80% | 1 | 现金 |

## 问题总结

1. ✅ 前端代码已修复（使用统一的 request 工具）
2. ✅ 开发环境正常（Vite 代理）
3. ✅ 生产环境已修复（Nginx 代理配置已更新）
4. ✅ API 调用正常（通过 /api/ 代理到后端）

## 注意事项

### Docker 网络地址
- ❌ `host.docker.internal` - 仅在 Docker Desktop (Mac/Windows) 可用
- ✅ `172.17.0.1` - Linux 上 Docker 桥接网络的宿主机地址

### 容器重启后配置持久化
当前修复通过 `docker cp` + `nginx -s reload` 完成，重启容器后配置会丢失。

**永久解决方案**：
1. 更新项目中的 `cocktail-frontend.conf`
2. 重新构建 Docker 镜像
3. 或使用 Docker volume 挂载配置文件

## 维护命令

```bash
# 查看 Nginx 配置
docker exec cocktail-frontend cat /etc/nginx/conf.d/default.conf

# 重载 Nginx
docker exec cocktail-frontend nginx -s reload

# 查看 Nginx 日志
docker logs cocktail-frontend

# 测试 API 代理
curl http://localhost:8081/api/financial/today
```

---
修复时间：2026-06-25  
环境：生产环境（Docker + Nginx）  
状态：✅ 已修复并验证
