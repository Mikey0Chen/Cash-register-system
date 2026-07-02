# API 文档

## 基础信息

- 基础路径：`http://localhost:8080`
- 响应格式：JSON
- 字符编码：UTF-8

## 通用响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": 1234567890
}
```

## 配方管理 API

### 1. 分页查询配方列表

**接口地址：** `GET /recipe/page`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| current | Integer | 否 | 当前页码，默认1 |
| size | Integer | 否 | 每页数量，默认10 |
| category | String | 否 | 分类筛选 |
| keyword | String | 否 | 关键词搜索 |

**响应示例：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "莫吉托",
        "nameEn": "Mojito",
        "category": "朗姆基酒",
        "price": 58.00,
        "costPrice": 12.50,
        "salesCount": 158,
        "status": 1
      }
    ],
    "total": 100,
    "size": 10,
    "current": 1,
    "pages": 10
  }
}
```

### 2. 获取配方详情

**接口地址：** `GET /recipe/{id}`

**路径参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 配方ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "莫吉托",
    "nameEn": "Mojito",
    "category": "朗姆基酒",
    "tasteTags": ["清爽", "薄荷", "微甜"],
    "price": 58.00,
    "costPrice": 12.50,
    "description": "古巴的经典鸡尾酒",
    "alcoholContent": "10-12%",
    "ingredients": [
      {
        "ingredientId": 1,
        "ingredientName": "白朗姆酒",
        "ingredientType": "基酒",
        "quantity": 45.00,
        "unit": "ml",
        "stock": 5000.00
      }
    ]
  }
}
```

### 3. 创建配方

**接口地址：** `POST /recipe`

**请求体：**

```json
{
  "name": "莫吉托",
  "nameEn": "Mojito",
  "category": "朗姆基酒",
  "tasteTags": ["清爽", "薄荷", "微甜"],
  "price": 58.00,
  "description": "古巴的经典鸡尾酒",
  "alcoholContent": "10-12%",
  "ingredients": [
    {
      "ingredientId": 1,
      "quantity": 45.00,
      "unit": "ml"
    }
  ]
}
```

**响应示例：**

```json
{
  "code": 200,
  "message": "创建成功",
  "data": 1
}
```

### 4. 更新配方

**接口地址：** `PUT /recipe`

**请求体：**（同创建，需包含 id）

### 5. 删除配方

**接口地址：** `DELETE /recipe/{id}`

**响应示例：**

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

### 6. 检查配方库存

**接口地址：** `GET /recipe/check-stock/{id}`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| quantity | Integer | 是 | 需要制作的数量 |

**响应示例：**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 参数错误 |
| 500 | 系统错误 |

## 开发计划

- [x] 配方管理 API
- [ ] 原料管理 API
- [ ] 订单管理 API
- [ ] 会员管理 API
- [ ] 报表统计 API
