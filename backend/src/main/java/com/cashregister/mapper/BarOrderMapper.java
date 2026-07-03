package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.BarOrder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单 Mapper
 */
@Mapper
public interface BarOrderMapper extends BaseMapper<BarOrder> {
}
