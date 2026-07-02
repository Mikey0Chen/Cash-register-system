# 鸡尾酒收银系统 - 当前运行架构

## 系统运行状态

### 1️⃣ 开发环境（本地调试）

**前端**
- 启动方式：`npm run dev`（Vite开发服务器）
- 进程：`node /work/cocktail-bar-system/frontend/node_modules/.bin/vite`
- 端口：**5173**
- 访问地址：http://localhost:5173
- 热更新：✅ 支持（修改代码自动刷新）

**后端**
- 启动方式：`./start-backend-optimized.sh`（Maven Spring Boot）
- 进程：`mvn spring-boot:run`
- 端口：**8080**
- JVM参数：
  ```bash
  -Xms256m -Xmx512m
  -XX:+UseG1GC
  -XX:MetaspaceSize=128m
  -XX:MaxMetaspaceSize=256m
  ```
- 实际内存：~150-180 MB

**API调用方式**
```javascript
// 前端代码
import request from '@/utils/request'
const data = await request.get('/financial/today')

// Vite 自动代理
// /api/financial/today → http://localhost:8080/financial/today
```

**Vite 代理配置**
```javascript
// vite.config.js
server: {
  port: 5173,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```

**请求流程**
```
浏览器 (http://localhost:5173)
    ↓ 发送请求 GET /api/financial/today
Vite 代理服务器
    ↓ 转发到 http://localhost:8080/financial/today
Spring Boot 后端 (localhost:8080)
    ↓ 返回 JSON 数据
浏览器接收响应
```

---

### 2️⃣ 生产环境（Docker容器）

**前端**
- 启动方式：Docker 容器 `cocktail-frontend`
- 镜像：基于 Nginx
- 端口映射：**8081** → 容器内 80
- 访问地址：http://47.94.123.202:8081
- 静态文件：编译后的 HTML/JS/CSS

**后端**
- 运行位置：宿主机（与开发环境共用）
- 端口：**8080**
- 地址：通过 Docker 桥接网络访问 `172.17.0.1:8080`

**API调用方式**
```javascript
// 前端代码（相同）
import request from '@/utils/request'
const data = await request.get('/financial/today')

// Nginx 代理
// /api/financial/today → http://172.17.0.1:8080/financial/today
```

**Nginx 代理配置**
```nginx
# 容器内 /etc/nginx/conf.d/default.conf
location /api/ {
    proxy_pass http://172.17.0.1:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

**请求流程**
```
外网浏览器 (http://47.94.123.202:8081)
    ↓ 发送请求 GET /api/financial/today
Docker 容器 (cocktail-frontend:80)
    ↓ Nginx 代理转发
Docker 桥接网络 (172.17.0.1:8080)
    ↓ 访问宿主机
Spring Boot 后端 (宿主机:8080)
    ↓ 返回 JSON 数据
浏览器接收响应
```

---

## 网络架构总览

```
┌─────────────────────────────────────────────────────────┐
│                      宿主机 (Linux)                      │
│                                                          │
│  ┌─────────────────────┐        ┌───────────────────┐  │
│  │   开发环境          │        │   生产环境         │  │
│  │                     │        │                    │  │
│  │  Vite Dev Server    │        │  Docker Container  │  │
│  │  :5173              │        │  Nginx :80         │  │
│  │  ↓ proxy /api       │        │  ↓ proxy /api      │  │
│  └──────┬──────────────┘        └────────┬───────────┘  │
│         │                                 │              │
│         │  ┌──────────────────────────────┘              │
│         │  │                                             │
│         ↓  ↓                                             │
│  ┌──────────────────┐                                   │
│  │  Spring Boot     │                                   │
│  │  Backend :8080   │                                   │
│  └─────┬────────────┘                                   │
│        │                                                 │
│        ↓                                                 │
│  ┌──────────────────────────────────────┐               │
│  │  Docker Containers                   │               │
│  │  ┌──────────────┐  ┌──────────────┐ │               │
│  │  │ MySQL :3306  │  │ Redis :6379  │ │               │
│  │  └──────────────┘  └──────────────┘ │               │
│  └──────────────────────────────────────┘               │
│                                                          │
└─────────────────────────────────────────────────────────┘

外网访问
  ↓
  8081端口 (生产环境)
  5173端口 (开发环境，仅内网)
```

---

## 前端代码统一使用 request 工具

### src/utils/request.js
```javascript
import axios from 'axios'

const request = axios.create({
  baseURL: '/api',  // 所有请求自动加 /api 前缀
  timeout: 10000
})

// 响应拦截器自动处理 code 判断
request.interceptors.response.use(
  response => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message))
    }
    return res  // 返回 { code, message, data }
  }
)

