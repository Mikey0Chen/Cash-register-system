package com.cocktail.controller;

import com.cocktail.common.Result;
import com.cocktail.service.FinancialService;
import com.cocktail.vo.FinancialStatVO;
import com.cocktail.vo.OrderFinancialVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * 财务统计控制器
 */
@RestController
@RequestMapping("/financial")
@CrossOrigin
public class FinancialController {

    @Autowired
    private FinancialService financialService;

    /**
     * 获取今日财务统计
     */
    @GetMapping("/today")
    public Result<FinancialStatVO> getTodayStats() {
        return Result.success(financialService.getTodayStats());
    }

    /**
     * 获取本周财务统计
     */
    @GetMapping("/week")
    public Result<FinancialStatVO> getWeekStats() {
        return Result.success(financialService.getWeekStats());
    }

    /**
     * 获取本月财务统计
     */
    @GetMapping("/month")
    public Result<FinancialStatVO> getMonthStats() {
        return Result.success(financialService.getMonthStats());
    }

    /**
     * 按日期范围查询财务统计
     */
    @GetMapping("/range")
    public Result<List<FinancialStatVO>> getStatsByDateRange(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        return Result.success(financialService.getStatsByDateRange(startDate, endDate));
    }

    /**
     * 查询订单财务明细
     */
    @GetMapping("/orders")
    public Result<List<OrderFinancialVO>> getOrderFinancialList(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        return Result.success(financialService.getOrderFinancialList(startDate, endDate));
    }
}
