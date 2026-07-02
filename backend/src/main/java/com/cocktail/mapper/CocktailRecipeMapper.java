package com.cocktail.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cocktail.entity.CocktailRecipe;
import org.apache.ibatis.annotations.Mapper;

/**
 * 鸡尾酒配方 Mapper
 */
@Mapper
public interface CocktailRecipeMapper extends BaseMapper<CocktailRecipe> {
}
