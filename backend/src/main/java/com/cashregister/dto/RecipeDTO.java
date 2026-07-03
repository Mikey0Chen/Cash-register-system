package com.cashregister.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 创建/更新鸡尾酒配方 DTO
 */
@Data
public class RecipeDTO {

    private Long id;

    @NotBlank(message = "鸡尾酒名称不能为空")
    private String name;

    private String nameEn;

    @NotBlank(message = "分类不能为空")
    private String category;

    private List<String> tasteTags;

    @NotNull(message = "售价不能为空")
    private BigDecimal price;

    private BigDecimal costPrice;

    private String imageUrl;

    private String steps;

    private String description;

    private String alcoholContent;

    private Integer status;

    private Integer sortOrder;

    private List<RecipeIngredientDTO> ingredients;
}
