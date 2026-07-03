package com.cashregister.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cashregister.dto.CreateOrderDTO;
import com.cashregister.entity.BarOrder;
import com.cashregister.entity.OrderDetail;
import com.cashregister.mapper.BarOrderMapper;
import com.cashregister.mapper.OrderDetailMapper;
import com.cashregister.service.CocktailRecipeService;
import com.cashregister.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 订单服务实现
 */
@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private BarOrderMapper orderMapper;

    @Autowired
    private OrderDetailMapper orderDetailMapper;

    @Autowired
    private CocktailRecipeService recipeService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createOrder(CreateOrderDTO dto) {
        // 创建订单主表
        BarOrder order = new BarOrder();
        order.setOrderNo(generateOrderNo());
        order.setTableId(dto.getTableId());
        order.setOrderType(dto.getOrderType());
        order.setTotalAmount(dto.getTotalAmount());
        order.setDiscountAmount(dto.getDiscountAmount());
        order.setActualAmount(dto.getActualAmount());
        order.setPayType(dto.getPayType());
        order.setMemberId(dto.getMemberId());
        order.setStatus(1); // 已支付
        order.setRemark(dto.getRemark());
        order.setPayTime(LocalDateTime.now());
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        orderMapper.insert(order);

        // 创建订单明细
        for (CreateOrderDTO.OrderItemDTO item : dto.getItems()) {
            OrderDetail detail = new OrderDetail();
            detail.setOrderId(order.getId());
            detail.setRecipeId(item.getRecipeId());
            detail.setItemName(item.getItemName());
            detail.setItemType(1); // 鸡尾酒
            detail.setQuantity(item.getQuantity());
            detail.setPrice(item.getPrice());
            detail.setTotal(item.getTotal());
            detail.setRemark(item.getRemark());
            detail.setStatus(2); // 已完成
            detail.setCreatedAt(LocalDateTime.now());

            // 获取并设置成本价
            try {
                detail.setCostPrice(recipeService.getRecipeCostPrice(item.getRecipeId()));
            } catch (Exception e) {
                detail.setCostPrice(null);
            }

            orderDetailMapper.insert(detail);

            // 扣减库存
            try {
                recipeService.deductRecipeStock(item.getRecipeId(), item.getQuantity());
            } catch (Exception e) {
                throw new RuntimeException("库存扣减失败: " + e.getMessage());
            }
        }

        return order.getId();
    }

    @Override
    public Page<BarOrder> getOrderPage(int current, int size, Integer status) {
        Page<BarOrder> page = new Page<>(current, size);
        LambdaQueryWrapper<BarOrder> wrapper = new LambdaQueryWrapper<>();

        if (status != null) {
            wrapper.eq(BarOrder::getStatus, status);
        }

        wrapper.orderByDesc(BarOrder::getCreatedAt);

        return orderMapper.selectPage(page, wrapper);
    }

    @Override
    public BarOrder getOrderDetail(Long orderId) {
        return orderMapper.selectById(orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelOrder(Long orderId) {
        BarOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        if (order.getStatus() != 0) {
            throw new RuntimeException("只能取消待支付订单");
        }

        order.setStatus(2); // 已取消
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", (int)(Math.random() * 10000));
    }
}
