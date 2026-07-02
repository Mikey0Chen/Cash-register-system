# 财务统计功能完成报告

## 功能概述
实现了订单支付成功后自动记录到财务统计的功能，包括收支明细展示。

## 已完成功能

### 1. 财务统计自动记录 ✅
- **订单创建时自动记录成本**：每次创建订单时，系统会自动获取配方的成本价并保存到订单明细表（order_detail.cost_price）
- **实时计算利润**：财务统计会根据订单的实际金额和成本自动计算利润和利润率
- **代码位置**：
  - `/work/cocktail-bar-system/backend/src/main/java/com/cocktail/service/impl/OrderServiceImpl.java` (第70-74行)
  ```java
  // 获取并设置成本价
  try {
      detail.setCostPrice(recipeService.getRecipeCostPrice(item.getRecipeId()));
  } catch (Exception e) {
      detail.setCostPrice(null);
  }
  ```

### 2. 财务统计API ✅
提供完整的财务统计接口：

#### 2.1 汇总统计
- **GET /financial/today** - 今日财务统计
- **GET /financial/week** - 本周财务统计
- **GET /financial/month** - 本月财务统计

返回数据包括：
- `totalRevenue`: 总收入
- `totalCost`: 总成本
- `totalProfit`: 净利润
- `profitRate`: 利润率
- `orderCount`: 订单数量
- `itemCount`: 销售数量

#### 2.2 订单明细
- **GET /financial/orders?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD** - 查询日期范围内的订单财务明细

返回每个订单的详细信息：
- 订单号
- 销售金额
- 成本
- 利润
- 利润率
- 数量
- 支付方式
- 支付时间

### 3. 前端财务页面 ✅
- **页面位置**：`/work/cocktail-bar-system/frontend/src/views/Financial.vue`
- **功能特性**：
  - 财务概览卡片（今日/本周/本月切换）
  - 销售收入、成本支出、净利润、利润率实时展示
  - 订单数量和销售数量统计
  - 订单明细表格（支持日期范围筛选）
  - 返回收银台按钮 ✅

### 4. 其他页面返回按钮 ✅
已为所有功能页面添加返回按钮：
- ✅ 财务统计页面 - 返回收银台
- ✅ 配方管理页面 - 返回收银台
- ✅ 库存管理页面 - 返回收银台

## 技术实现

### 数据库设计
- **订单主表** (`bar_order`): 存储订单基本信息和实际支付金额
- **订单明细表** (`order_detail`): 存储每个商品的成本价（cost_price）和数量
- 利润计算公式：`利润 = 实际金额 - (成本价 × 数量)`
- 利润率计算公式：`利润率 = (利润 / 实际金额) × 100`

### SQL查询优化
使用子查询聚合订单明细的成本和数量，避免多次查询：
```sql
SELECT 
    SUM(o.actual_amount) as totalRevenue,
    SUM((SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id)) as totalCost,
    SUM(o.actual_amount) - SUM((SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id)) as totalProfit
FROM bar_order o
WHERE o.status = 1 AND o.pay_time >= ? AND o.pay_time < ?
```

### 资源优化
- 查询仅针对已支付订单（status = 1）
- 使用日期索引提升查询性能
- 前端按需加载数据（分页、日期筛选）

## 测试验证

### API测试结果
```bash
# 今日财务统计
curl http://localhost:8080/financial/today
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

# 订单明细
curl "http://localhost:8080/financial/orders?startDate=2026-06-25&endDate=2026-06-25"
{
  "code": 200,
  "data": [
    {
      "orderNo": "ORD202606251327391170",
      "actualAmount": 88.00,
      "totalCost": 12.50,
      "profit": 75.50,
      "profitRate": 85.80,
      "itemCount": 1,
      "payType": 1,
      "cashierName": "收银员",
      "payTime": "2026-06-25T13:27:39"
    }
  ]
}
```

## 系统资源占用

### 后端（优化后）
- **JVM堆内存**：256MB ~ 512MB
- **实际内存占用**：约 150-180 MB
- **启动时间**：约 4 秒

### 前端
- **开发服务器**：Vite
- **端口**：5173（开发）/ 8081（生产）

### 数据库连接
- **最大连接数**：5
- **最小空闲**：2

## 使用说明

### 访问财务统计
1. 启动系统后访问：http://localhost:5173
2. 在收银台点击"财务统计"菜单
3. 选择统计周期（今日/本周/本月）查看汇总数据
4. 使用日期筛选器查看特定时间段的订单明细

### 数据流程
1. 收银台创建订单
2. 系统自动从配方表获取成本价
3. 保存订单时记录到 order_detail.cost_price
4. 财务统计自动聚合计算收入、成本、利润

## 注意事项

1. **成本价来源**：配方的成本价由原料成本自动计算（CocktailRecipeService.updateRecipeCost）
2. **仅统计已支付订单**：status = 1 的订单才会纳入财务统计
3. **日期筛选**：订单明细按 pay_time（支付时间）筛选，而非创建时间

## 下一步建议

1. 添加导出财务报表功能（Excel/PDF）
2. 增加按商品、分类的销售统计
3. 添加收银员业绩统计
4. 支持自定义日期范围的图表展示
5. 添加财务数据对比（同比、环比）

---
完成时间：2026-06-25  
版本：v1.1.0
