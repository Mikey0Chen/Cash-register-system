# 🍸 鸡尾酒收银系统 - 项目总览

## 项目完成度

✅ **已完成**
- [x] 数据库设计（12张核心表）
- [x] 后端 Spring Boot 项目框架
- [x] 配方管理完整功能（增删改查 + 自动库存扣减）
- [x] 前端 Vue 3 项目框架
- [x] 收银台界面（商品展示、购物车、结账）
- [x] 配方管理界面（列表、详情、删除）
- [x] Docker 一键部署配置
- [x] 测试数据（6个经典鸡尾酒 + 32种原料）

🚧 **待开发**
- [ ] 原料管理完整功能
- [ ] 订单管理功能
- [ ] 会员管理功能
- [ ] 桌台管理功能
- [ ] 报表统计功能
- [ ] 用户登录/权限管理
- [ ] 小票打印功能

## 快速开始

### 方式一：Docker 一键启动（推荐）

```bash
cd /work/cocktail-bar-system
./start.sh
```

启动后访问：
- 前端：http://localhost
- 后端：http://localhost:8080

### 方式二：本地开发

**1. 启动数据库**
```bash
docker-compose up -d mysql redis
```

**2. 启动后端**
```bash
cd backend
mvn spring-boot:run
```

**3. 启动前端**
```bash
cd frontend
npm install
npm run dev
```

前端开发地址：http://localhost:5173

## 核心功能演示

### 1. 收银台（/pos）

**功能特点：**
- 按分类浏览鸡尾酒
- 实时搜索
- 购物车管理
- 多种支付方式
- 金额自动计算

**操作流程：**
1. 选择分类或搜索鸡尾酒
2. 点击商品卡片添加到购物车
3. 调整数量或删除商品
4. 点击"结账"选择支付方式
5. 确认支付完成订单

### 2. 配方管理（/recipe）

**功能特点：**
- 配方列表展示
- 查看配方详情（含原料配方）
- 删除配方（软删除）
- 销量统计
- 成本价自动计算

**核心逻辑：**
- 创建配方时自动关联原料
- 成本价 = Σ(原料成本价 × 用量)
- 下单时自动扣减原料库存

### 3. 库存管理（/ingredient）

**功能特点：**
- 原料库存展示
- 库存预警提示
- 入库/出库操作（待开发）
- 盘点功能（待开发）

## 技术架构

### 后端技术栈

```
Spring Boot 3.2.0
├── MyBatis-Plus 3.5.5    # ORM框架
├── MySQL 8.0              # 数据库
├── Redis 7.0              # 缓存
├── JWT                    # 认证（待集成）
└── Hutool                 # 工具类
```

**核心特性：**
- RESTful API 设计
- 统一响应格式
- 全局异常处理
- 参数校验
- 跨域配置
- 健康检查

### 前端技术栈

```
Vue 3.4
├── Vite 5.0               # 构建工具
├── Element Plus 2.5       # UI组件库
├── Vue Router 4.2         # 路由
├── Pinia 2.1              # 状态管理
└── Axios 1.6              # HTTP客户端
```

**核心特性：**
- Composition API
- 响应式设计
- API代理配置
- 统一请求拦截

## 数据库设计亮点

### 1. 配方与原料关联

```
cocktail_recipe (配方表)
    ↓
recipe_ingredient (关联表) ← 记录用量
    ↓
ingredient (原料表) ← 库存管理
```

### 2. 自动库存扣减

**业务流程：**
```java
点单 → 检查库存 → 创建订单 → 扣减原料 → 记录消耗
```

**关键代码：**
```java
@Transactional
public void deductRecipeStock(Long recipeId, Integer quantity) {
    // 1. 查询配方原料
    List<RecipeIngredient> ingredients = getRecipeIngredients(recipeId);
    
    // 2. 逐个扣减库存
    for (RecipeIngredient ri : ingredients) {
        BigDecimal needQuantity = ri.getQuantity() * quantity;
        ingredientMapper.deductStock(ri.getIngredientId(), needQuantity);
    }
}
```

### 3. 成本价自动计算

每次更新配方原料后，自动重新计算成本价：
```sql
成本价 = Σ(原料单价 × 用量)
```

## 测试数据说明

### 预置鸡尾酒配方

1. **莫吉托** (Mojito) - ¥58
   - 分类：朗姆基酒
   - 口味：清爽、薄荷、微甜
   - 原料：白朗姆、青柠汁、薄荷叶等

2. **长岛冰茶** (Long Island Iced Tea) - ¥68
   - 分类：伏特加基酒
   - 口味：浓郁、多层次、烈性
   - 原料：四种基酒 + 柠檬汁

3. **玛格丽特** (Margarita) - ¥62
   - 分类：龙舌兰基酒
   - 口味：酸甜、清爽、盐边

