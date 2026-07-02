-- ============================================
-- 鸡尾酒收银系统 - 数据库初始化脚本
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 鸡尾酒配方表
-- ----------------------------
DROP TABLE IF EXISTS `cocktail_recipe`;
CREATE TABLE `cocktail_recipe` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(100) NOT NULL COMMENT '鸡尾酒名称',
  `name_en` VARCHAR(100) DEFAULT NULL COMMENT '英文名称',
  `category` VARCHAR(50) DEFAULT NULL COMMENT '分类（朗姆基/伏特加基/威士忌基/无酒精）',
  `taste_tags` VARCHAR(200) DEFAULT NULL COMMENT '口味标签 JSON ["清爽","果香","微甜"]',
  `price` DECIMAL(10,2) NOT NULL COMMENT '售价',
  `cost_price` DECIMAL(10,2) DEFAULT NULL COMMENT '成本价',
  `image_url` VARCHAR(200) DEFAULT NULL COMMENT '图片URL',
  `steps` TEXT COMMENT '制作步骤',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '描述',
  `alcohol_content` VARCHAR(50) DEFAULT NULL COMMENT '酒精度',
  `status` TINYINT DEFAULT 1 COMMENT '状态 1在售 0下架',
  `sales_count` INT DEFAULT 0 COMMENT '销量统计',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_sales` (`sales_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='鸡尾酒配方表';

-- ----------------------------
-- 2. 原料表
-- ----------------------------
DROP TABLE IF EXISTS `ingredient`;
CREATE TABLE `ingredient` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(100) NOT NULL COMMENT '原料名称',
  `type` VARCHAR(50) DEFAULT NULL COMMENT '类型（基酒/果汁/糖浆/配料/装饰）',
  `stock` DECIMAL(10,2) DEFAULT 0.00 COMMENT '库存数量',
  `unit` VARCHAR(10) DEFAULT 'ml' COMMENT '单位（ml/瓶/个/片）',
  `min_stock` DECIMAL(10,2) DEFAULT 0.00 COMMENT '最小库存预警值',
  `cost_price` DECIMAL(10,2) DEFAULT NULL COMMENT '进货单价',
  `supplier` VARCHAR(100) DEFAULT NULL COMMENT '供应商',
  `barcode` VARCHAR(50) DEFAULT NULL COMMENT '条码',
  `status` TINYINT DEFAULT 1 COMMENT '状态 1启用 0停用',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='原料库存表';

-- ----------------------------
-- 3. 配方原料关联表
-- ----------------------------
DROP TABLE IF EXISTS `recipe_ingredient`;
CREATE TABLE `recipe_ingredient` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `recipe_id` BIGINT NOT NULL COMMENT '配方ID',
  `ingredient_id` BIGINT NOT NULL COMMENT '原料ID',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT '用量',
  `unit` VARCHAR(10) DEFAULT 'ml' COMMENT '单位',
  `is_optional` TINYINT DEFAULT 0 COMMENT '是否可选 1是 0否',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_recipe` (`recipe_id`),
  KEY `idx_ingredient` (`ingredient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配方原料关联表';

