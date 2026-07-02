package com.cocktail.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cocktail.entity.OrderDetail;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单明细 Mapper
 */
@Mapper
public interface OrderDetailMapper extends BaseMapper<OrderDetail> {
}
