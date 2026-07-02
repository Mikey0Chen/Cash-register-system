package com.cocktail.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 财务统计VO
 */
@Data
public class FinancialStatVO {
    /**
     * 统计日期
     */
    private LocalDate statDate;

    /**
     * 销售收入
     */
    private BigDecimal totalRevenue = BigDecimal.ZERO;

    /**
     * 成本支出
     */
    private BigDecimal totalCost = BigDecimal.ZERO;

    /**
     * 利润
     */
    private BigDecimal totalProfit = BigDecimal.ZERO;

    /**
     * 订单数量
     */
    private Integer orderCount = 0;

    /**
     * 商品销量
     */
    private Integer itemCount = 0;

    /**
     * 利润率
     */
    private BigDecimal profitRate = BigDecimal.ZERO;
}
