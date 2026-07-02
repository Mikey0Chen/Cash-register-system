-- ============================================
-- 测试数据脚本 - 包含示例鸡尾酒配方和原料
-- ============================================

SET NAMES utf8mb4;

-- ----------------------------
-- 1. 插入原料数据
-- ----------------------------

-- 基酒类
INSERT INTO `ingredient` (`name`, `type`, `stock`, `unit`, `min_stock`, `cost_price`, `supplier`) VALUES
('白朗姆酒', '基酒', 5000.00, 'ml', 1000.00, 0.15, '进口酒商'),
('金朗姆酒', '基酒', 3000.00, 'ml', 1000.00, 0.18, '进口酒商'),
('伏特加', '基酒', 4000.00, 'ml', 1000.00, 0.12, '进口酒商'),
('金酒', '基酒', 3500.00, 'ml', 1000.00, 0.16, '进口酒商'),
('龙舌兰', '基酒', 3000.00, 'ml', 1000.00, 0.20, '进口酒商'),
('威士忌', '基酒', 4000.00, 'ml', 1000.00, 0.25, '进口酒商'),
('白兰地', '基酒', 2000.00, 'ml', 500.00, 0.30, '进口酒商'),
('朗姆酒黑标', '基酒', 2000.00, 'ml', 500.00, 0.22, '进口酒商');

-- 果汁类
INSERT INTO `ingredient` (`name`, `type`, `stock`, `unit`, `min_stock`, `cost_price`, `supplier`) VALUES
('青柠汁', '果汁', 2000.00, 'ml', 500.00, 0.02, '本地供应商'),
('柠檬汁', '果汁', 2000.00, 'ml', 500.00, 0.02, '本地供应商'),
('橙汁', '果汁', 3000.00, 'ml', 800.00, 0.015, '本地供应商'),
('菠萝汁', '果汁', 2000.00, 'ml', 500.00, 0.018, '本地供应商'),
('蔓越莓汁', '果汁', 1500.00, 'ml', 500.00, 0.025, '本地供应商'),
('西柚汁', '果汁', 1500.00, 'ml', 500.00, 0.022, '本地供应商');

-- 糖浆类
INSERT INTO `ingredient` (`name`, `type`, `stock`, `unit`, `min_stock`, `cost_price`, `supplier`) VALUES
('简单糖浆', '糖浆', 3000.00, 'ml', 500.00, 0.008, '本地供应商'),
('石榴糖浆', '糖浆', 1000.00, 'ml', 300.00, 0.015, '本地供应商'),
('薄荷糖浆', '糖浆', 800.00, 'ml', 200.00, 0.018, '本地供应商'),
('香草糖浆', '糖浆', 800.00, 'ml', 200.00, 0.018, '本地供应商');

-- 配料类
INSERT INTO `ingredient` (`name`, `type`, `stock`, `unit`, `min_stock`, `cost_price`, `supplier`) VALUES
('苏打水', '配料', 5000.00, 'ml', 1000.00, 0.005, '本地供应商'),
('汤力水', '配料', 3000.00, 'ml', 1000.00, 0.008, '本地供应商'),
('可乐', '配料', 3000.00, 'ml', 1000.00, 0.006, '本地供应商'),
('雪碧', '配料', 2000.00, 'ml', 500.00, 0.006, '本地供应商'),
('姜汁啤酒', '配料', 1500.00, 'ml', 500.00, 0.012, '本地供应商'),
('安格斯特拉苦精', '配料', 500.00, 'ml', 100.00, 0.08, '进口酒商'),
('橙味苦精', '配料', 300.00, 'ml', 100.00, 0.08, '进口酒商');

-- 装饰类
INSERT INTO `ingredient` (`name`, `type`, `stock`, `unit`, `min_stock`, `cost_price`, `supplier`) VALUES
('薄荷叶', '装饰', 200.00, '片', 50.00, 0.05, '本地供应商'),
('青柠片', '装饰', 100.00, '片', 30.00, 0.08, '本地供应商'),
('柠檬片', '装饰', 100.00, '片', 30.00, 0.08, '本地供应商'),
('橙片', '装饰', 80.00, '片', 30.00, 0.10, '本地供应商'),
('樱桃', '装饰', 150.00, '个', 50.00, 0.20, '本地供应商'),
('迷迭香', '装饰', 50.00, '支', 20.00, 0.30, '本地供应商'),
('冰块', '配料', 10000.00, 'g', 2000.00, 0.001, '自制');

