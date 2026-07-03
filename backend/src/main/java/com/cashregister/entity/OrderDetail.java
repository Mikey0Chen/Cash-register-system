package com.cashregister.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单明细实体
 */
@Data
@TableName("order_detail")
public class OrderDetail {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long recipeId;

    private String itemName;

    private Integer itemType;

    private Integer quantity;

    private BigDecimal price;

    private BigDecimal total;

    private BigDecimal costPrice;

    private String remark;

    private Integer status;

    private Long bartenderId;

    private LocalDateTime createdAt;
}
