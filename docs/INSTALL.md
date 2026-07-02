# 🍸 鸡尾酒收银系统 - 安装部署指南

## 系统要求

- **操作系统**：Linux / macOS / Windows (WSL2)
- **Docker**：20.10+ ✅ 已安装
- **Docker Compose**：2.0+ ✅ 已安装
- **Java**：JDK 17+ (用于本地开发)
- **Maven**：3.6+ (正在安装中...)
- **Node.js**：18+ (用于本地开发)

---

## 快速启动指南

### 方式一：Docker 一键启动（推荐生产环境）

```bash
cd /work/cocktail-bar-system
./start.sh
```

**访问地址：**
- 前端：http://localhost
- 后端：http://localhost:8080

**默认账号：**
- 用户名：admin
- 密码：admin123

---

### 方式二：本地开发模式

#### 1. 启动数据库服务

```bash
cd /work/cocktail-bar-system
./start-db-only.sh
```

**数据库连接信息：**
```
MySQL:
  Host: localhost:3306
  Database: cocktail_bar
  Username: cocktail
  Password: cocktail123

Redis:
  Host: localhost:6379
  Password: redis123
```

#### 2. 启动后端（Spring Boot）

```bash
cd /work/cocktail-bar-system/backend

# 首次运行需要下载依赖
mvn clean install

# 启动后端服务
mvn spring-boot:run
```

**后端地址：** http://localhost:8080

**健康检查：** http://localhost:8080/actuator/health

#### 3. 启动前端（Vue 3）

```bash
cd /work/cocktail-bar-system/frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

**前端地址：** http://localhost:5173

---

## 环境变量配置

### 后端配置文件

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/cocktail_bar?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: cocktail
    password: cocktail123
  
  redis:
    host: localhost
    port: 6379
    password: redis123
```

### 前端代理配置

编辑 `frontend/vite.config.js`：

```javascript
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

---

## 数据库初始化

数据库会在首次启动时自动初始化，包含：
- ✅ 12 张核心表结构
- ✅ 6 个经典鸡尾酒配方
- ✅ 32 种原料数据
- ✅ 测试员工账号
- ✅ 测试会员数据

**手动初始化（如果需要）：**

```bash
# 进入 MySQL 容器
docker exec -it cocktail-mysql bash

# 连接数据库
mysql -uroot -proot123 cocktail_bar

# 执行初始化脚本
source /docker-entrypoint-initdb.d/1-init.sql
source /docker-entrypoint-initdb.d/2-data.sql
```

---

## 常用命令

### Docker 管理

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
docker compose logs -f mysql
docker compose logs -f backend

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 停止并删除数据卷
docker compose down -v
```

### Maven 命令

```bash
# 清理编译
mvn clean

# 编译项目
mvn compile

# 打包（跳过测试）
mvn package -DskipTests

# 运行测试
mvn test

# 安装到本地仓库
mvn install
```

### NPM 命令

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

---

## 故障排查

### 1. 端口被占用

**问题：** 启动失败，提示端口已被占用

**解决：**
```bash
# 查看端口占用
lsof -i :3306  # MySQL
lsof -i :6379  # Redis
lsof -i :8080  # 后端
lsof -i :80    # 前端

# 停止占用进程
kill -9 <PID>
```

### 2. 数据库连接失败

**问题：** 后端无法连接数据库

**检查：**
```bash
# 检查 MySQL 是否运行
docker compose ps mysql

# 查看 MySQL 日志
docker compose logs mysql

# 测试连接
mysql -h127.0.0.1 -P3306 -ucocktail -pcocktail123 -e "SELECT 1"
```

### 3. 前端无法调用后端 API

**问题：** 前端请求后端接口失败

**检查：**
```bash
# 测试后端健康检查
curl http://localhost:8080/actuator/health

# 测试 API 接口
curl http://localhost:8080/recipe/page?current=1&size=10
```

### 4. Maven 下载依赖慢

**解决：** 配置国内镜像源

编辑 `~/.m2/settings.xml`：

```xml
<mirrors>
  <mirror>
    <id>aliyun</id>
    <mirrorOf>central</mirrorOf>
    <name>Aliyun Maven</name>
    <url>https://maven.aliyun.com/repository/public</url>
  </mirror>
</mirrors>
```

### 5. NPM 安装依赖慢

**解决：** 使用淘宝镜像

```bash
npm config set registry https://registry.npmmirror.com
npm install
```

---

## 性能优化

### 1. 数据库优化

```sql
-- 添加索引（已在 init.sql 中包含）
CREATE INDEX idx_category ON cocktail_recipe(category);
CREATE INDEX idx_sales ON cocktail_recipe(sales_count);
CREATE INDEX idx_create_time ON bar_order(created_at);
```

### 2. Redis 缓存配置

```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 16
        max-idle: 8
        min-idle: 2
```

### 3. 后端 JVM 参数

```bash
java -Xms512m -Xmx1024m -jar app.jar
```

---

## 安全建议

### 生产环境部署

1. **修改默认密码**
```yaml
# docker-compose.yml
MYSQL_ROOT_PASSWORD: <强密码>
SPRING_REDIS_PASSWORD: <强密码>
```

2. **启用 HTTPS**
```bash
# 使用 Let's Encrypt
certbot --nginx -d yourdomain.com
```

3. **配置防火墙**
```bash
# 只开放必要端口
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

4. **定期备份数据**
```bash
# 自动备份脚本
0 2 * * * mysqldump -uroot -p<password> cocktail_bar > /backup/db_$(date +\%Y\%m\%d).sql
```

---

## 项目结构说明

```
cocktail-bar-system/
├── backend/                # 后端代码
│   ├── src/
│   │   └── main/
│   │       ├── java/      # Java 源码
│   │       └── resources/ # 配置文件
│   ├── pom.xml            # Maven 配置
│   └── Dockerfile         # 后端镜像
│
├── frontend/              # 前端代码
│   ├── src/
│   │   ├── views/        # 页面组件
│   │   ├── api/          # API 接口
│   │   └── router/       # 路由配置
│   ├── package.json      # NPM 配置
│   └── Dockerfile        # 前端镜像
│
├── database/             # 数据库脚本
│   ├── init.sql          # 表结构
│   └── data.sql          # 测试数据
│
├── docs/                 # 文档
│   ├── API.md           # API 文档
│   ├── DATABASE.md      # 数据库设计
│   └── PROJECT.md       # 项目总览
│
├── docker-compose.yml    # Docker 编排
├── start.sh             # 完整启动脚本
├── start-db-only.sh     # 仅启动数据库
└── stop.sh              # 停止脚本
```

---

## 开发团队

**项目名称：** 鸡尾酒收银系统  
**版本：** v1.0.0  
**创建时间：** 2024-06-24  
**技术栈：** Spring Boot 3 + Vue 3 + MySQL + Redis  
**License：** MIT

---

## 联系方式

遇到问题？
- 查看文档：`docs/` 目录
- 提交 Issue
- 或联系开发团队

**祝你使用愉快！🍸**