-- ----------------------------
-- 2. 插入鸡尾酒配方数据
-- ----------------------------

-- 莫吉托 (Mojito)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('莫吉托', 'Mojito', '朗姆基酒', '["清爽","薄荷","微甜"]', 58.00, 12.50, '古巴的经典鸡尾酒，清爽薄荷与朗姆酒的完美结合', '10-12%',
'1. 在杯中加入薄荷叶和糖浆，用捣棒轻轻捣碎\n2. 加入青柠汁和白朗姆酒\n3. 加满冰块，倒入苏打水\n4. 轻轻搅拌，用薄荷叶和青柠片装饰',
158, 1);

-- 配方原料关联
INSERT INTO `recipe_ingredient` (`recipe_id`, `ingredient_id`, `quantity`, `unit`, `sort_order`) VALUES
(1, 1, 45.00, 'ml', 1),  -- 白朗姆酒
(1, 9, 20.00, 'ml', 2),  -- 青柠汁
(1, 13, 10.00, 'ml', 3), -- 简单糖浆
(1, 17, 100.00, 'ml', 4), -- 苏打水
(1, 25, 6.00, '片', 5),  -- 薄荷叶
(1, 26, 2.00, '片', 6),  -- 青柠片
(1, 32, 200.00, 'g', 7); -- 冰块

-- 长岛冰茶 (Long Island Iced Tea)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('长岛冰茶', 'Long Island Iced Tea', '伏特加基酒', '["浓郁","多层次","烈性"]', 68.00, 18.00, '经典的强劲鸡尾酒，看似冰茶实则烈酒', '22-28%',
'1. 在调酒器中加入所有基酒和柠檬汁\n2. 加冰摇匀\n3. 滤入盛满冰块的杯中\n4. 倒入可乐至杯口\n5. 用柠檬片装饰',
125, 2);

INSERT INTO `recipe_ingredient` (`recipe_id`, `ingredient_id`, `quantity`, `unit`, `sort_order`) VALUES
(2, 1, 15.00, 'ml', 1),  -- 白朗姆酒
(2, 3, 15.00, 'ml', 2),  -- 伏特加
(2, 4, 15.00, 'ml', 3),  -- 金酒
(2, 5, 15.00, 'ml', 4),  -- 龙舌兰
(2, 10, 25.00, 'ml', 5), -- 柠檬汁
(2, 13, 15.00, 'ml', 6), -- 简单糖浆
(2, 19, 50.00, 'ml', 7), -- 可乐
(2, 27, 1.00, '片', 8),  -- 柠檬片
(2, 32, 200.00, 'g', 9); -- 冰块

-- 玛格丽特 (Margarita)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('玛格丽特', 'Margarita', '龙舌兰基酒', '["酸甜","清爽","盐边"]', 62.00, 14.00, '墨西哥的国酒龙舌兰调制而成，酸甜可口', '15-18%',
'1. 用青柠片涂抹杯口，沾盐\n2. 在调酒器中加入龙舌兰、橙汁、青柠汁和糖浆\n3. 加冰摇匀\n4. 滤入盐边杯中\n5. 用青柠片装饰',
98, 3);

INSERT INTO `recipe_ingredient` (`recipe_id`, `ingredient_id`, `quantity`, `unit`, `sort_order`) VALUES
(3, 5, 50.00, 'ml', 1),  -- 龙舌兰
(3, 11, 25.00, 'ml', 2), -- 橙汁
(3, 9, 20.00, 'ml', 3),  -- 青柠汁
(3, 13, 10.00, 'ml', 4), -- 简单糖浆
(3, 26, 1.00, '片', 5),  -- 青柠片
(3, 32, 150.00, 'g', 6); -- 冰块

