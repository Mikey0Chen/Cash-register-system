package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.OrderDetail;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单明细 Mapper
 */
@Mapper
public interface OrderDetailMapper extends BaseMapper<OrderDetail> {
}
