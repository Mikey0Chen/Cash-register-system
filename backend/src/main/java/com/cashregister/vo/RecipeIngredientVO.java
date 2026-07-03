package com.cashregister.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 配方原料 VO
 */
@Data
public class RecipeIngredientVO {

    private Long ingredientId;

    private String ingredientName;

    private String ingredientType;

    private BigDecimal quantity;

    private String unit;

    private Integer isOptional;

    private BigDecimal stock;

    private Integer sortOrder;
}
