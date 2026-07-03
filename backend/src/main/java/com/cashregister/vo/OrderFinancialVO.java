package com.cashregister.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单财务明细VO
 */
@Data
public class OrderFinancialVO {
    /**
     * 订单ID
     */
    private Long orderId;

    /**
     * 订单号
     */
    private String orderNo;

    /**
     * 实付金额（销售收入）
     */
    private BigDecimal actualAmount;

    /**
     * 成本总额
     */
    private BigDecimal totalCost;

    /**
     * 利润
     */
    private BigDecimal profit;

    /**
     * 利润率
     */
    private BigDecimal profitRate;

    /**
     * 商品数量
     */
    private Integer itemCount;

    /**
     * 支付方式 1现金 2微信 3支付宝 4会员卡
     */
    private Integer payType;

    /**
     * 收银员姓名
     */
    private String cashierName;

    /**
     * 支付时间
     */
    private LocalDateTime payTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
