package com.cocktail.service.impl;

import com.cocktail.mapper.FinancialMapper;
import com.cocktail.service.FinancialService;
import com.cocktail.vo.FinancialStatVO;
import com.cocktail.vo.OrderFinancialVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

/**
 * 财务统计服务实现
 */
@Service
public class FinancialServiceImpl implements FinancialService {

    @Autowired
    private FinancialMapper financialMapper;

    @Override
    public List<FinancialStatVO> getStatsByDateRange(LocalDate startDate, LocalDate endDate) {
        LocalDateTime startTime = startDate.atStartOfDay();
        LocalDateTime endTime = endDate.plusDays(1).atStartOfDay();

        List<FinancialStatVO> stats = financialMapper.getStatsByDateRange(startTime, endTime);

        // 计算利润率
        stats.forEach(this::calculateProfitRate);

        return stats;
    }

    @Override
    public FinancialStatVO getTodayStats() {
        LocalDate today = LocalDate.now();
        LocalDateTime startTime = today.atStartOfDay();
        LocalDateTime endTime = today.plusDays(1).atStartOfDay();

        return getSinglePeriodStats(startTime, endTime, today);
    }

    @Override
    public FinancialStatVO getWeekStats() {
        LocalDate today = LocalDate.now();
        LocalDate monday = today.with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
        LocalDateTime startTime = monday.atStartOfDay();
        LocalDateTime endTime = today.plusDays(1).atStartOfDay();

        return getSinglePeriodStats(startTime, endTime, monday);
    }

    @Override
    public FinancialStatVO getMonthStats() {
        LocalDate today = LocalDate.now();
        LocalDate firstDayOfMonth = today.with(TemporalAdjusters.firstDayOfMonth());
        LocalDateTime startTime = firstDayOfMonth.atStartOfDay();
        LocalDateTime endTime = today.plusDays(1).atStartOfDay();

        return getSinglePeriodStats(startTime, endTime, firstDayOfMonth);
    }

    @Override
    public List<OrderFinancialVO> getOrderFinancialList(LocalDate startDate, LocalDate endDate) {
        LocalDateTime startTime = startDate.atStartOfDay();
        LocalDateTime endTime = endDate.plusDays(1).atStartOfDay();

        List<OrderFinancialVO> orders = financialMapper.getOrderFinancialList(startTime, endTime);

        // 计算利润率
        orders.forEach(order -> {
            if (order.getActualAmount() != null && order.getActualAmount().compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal profitRate = order.getProfit()
                        .divide(order.getActualAmount(), 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100"));
                order.setProfitRate(profitRate);
            }
        });

        return orders;
    }

    /**
     * 获取单个时间段的统计数据
     */
    private FinancialStatVO getSinglePeriodStats(LocalDateTime startTime, LocalDateTime endTime, LocalDate statDate) {
        List<FinancialStatVO> stats = financialMapper.getStatsByDateRange(startTime, endTime);

        if (stats.isEmpty()) {
            FinancialStatVO emptyStats = new FinancialStatVO();
            emptyStats.setStatDate(statDate);
            return emptyStats;
        }

        // 合并多日数据
        FinancialStatVO result = new FinancialStatVO();
        result.setStatDate(statDate);
        result.setTotalRevenue(stats.stream()
                .map(FinancialStatVO::getTotalRevenue)
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        result.setTotalCost(stats.stream()
                .map(FinancialStatVO::getTotalCost)
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        result.setTotalProfit(stats.stream()
                .map(FinancialStatVO::getTotalProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        result.setOrderCount(stats.stream()
                .mapToInt(FinancialStatVO::getOrderCount)
                .sum());
        result.setItemCount(stats.stream()
                .mapToInt(FinancialStatVO::getItemCount)
                .sum());

        calculateProfitRate(result);

        return result;
    }

    /**
     * 计算利润率
     */
    private void calculateProfitRate(FinancialStatVO stat) {
        if (stat.getTotalRevenue() != null && stat.getTotalRevenue().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal profitRate = stat.getTotalProfit()
                    .divide(stat.getTotalRevenue(), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"));
            stat.setProfitRate(profitRate);
        }
    }
}
