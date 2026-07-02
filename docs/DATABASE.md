# 数据库设计文档

## 核心表说明

### 1. cocktail_recipe（鸡尾酒配方表）

存储鸡尾酒配方的基本信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| name | VARCHAR(100) | 鸡尾酒名称 |
| name_en | VARCHAR(100) | 英文名称 |
| category | VARCHAR(50) | 分类（朗姆基/伏特加基等） |
| taste_tags | VARCHAR(200) | 口味标签 JSON |
| price | DECIMAL(10,2) | 售价 |
| cost_price | DECIMAL(10,2) | 成本价（自动计算） |
| image_url | VARCHAR(200) | 图片URL |
| steps | TEXT | 制作步骤 |
| description | VARCHAR(500) | 描述 |
| alcohol_content | VARCHAR(50) | 酒精度 |
| status | TINYINT | 状态 1在售 0下架 |
| sales_count | INT | 销量统计 |
| created_at | TIMESTAMP | 创建时间 |

### 2. ingredient（原料表）

存储所有原料的库存信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| name | VARCHAR(100) | 原料名称 |
| type | VARCHAR(50) | 类型（基酒/果汁/糖浆/配料/装饰） |
| stock | DECIMAL(10,2) | 库存数量 |
| unit | VARCHAR(10) | 单位（ml/瓶/个/片） |
| min_stock | DECIMAL(10,2) | 最小库存预警值 |
| cost_price | DECIMAL(10,2) | 进货单价 |
| supplier | VARCHAR(100) | 供应商 |
| status | TINYINT | 状态 1启用 0停用 |

### 3. recipe_ingredient（配方原料关联表）

存储配方与原料的关联关系。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| recipe_id | BIGINT | 配方ID |
| ingredient_id | BIGINT | 原料ID |
| quantity | DECIMAL(10,2) | 用量 |
| unit | VARCHAR(10) | 单位 |
| is_optional | TINYINT | 是否可选 1是 0否 |

### 4. bar_order（订单主表）

存储订单基本信息。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| order_no | VARCHAR(32) | 订单号 |
| table_id | BIGINT | 桌台ID |
| session_id | VARCHAR(50) | 会话ID |
| total_amount | DECIMAL(10,2) | 总金额 |
| discount_amount | DECIMAL(10,2) | 优惠金额 |
| actual_amount | DECIMAL(10,2) | 实付金额 |
| pay_type | TINYINT | 支付方式 |
| status | TINYINT | 状态 0待支付 1已支付 |
| created_at | TIMESTAMP | 创建时间 |

### 5. order_detail（订单明细表）

存储订单的商品明细。

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| order_id | BIGINT | 订单ID |
| recipe_id | BIGINT | 配方ID |
| item_name | VARCHAR(100) | 商品名称 |
| quantity | INT | 数量 |
| price | DECIMAL(10,2) | 单价 |
| total | DECIMAL(10,2) | 小计 |
| status | TINYINT | 制作状态 0待制作 1制作中 2已完成 |

## 核心业务流程

### 下单流程

1. 用户点单 → 添加到购物车
2. 检查配方库存是否充足（`checkRecipeStock`）
3. 创建订单记录（`bar_order` + `order_detail`）
4. **自动扣减原料库存**（关键步骤）
5. 记录原料消耗明细（`ingredient_usage`）
6. 更新配方销量
7. 支付完成

### 库存自动扣减逻辑

```sql
-- 示例：卖出1杯莫吉托
-- 1. 查询配方原料
SELECT * FROM recipe_ingredient WHERE recipe_id = 1;

-- 2. 逐个扣减原料库存
UPDATE ingredient SET stock = stock - 45 WHERE id = 1 AND stock >= 45;  -- 白朗姆酒
UPDATE ingredient SET stock = stock - 20 WHERE id = 9 AND stock >= 20;  -- 青柠汁
-- ...

-- 3. 记录消耗
INSERT INTO ingredient_usage (order_detail_id, ingredient_id, quantity) VALUES (?, ?, ?);
```

## 索引设计

```sql
-- 配方表索引
CREATE INDEX idx_category ON cocktail_recipe(category);
CREATE INDEX idx_status ON cocktail_recipe(status);
CREATE INDEX idx_sales ON cocktail_recipe(sales_count);

-- 原料表索引
CREATE INDEX idx_type ON ingredient(type);
CREATE INDEX idx_name ON ingredient(name);

-- 订单表索引
CREATE INDEX idx_order_no ON bar_order(order_no);
CREATE INDEX idx_table ON bar_order(table_id);
CREATE INDEX idx_member ON bar_order(member_id);
CREATE INDEX idx_create_time ON bar_order(created_at);
```

## 数据备份建议

1. **每日备份**：凌晨2点自动备份到本地和OSS
2. **保留策略**：本地保留7天，OSS保留30天
3. **备份命令**：
```bash
mysqldump -u root -p cocktail_bar > backup_$(date +%Y%m%d).sql
```