export default request
```

### 业务代码调用
```javascript
import request from '@/utils/request'

// 财务统计
const data = await request.get('/financial/today')
console.log(data.data)  // { totalRevenue, totalCost, ... }

// 订单明细
const data = await request.get('/financial/orders', {
  params: { startDate: '2026-06-25', endDate: '2026-06-25' }
})
console.log(data.data)  // [{ orderNo, actualAmount, ... }]
```

---

## 两套环境的区别

| 对比项 | 开发环境 | 生产环境 |
|--------|----------|----------|
| **前端服务器** | Vite (Node.js) | Nginx (Docker) |
| **端口** | 5173 | 8081 |
| **代理方式** | Vite proxy | Nginx proxy_pass |
| **后端地址** | localhost:8080 | 172.17.0.1:8080 |
| **热更新** | ✅ 支持 | ❌ 需重新构建 |
| **访问范围** | 本地 | 外网 47.94.123.202 |
| **静态文件** | 实时编译 | 预编译（npm run build） |

---

## 启动/停止命令

### 开发环境

**启动前端**
```bash
cd /work/cocktail-bar-system/frontend
npm run dev
# 访问 http://localhost:5173
```

**启动后端**
```bash
cd /work/cocktail-bar-system
./start-backend-optimized.sh
# 后端监听 :8080
```

**停止**
```bash
# 停止前端：Ctrl+C 或 pkill -f vite
# 停止后端：pkill -f spring-boot:run
```

### 生产环境

**启动/重启容器**
```bash
cd /work/cocktail-bar-system
docker compose up -d cocktail-frontend
# 访问 http://47.94.123.202:8081
```

**查看日志**
```bash
docker logs -f cocktail-frontend
```

**更新前端代码**
```bash
# 1. 编译前端
cd frontend
npm run build

# 2. 重新构建镜像
docker build -t cocktail-frontend:latest .

# 3. 重启容器
docker compose up -d cocktail-frontend
```

**停止**
```bash
docker compose stop cocktail-frontend
```

---

## 数据库和缓存

### MySQL
```bash
# 容器名：cocktail-mysql
# 端口：3306
# 连接：mysql -h127.0.0.1 -uroot -proot123 cocktail_bar

# 或通过 Docker
docker exec -it cocktail-mysql mysql -uroot -proot123 cocktail_bar
```

### Redis
```bash
# 容器名：cocktail-redis
# 端口：6379
# 连接：redis-cli -h 127.0.0.1 -p 6379

# 或通过 Docker
docker exec -it cocktail-redis redis-cli
```

---

## 当前系统资源占用

```bash
# 后端内存
ps aux | grep spring-boot | awk '{print $6/1024 " MB"}'
# 约 150-180 MB

# 前端内存（Vite开发服务器）
ps aux | grep vite | awk '{print $6/1024 " MB"}'
# 约 60-80 MB

# 容器资源
docker stats --no-stream cocktail-frontend cocktail-mysql cocktail-redis
```

---

## 常见问题

### Q1: 为什么有两个前端在运行？
- **开发环境（5173）**：用于本地开发和调试，支持热更新
- **生产环境（8081）**：用于外网访问，使用编译后的静态文件

### Q2: 两个前端可以同时运行吗？
✅ 可以，它们使用不同的端口，互不干扰。

### Q3: 如何选择访问哪个环境？
- 开发调试：访问 http://localhost:5173
- 正式使用：访问 http://47.94.123.202:8081

### Q4: 后端是共用的吗？
✅ 是的，两个前端环境共用同一个后端服务（宿主机 :8080）。

### Q5: 修改前端代码后如何生效？
- **开发环境**：保存后自动热更新
- **生产环境**：需要 `npm run build` + 重新构建 Docker 镜像

---

## 推荐的开发流程

1. **日常开发**：使用开发环境（5173端口）
   ```bash
   cd /work/cocktail-bar-system
   ./start-backend-optimized.sh  # 启动后端
   cd frontend
   npm run dev  # 启动前端
   ```

2. **功能完成后**：部署到生产环境
   ```bash
   cd frontend
   npm run build  # 编译
   docker build -t cocktail-frontend:latest .  # 构建镜像
   docker compose up -d cocktail-frontend  # 重启容器
   ```

3. **验证**：访问 http://47.94.123.202:8081 测试

---

## 总结

✅ 开发环境：Vite (5173) + Spring Boot (8080)  
✅ 生产环境：Nginx Docker (8081) + Spring Boot (8080)  
✅ API代理：统一使用 `/api` 前缀  
✅ 前端代码：统一使用 `request` 工具  
✅ 后端共享：两个环境使用同一个后端服务

当前配置：内存优化，适配 2C2G 服务器 ✅