4. **血腥玛丽** (Bloody Mary) - ¥55
   - 分类：伏特加基酒
   - 口味：咸鲜、番茄、微辣

5. **威士忌酸** (Whiskey Sour) - ¥65
   - 分类：威士忌基酒
   - 口味：酸甜、醇厚、泡沫

6. **蓝色夏威夷** (Blue Hawaii) - ¥58
   - 分类：朗姆基酒
   - 口味：果香、热带、清凉

### 预置原料（32种）

- **基酒类**：白朗姆、伏特加、金酒、龙舌兰、威士忌等
- **果汁类**：青柠汁、柠檬汁、橙汁、菠萝汁等
- **糖浆类**：简单糖浆、石榴糖浆、薄荷糖浆等
- **配料类**：苏打水、汤力水、可乐、苦精等
- **装饰类**：薄荷叶、青柠片、樱桃、冰块等

### 预置员工账号

- **管理员**：admin / admin123
- **收银员**：cashier01 / admin123
- **调酒师**：bartender01 / admin123
- **服务员**：waiter01 / admin123

## 开发建议

### 后续开发优先级

**阶段一：完善核心功能**
1. 原料管理（入库、出库、盘点）
2. 订单管理（订单列表、详情、退款）
3. 用户登录和权限控制

**阶段二：增强用户体验**
1. 桌台管理（开台、换台、并台）
2. 会员管理（充值、积分、优惠）
3. 小票打印功能

**阶段三：数据分析**
1. 营业报表（日报、月报）
2. 畅销分析
3. 成本分析
4. 员工业绩统计

### 代码规范

**后端：**
- Controller 只做参数校验和路由
- Service 处理业务逻辑
- Mapper 只做数据库操作
- 使用事务保证数据一致性

**前端：**
- 组件按功能模块划分
- API 统一在 `/api` 目录管理
- 使用 Pinia 管理全局状态
- 统一错误提示处理

## 部署建议

### 生产环境配置

1. **修改默认密码**
```yaml
# docker-compose.yml
MYSQL_ROOT_PASSWORD: <强密码>
SPRING_REDIS_PASSWORD: <强密码>
```

2. **启用 HTTPS**
```bash
# 使用 Let's Encrypt 证书
certbot --nginx -d yourdomain.com
```

3. **数据备份**
```bash
# 每日自动备份
0 2 * * * /usr/local/bin/backup-cocktail-db.sh
```

4. **监控告警**
- 接入 Prometheus + Grafana
- 配置库存预警通知
- 监控服务健康状态

## 故障排查

### 常见问题

**1. 后端无法连接数据库**
```bash
# 检查 MySQL 是否启动
docker-compose ps mysql

# 查看数据库日志
docker-compose logs mysql
```

**2. 前端无法调用后端 API**
```bash
# 检查后端是否启动
curl http://localhost:8080/actuator/health

# 检查 Nginx 代理配置
docker-compose logs frontend
```

**3. 数据库初始化失败**
```bash
# 手动执行 SQL
docker exec -it cocktail-mysql mysql -uroot -p
source /docker-entrypoint-initdb.d/init.sql
```

## 项目目录说明

```
cocktail-bar-system/
├── backend/                    # 后端代码
│   ├── src/main/java/com/cocktail/
│   │   ├── controller/        # 控制器
│   │   ├── service/           # 业务逻辑
│   │   ├── mapper/            # 数据访问层
│   │   ├── entity/            # 实体类
│   │   ├── dto/               # 数据传输对象
│   │   ├── vo/                # 视图对象
│   │   ├── common/            # 通用类
│   │   ├── config/            # 配置类
│   │   └── exception/         # 异常处理
│   ├── src/main/resources/
│   │   └── application.yml    # 配置文件
│   └── pom.xml                # Maven配置
├── frontend/                   # 前端代码
│   ├── src/
│   │   ├── views/             # 页面组件
│   │   ├── components/        # 公共组件
│   │   ├── router/            # 路由配置
│   │   ├── api/               # API接口
│   │   └── utils/             # 工具函数
│   ├── package.json           # NPM配置
│   └── vite.config.js         # Vite配置
├── database/                   # 数据库脚本
│   ├── init.sql               # 表结构
│   └── data.sql               # 测试数据
├── docker/                     # Docker配置
│   └── nginx.conf             # Nginx配置
├── docs/                       # 文档
│   ├── API.md                 # API文档
│   └── DATABASE.md            # 数据库文档
├── docker-compose.yml          # Docker编排
├── start.sh                    # 启动脚本
└── README.md                   # 项目说明
```

## 联系方式

有问题或建议？欢迎：
- 提交 Issue
- 发起 Pull Request
- 或直接联系开发团队

---

**License:** MIT

**版本：** v1.0.0

**最后更新：** 2024-06-24
