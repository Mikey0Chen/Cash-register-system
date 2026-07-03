package com.cashregister.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单主表实体
 */
@Data
@TableName("bar_order")
public class BarOrder {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String orderNo;

    private Long tableId;

    private String sessionId;

    private BigDecimal totalAmount;

    private BigDecimal discountAmount;

    private BigDecimal actualAmount;

    private Integer payType;

    private Long memberId;

    private Long bartenderId;

    private Long cashierId;

    private Integer status;

    private Integer orderType;

    private String remark;

    private LocalDateTime payTime;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
