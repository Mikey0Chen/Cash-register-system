# 🍸 Cocktail Bar System - 鸡尾酒收银记账系统

一个专为酒吧设计的智能收银系统，支持鸡尾酒配方管理、原料自动扣减、桌台管理、会员系统等功能。

## 项目特色

- ✅ **配方管理**：标准化鸡尾酒配方，新手也能快速调制
- ✅ **原料自动扣减**：点单后自动扣减基酒、果汁等原料库存
- ✅ **桌台模式**：支持开台/换台/并台，更符合酒吧场景
- ✅ **成本核算**：实时计算每杯酒的成本和利润
- ✅ **口味推荐**：根据标签推荐鸡尾酒（清爽/浓郁/果香）
- ✅ **会员系统**：储值、积分、专属配方记录

## 技术栈

### 后端
- Spring Boot 3.2
- MyBatis-Plus 3.5
- MySQL 8.0
- Redis 7.0
- JWT 认证

### 前端
- Vue 3
- Vite 5
- Element Plus
- Pinia
- Axios

### 部署
- Docker
- Docker Compose
- Nginx

## 快速开始

### 1. 克隆项目
```bash
cd /work/cocktail-bar-system
```

### 2. 启动服务（Docker）
```bash
docker-compose up -d
```

### 3. 访问系统
- 前端地址：http://localhost
- 后端地址：http://localhost:8080
- 默认账号：admin / admin123

## 项目结构

```
cocktail-bar-system/
├── backend/              # Spring Boot 后端
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   └── resources/
│   │   └── test/
│   ├── pom.xml
│   └── Dockerfile
├── frontend/             # Vue 3 前端
│   ├── src/
│   │   ├── views/       # 页面组件
│   │   ├── components/  # 公共组件
│   │   ├── router/      # 路由配置
│   │   ├── store/       # 状态管理
│   │   └── api/         # API 接口
│   ├── package.json
│   └── Dockerfile
├── database/             # 数据库脚本
│   ├── init.sql         # 初始化表结构
│   └── data.sql         # 测试数据
├── docker/               # Docker 配置
│   └── nginx.conf       # Nginx 配置
├── docs/                 # 文档
│   ├── API.md           # API 文档
│   └── DATABASE.md      # 数据库设计
├── docker-compose.yml    # 一键部署
└── README.md
```

## 核心功能模块

### 1. 收银台模块
- 开台/换台/并台
- 鸡尾酒点单
- 购物车管理
- 多种支付方式
- 小票打印

### 2. 配方管理
- 鸡尾酒配方增删改查
- 原料关联配置
- 制作步骤说明
- 成本价/售价管理

### 3. 库存管理
- 原料入库/出库
- 库存预警
- 盘点功能
- 自动扣减

### 4. 会员管理
- 会员注册/充值
- 积分累计
- 消费记录
- 喜好记录

### 5. 报表分析
- 营业日报/月报
- 畅销酒品排行
- 原料消耗统计
- 调酒师业绩

## 开发指南

### 后端开发
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### 前端开发
```bash
cd frontend
npm install
npm run dev
```

## License

MIT License

## 联系方式

有问题或建议？欢迎提 Issue！
