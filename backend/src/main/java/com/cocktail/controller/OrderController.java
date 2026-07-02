package com.cocktail.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cocktail.common.Result;
import com.cocktail.dto.CreateOrderDTO;
import com.cocktail.entity.BarOrder;
import com.cocktail.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/order")
@CrossOrigin
public class OrderController {

    @Autowired
    private OrderService orderService;

    /**
     * 创建订单
     */
    @PostMapping
    public Result<Long> createOrder(@Validated @RequestBody CreateOrderDTO dto) {
        try {
            Long orderId = orderService.createOrder(dto);
            return Result.success(orderId);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 分页查询订单
     */
    @GetMapping("/page")
    public Result<Page<BarOrder>> getOrderPage(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Integer status) {
        return Result.success(orderService.getOrderPage(current, size, status));
    }

    /**
     * 查询订单详情
     */
    @GetMapping("/{id}")
    public Result<BarOrder> getOrderDetail(@PathVariable Long id) {
        return Result.success(orderService.getOrderDetail(id));
    }

    /**
     * 取消订单
     */
    @PutMapping("/{id}/cancel")
    public Result<Void> cancelOrder(@PathVariable Long id) {
        try {
            orderService.cancelOrder(id);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
