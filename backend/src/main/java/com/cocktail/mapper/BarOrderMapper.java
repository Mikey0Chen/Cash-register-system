package com.cocktail.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cocktail.entity.BarOrder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单 Mapper
 */
@Mapper
public interface BarOrderMapper extends BaseMapper<BarOrder> {
}
