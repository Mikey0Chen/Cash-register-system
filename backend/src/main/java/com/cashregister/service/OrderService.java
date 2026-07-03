package com.cashregister.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cashregister.dto.CreateOrderDTO;
import com.cashregister.entity.BarOrder;

/**
 * 订单服务
 */
public interface OrderService {

    /**
     * 创建订单
     */
    Long createOrder(CreateOrderDTO dto);

    /**
     * 分页查询订单
     */
    Page<BarOrder> getOrderPage(int current, int size, Integer status);

    /**
     * 查询订单详情
     */
    BarOrder getOrderDetail(Long orderId);

    /**
     * 取消订单
     */
    void cancelOrder(Long orderId);
}
