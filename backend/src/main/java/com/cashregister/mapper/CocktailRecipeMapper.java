package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.CocktailRecipe;
import org.apache.ibatis.annotations.Mapper;

/**
 * 鸡尾酒配方 Mapper
 */
@Mapper
public interface CocktailRecipeMapper extends BaseMapper<CocktailRecipe> {
}
