package com.cashregister.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 配方原料关联实体
 */
@Data
@TableName("recipe_ingredient")
public class RecipeIngredient {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long recipeId;

    private Long ingredientId;

    private BigDecimal quantity;

    private String unit;

    private Integer isOptional;

    private Integer sortOrder;
}
