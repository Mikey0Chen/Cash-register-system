package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.RecipeIngredient;
import org.apache.ibatis.annotations.Mapper;

/**
 * 配方原料关联 Mapper
 */
@Mapper
public interface RecipeIngredientMapper extends BaseMapper<RecipeIngredient> {
}
