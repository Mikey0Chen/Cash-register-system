package com.cocktail.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 鸡尾酒配方实体
 */
@Data
@TableName("cocktail_recipe")
public class CocktailRecipe {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String nameEn;

    private String category;

    private String tasteTags;

    private BigDecimal price;

    private BigDecimal costPrice;

    private String imageUrl;

    private String steps;

    private String description;

    private String alcoholContent;

    private Integer status;

    private Integer salesCount;

    private Integer sortOrder;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
