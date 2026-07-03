package com.cashregister.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 鸡尾酒配方详情 VO
 */
@Data
public class CocktailRecipeVO {

    private Long id;

    private String name;

    private String nameEn;

    private String category;

    private List<String> tasteTags;

    private BigDecimal price;

    private BigDecimal costPrice;

    private String imageUrl;

    private String steps;

    private String description;

    private String alcoholContent;

    private Integer status;

    private Integer salesCount;

    private List<RecipeIngredientVO> ingredients;
}
