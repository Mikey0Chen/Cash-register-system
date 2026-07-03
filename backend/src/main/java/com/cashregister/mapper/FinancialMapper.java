package com.cashregister.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cashregister.entity.BarOrder;
import com.cashregister.vo.FinancialStatVO;
import com.cashregister.vo.OrderFinancialVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 财务统计Mapper
 */
@Mapper
public interface FinancialMapper extends BaseMapper<BarOrder> {

    /**
     * 按日期统计财务数据
     */
    @Select("SELECT " +
            "DATE(o.pay_time) as statDate, " +
            "SUM(o.actual_amount) as totalRevenue, " +
            "SUM(IFNULL((SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id), 0)) as totalCost, " +
            "SUM(o.actual_amount) - SUM(IFNULL((SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id), 0)) as totalProfit, " +
            "COUNT(o.id) as orderCount, " +
            "SUM((SELECT SUM(od.quantity) FROM order_detail od WHERE od.order_id = o.id)) as itemCount " +
            "FROM bar_order o " +
            "WHERE o.status = 1 AND o.pay_time >= #{startTime} AND o.pay_time < #{endTime} " +
            "GROUP BY DATE(o.pay_time) " +
            "ORDER BY statDate DESC")
    List<FinancialStatVO> getStatsByDateRange(@Param("startTime") LocalDateTime startTime,
                                               @Param("endTime") LocalDateTime endTime);

    /**
     * 查询订单财务明细
     */
    @Select("SELECT " +
            "o.id as orderId, " +
            "o.order_no as orderNo, " +
            "o.actual_amount as actualAmount, " +
            "(SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id) as totalCost, " +
            "o.actual_amount - (SELECT SUM(od.cost_price * od.quantity) FROM order_detail od WHERE od.order_id = o.id) as profit, " +
            "(SELECT SUM(od.quantity) FROM order_detail od WHERE od.order_id = o.id) as itemCount, " +
            "o.pay_type as payType, " +
            "'收银员' as cashierName, " +
            "o.pay_time as payTime, " +
            "o.created_at as createdAt " +
            "FROM bar_order o " +
            "WHERE o.status = 1 AND o.pay_time >= #{startTime} AND o.pay_time < #{endTime} " +
            "ORDER BY o.pay_time DESC")
    List<OrderFinancialVO> getOrderFinancialList(@Param("startTime") LocalDateTime startTime,
                                                  @Param("endTime") LocalDateTime endTime);
}