-- 血腥玛丽 (Bloody Mary)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('血腥玛丽', 'Bloody Mary', '伏特加基酒', '["咸鲜","番茄","微辣"]', 55.00, 13.00, '经典的早午餐鸡尾酒，番茄汁与伏特加的完美搭配', '12-15%',
'1. 在杯中加入冰块\n2. 加入伏特加、番茄汁、柠檬汁\n3. 加入盐、黑胡椒、辣椒酱调味\n4. 轻轻搅拌\n5. 用芹菜和柠檬片装饰',
76, 4);

-- 威士忌酸 (Whiskey Sour)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('威士忌酸', 'Whiskey Sour', '威士忌基酒', '["酸甜","醇厚","泡沫"]', 65.00, 16.00, '威士忌与柠檬汁的经典组合，泡沫细腻', '18-22%',
'1. 在调酒器中加入威士忌、柠檬汁、糖浆和蛋清\n2. 干摇（不加冰）15秒\n3. 加冰再摇15秒\n4. 滤入岩石杯\n5. 用柠檬片和樱桃装饰',
89, 5);

INSERT INTO `recipe_ingredient` (`recipe_id`, `ingredient_id`, `quantity`, `unit`, `sort_order`) VALUES
(5, 6, 60.00, 'ml', 1),  -- 威士忌
(5, 10, 30.00, 'ml', 2), -- 柠檬汁
(5, 13, 15.00, 'ml', 3), -- 简单糖浆
(5, 27, 1.00, '片', 4),  -- 柠檬片
(5, 29, 1.00, '个', 5),  -- 樱桃
(5, 32, 150.00, 'g', 6); -- 冰块

-- 蓝色夏威夷 (Blue Hawaii)
INSERT INTO `cocktail_recipe` (`name`, `name_en`, `category`, `taste_tags`, `price`, `cost_price`, `description`, `alcohol_content`, `steps`, `sales_count`, `sort_order`)
VALUES ('蓝色夏威夷', 'Blue Hawaii', '朗姆基酒', '["果香","热带","清凉"]', 58.00, 13.50, '热带风情的蓝色鸡尾酒，颜值与口感并存', '12-15%',
'1. 在调酒器中加入朗姆酒、蓝橙力娇酒、菠萝汁、柠檬汁\n2. 加冰摇匀\n3. 滤入盛满冰块的杯中\n4. 用菠萝片和樱桃装饰',
112, 6);

INSERT INTO `recipe_ingredient` (`recipe_id`, `ingredient_id`, `quantity`, `unit`, `sort_order`) VALUES
(6, 1, 40.00, 'ml', 1),  -- 白朗姆酒
(6, 12, 60.00, 'ml', 2), -- 菠萝汁
(6, 10, 20.00, 'ml', 3), -- 柠檬汁
(6, 29, 1.00, '个', 4),  -- 樱桃
(6, 32, 200.00, 'g', 5); -- 冰块

-- ----------------------------
-- 3. 插入桌台数据
-- ----------------------------
INSERT INTO `bar_table` (`table_no`, `area`, `capacity`, `status`) VALUES
('A01', '卡座区', 6, 0),
('A02', '卡座区', 6, 0),
('A03', '卡座区', 4, 0),
('B01', '散台区', 4, 0),
('B02', '散台区', 4, 0),
('B03', '散台区', 2, 0),
('B04', '散台区', 2, 0),
('C01', '吧台区', 1, 0),
('C02', '吧台区', 1, 0),
('C03', '吧台区', 1, 0);

-- ----------------------------
-- 4. 插入员工数据
-- ----------------------------
INSERT INTO `employee` (`username`, `password`, `real_name`, `phone`, `role`, `status`) VALUES
('cashier01', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张收银', '13800138001', 2, 1),
('bartender01', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李调酒', '13800138002', 3, 1),
('bartender02', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王调酒', '13800138003', 3, 1),
('waiter01', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵服务', '13800138004', 4, 1);
-- 密码统一为：admin123

-- ----------------------------
-- 5. 插入测试会员数据
-- ----------------------------
INSERT INTO `member` (`phone`, `name`, `nickname`, `balance`, `points`, `level`, `total_consume`, `visit_count`) VALUES
('13900139001', '张三', '老张', 500.00, 1250, 2, 2580.00, 15),
('13900139002', '李四', '小李', 1200.00, 3800, 3, 7650.00, 38),
('13900139003', '王五', '老王', 300.00, 680, 1, 1360.00, 8);
