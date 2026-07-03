package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.Ingredient;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;

/**
 * 原料 Mapper
 */
@Mapper
public interface IngredientMapper extends BaseMapper<Ingredient> {

    /**
     * 扣减库存
     */
    @Update("UPDATE ingredient SET stock = stock - #{quantity} WHERE id = #{id} AND stock >= #{quantity}")
    int deductStock(@Param("id") Long id, @Param("quantity") BigDecimal quantity);

    /**
     * 增加库存
     */
    @Update("UPDATE ingredient SET stock = stock + #{quantity} WHERE id = #{id}")
    int addStock(@Param("id") Long id, @Param("quantity") BigDecimal quantity);
}
