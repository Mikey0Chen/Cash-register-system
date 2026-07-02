package com.cocktail.dto;

import lombok.Data;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 创建订单DTO
 */
@Data
public class CreateOrderDTO {
    /**
     * 桌台ID
     */
    private Long tableId;

    /**
     * 订单类型 1堂食 2外带
     */
    @NotNull(message = "订单类型不能为空")
    private Integer orderType;

    /**
     * 支付方式 1现金 2微信 3支付宝 4会员卡
     */
    @NotNull(message = "支付方式不能为空")
    private Integer payType;

    /**
     * 会员ID
     */
    private Long memberId;

    /**
     * 总金额
     */
    @NotNull(message = "总金额不能为空")
    private BigDecimal totalAmount;

    /**
     * 优惠金额
     */
    private BigDecimal discountAmount;

    /**
     * 实付金额
     */
    @NotNull(message = "实付金额不能为空")
    private BigDecimal actualAmount;

    /**
     * 备注
     */
    private String remark;

    /**
     * 订单明细列表
     */
    @NotNull(message = "订单明细不能为空")
    private List<OrderItemDTO> items;

    @Data
    public static class OrderItemDTO {
        /**
         * 配方ID
         */
        @NotNull(message = "配方ID不能为空")
        private Long recipeId;

        /**
         * 商品名称
         */
        @NotNull(message = "商品名称不能为空")
        private String itemName;

        /**
         * 数量
         */
        @NotNull(message = "数量不能为空")
        private Integer quantity;

        /**
         * 单价
         */
        @NotNull(message = "单价不能为空")
        private BigDecimal price;

        /**
         * 小计
         */
        @NotNull(message = "小计不能为空")
        private BigDecimal total;

        /**
         * 备注
         */
        private String remark;
    }
}
