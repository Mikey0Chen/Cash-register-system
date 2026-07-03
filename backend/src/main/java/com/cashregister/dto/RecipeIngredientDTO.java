package com.cashregister.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 配方原料 DTO
 */
@Data
public class RecipeIngredientDTO {

    @NotNull(message = "原料ID不能为空")
    private Long ingredientId;

    @NotNull(message = "用量不能为空")
    private BigDecimal quantity;

    private String unit;

    private Integer isOptional;

    private Integer sortOrder;
}