-- ----------------------------
-- 4. 桌台表
-- ----------------------------
DROP TABLE IF EXISTS `bar_table`;
CREATE TABLE `bar_table` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `table_no` VARCHAR(20) NOT NULL COMMENT '桌号（A01/吧台1）',
  `area` VARCHAR(50) DEFAULT NULL COMMENT '区域（卡座/散台/吧台）',
  `capacity` INT DEFAULT 4 COMMENT '容纳人数',
  `status` TINYINT DEFAULT 0 COMMENT '状态 0空闲 1使用中 2预定 3清洁中',
  `open_time` TIMESTAMP NULL DEFAULT NULL COMMENT '开台时间',
  `session_id` VARCHAR(50) DEFAULT NULL COMMENT '当前会话ID',
  `qr_code` VARCHAR(200) DEFAULT NULL COMMENT '桌台二维码（扫码点单）',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_table_no` (`table_no`),
  KEY `idx_status` (`status`),
  KEY `idx_session` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='桌台表';

-- ----------------------------
-- 5. 订单主表
-- ----------------------------
DROP TABLE IF EXISTS `bar_order`;
CREATE TABLE `bar_order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
  `table_id` BIGINT DEFAULT NULL COMMENT '桌台ID',
  `session_id` VARCHAR(50) DEFAULT NULL COMMENT '会话ID',
  `total_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '总金额',
  `discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '优惠金额',
  `actual_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '实付金额',
  `pay_type` TINYINT DEFAULT NULL COMMENT '支付方式 1现金 2微信 3支付宝 4会员卡',
  `member_id` BIGINT DEFAULT NULL COMMENT '会员ID',
  `bartender_id` BIGINT DEFAULT NULL COMMENT '调酒师ID',
  `cashier_id` BIGINT DEFAULT NULL COMMENT '收银员ID',
  `status` TINYINT DEFAULT 0 COMMENT '状态 0待支付 1已支付 2已取消 3已退款',
  `order_type` TINYINT DEFAULT 1 COMMENT '订单类型 1堂食 2外带',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `pay_time` TIMESTAMP NULL DEFAULT NULL COMMENT '支付时间',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_table` (`table_id`),
  KEY `idx_session` (`session_id`),
  KEY `idx_member` (`member_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- ----------------------------
-- 6. 订单明细表
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `recipe_id` BIGINT DEFAULT NULL COMMENT '配方ID',
  `item_name` VARCHAR(100) NOT NULL COMMENT '商品名称',
  `item_type` TINYINT DEFAULT 1 COMMENT '商品类型 1鸡尾酒 2小食 3瓶装酒',
  `quantity` INT NOT NULL COMMENT '数量',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `total` DECIMAL(10,2) NOT NULL COMMENT '小计',
  `cost_price` DECIMAL(10,2) DEFAULT NULL COMMENT '成本价',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注（少冰/去薄荷）',
  `status` TINYINT DEFAULT 0 COMMENT '制作状态 0待制作 1制作中 2已完成',
  `bartender_id` BIGINT DEFAULT NULL COMMENT '制作人ID',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_recipe` (`recipe_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- ----------------------------
-- 7. 原料消耗记录表
-- ----------------------------
DROP TABLE IF EXISTS `ingredient_usage`;
CREATE TABLE `ingredient_usage` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_detail_id` BIGINT NOT NULL COMMENT '订单明细ID',
  `ingredient_id` BIGINT NOT NULL COMMENT '原料ID',
  `ingredient_name` VARCHAR(100) DEFAULT NULL COMMENT '原料名称（冗余）',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT '消耗量',
  `unit` VARCHAR(10) DEFAULT 'ml' COMMENT '单位',
  `cost_price` DECIMAL(10,2) DEFAULT NULL COMMENT '成本价',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_detail` (`order_detail_id`),
  KEY `idx_ingredient` (`ingredient_id`),
  KEY `idx_create_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='原料消耗记录表';

-- ----------------------------
-- 8. 库存变动记录表
-- ----------------------------
DROP TABLE IF EXISTS `stock_record`;
CREATE TABLE `stock_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `ingredient_id` BIGINT NOT NULL COMMENT '原料ID',
  `type` TINYINT NOT NULL COMMENT '类型 1入库 2出库(销售) 3盘点 4损耗',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT '变动数量（正负）',
  `before_stock` DECIMAL(10,2) DEFAULT NULL COMMENT '变动前库存',
  `after_stock` DECIMAL(10,2) DEFAULT NULL COMMENT '变动后库存',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_ingredient` (`ingredient_id`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存变动记录表';

-- ----------------------------
-- 9. 会员表
-- ----------------------------
DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `phone` VARCHAR(11) NOT NULL COMMENT '手机号',
  `name` VARCHAR(50) DEFAULT NULL COMMENT '姓名',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `avatar` VARCHAR(200) DEFAULT NULL COMMENT '头像',
  `gender` TINYINT DEFAULT 0 COMMENT '性别 0未知 1男 2女',
  `birthday` DATE DEFAULT NULL COMMENT '生日',
  `balance` DECIMAL(10,2) DEFAULT 0.00 COMMENT '储值余额',
  `points` INT DEFAULT 0 COMMENT '积分',
  `level` TINYINT DEFAULT 1 COMMENT '等级 1普通 2银卡 3金卡 4黑卡',
  `favorite_cocktails` TEXT COMMENT '喜好配方ID JSON数组',
  `custom_recipes` TEXT COMMENT '定制配方 JSON',
  `total_consume` DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计消费',
  `visit_count` INT DEFAULT 0 COMMENT '到店次数',
  `last_visit_time` TIMESTAMP NULL DEFAULT NULL COMMENT '最后到店时间',
  `status` TINYINT DEFAULT 1 COMMENT '状态 1正常 0冻结',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_level` (`level`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

-- ----------------------------
-- 10. 会员充值记录表
-- ----------------------------
DROP TABLE IF EXISTS `member_recharge`;
CREATE TABLE `member_recharge` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `member_id` BIGINT NOT NULL COMMENT '会员ID',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '充值金额',
  `bonus` DECIMAL(10,2) DEFAULT 0.00 COMMENT '赠送金额',
  `actual_amount` DECIMAL(10,2) NOT NULL COMMENT '实际到账',
  `pay_type` TINYINT DEFAULT NULL COMMENT '支付方式 1现金 2微信 3支付宝',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作员ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作员姓名',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_member` (`member_id`),
  KEY `idx_create_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员充值记录表';

-- ----------------------------
-- 11. 员工表
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '密码（加密）',
  `real_name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
  `phone` VARCHAR(11) DEFAULT NULL COMMENT '手机号',
  `role` TINYINT NOT NULL COMMENT '角色 1管理员 2收银员 3调酒师 4服务员',
  `status` TINYINT DEFAULT 1 COMMENT '状态 1在职 0离职',
  `avatar` VARCHAR(200) DEFAULT NULL COMMENT '头像',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- ----------------------------
-- 12. 财务流水表
-- ----------------------------
DROP TABLE IF EXISTS `transaction`;
CREATE TABLE `transaction` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` VARCHAR(32) DEFAULT NULL COMMENT '关联订单号',
  `type` TINYINT NOT NULL COMMENT '类型 1销售收入 2退款 3会员充值 4采购支出',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '金额',
  `pay_type` TINYINT DEFAULT NULL COMMENT '支付方式',
  `member_id` BIGINT DEFAULT NULL COMMENT '会员ID',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作员ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作员姓名',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_no`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='财务流水表';

-- ----------------------------
-- 初始化管理员账号
-- ----------------------------
INSERT INTO `employee` (`username`, `password`, `real_name`, `phone`, `role`, `status`)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', '13800138000', 1, 1);
-- 密码：admin123

SET FOREIGN_KEY_CHECKS = 1;
