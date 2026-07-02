package com.cocktail.service;

import com.cocktail.vo.FinancialStatVO;
import com.cocktail.vo.OrderFinancialVO;

import java.time.LocalDate;
import java.util.List;

/**
 * 财务统计服务
 */
public interface FinancialService {

    /**
     * 获取指定日期范围的财务统计
     */
    List<FinancialStatVO> getStatsByDateRange(LocalDate startDate, LocalDate endDate);

    /**
     * 获取今日财务统计
     */
    FinancialStatVO getTodayStats();

    /**
     * 获取本周财务统计
     */
    FinancialStatVO getWeekStats();

    /**
     * 获取本月财务统计
     */
    FinancialStatVO getMonthStats();

    /**
     * 获取订单财务明细列表
     */
    List<OrderFinancialVO> getOrderFinancialList(LocalDate startDate, LocalDate endDate);
}
