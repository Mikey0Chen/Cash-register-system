<template>
  <div class="financial-container">
    <!-- 顶部导航 -->
    <div class="page-header">
      <h2>财务统计</h2>
      <el-button @click="goTo('/pos')">返回收银台</el-button>
    </div>

    <el-card v-loading="summaryLoading" class="summary-card">
      <template #header>
        <div class="card-header">
          <span>财务概览</span>
          <div>
            <el-radio-group v-model="activePeriod" @change="loadSummary" style="margin-right: 10px;">
              <el-radio-button label="today">今日</el-radio-button>
              <el-radio-button label="week">本周</el-radio-button>
              <el-radio-button label="month">本月</el-radio-button>
            </el-radio-group>
            <el-button @click="handleRefresh" :icon="RefreshIcon" circle title="刷新数据" />
          </div>
        </div>
      </template>

      <el-row :gutter="20">
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">销售收入</div>
            <div class="stat-value revenue">¥{{ formatCurrency(summary.totalRevenue) }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">成本支出</div>
            <div class="stat-value cost">¥{{ formatCurrency(summary.totalCost) }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">净利润</div>
            <div class="stat-value profit">¥{{ formatCurrency(summary.totalProfit) }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">利润率</div>
            <div class="stat-value rate">{{ summary.profitRate || '0.00' }}%</div>
          </div>
        </el-col>
      </el-row>

      <el-divider />

      <el-row :gutter="20">
        <el-col :span="12">
          <div class="stat-item-small">
            <span class="label">订单数量：</span>
            <span class="value">{{ summary.orderCount || 0 }} 单</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="stat-item-small">
            <span class="label">销售数量：</span>
            <span class="value">{{ summary.itemCount || 0 }} 杯</span>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="detail-card">
      <template #header>
        <div class="card-header">
          <span>订单明细</span>
          <div>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
              @change="loadOrderList"
            />
          </div>
        </div>
      </template>

      <el-table v-loading="orderListLoading" :data="orderList" stripe>
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="payTime" label="支付时间" width="160">
          <template #default="{ row }">
            {{ formatDateTimeLabel(row.payTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="actualAmount" label="销售金额" width="100" align="right">
          <template #default="{ row }">
            ¥{{ formatCurrency(row.actualAmount) }}
          </template>
        </el-table-column>
        <el-table-column prop="totalCost" label="成本" width="100" align="right">
          <template #default="{ row }">
            ¥{{ formatCurrency(row.totalCost) }}
          </template>
        </el-table-column>
        <el-table-column prop="profit" label="利润" width="100" align="right">
          <template #default="{ row }">
            <span :class="row.profit >= 0 ? 'profit-positive' : 'profit-negative'">
              ¥{{ formatCurrency(row.profit) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="profitRate" label="利润率" width="80" align="right">
          <template #default="{ row }">
            {{ row.profitRate }}%
          </template>
        </el-table-column>
        <el-table-column prop="itemCount" label="数量" width="80" align="center" />
        <el-table-column prop="payType" label="支付方式" width="100">
          <template #default="{ row }">
            {{ getPayTypeName(row.payType) }}
          </template>
        </el-table-column>
        <el-table-column prop="cashierName" label="收银员" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getFinancialSummary, getFinancialOrderList } from '@/api/financial'
import { PAYMENT_TYPE_LABELS } from '@/constants/pos'
import { ElMessage } from 'element-plus'
import { Refresh as RefreshIcon } from '@element-plus/icons-vue'
import { formatCurrency, formatDateTime } from '@/utils/format'

const router = useRouter()
const activePeriod = ref('today')
const summary = ref({})
const dateRange = ref([])
const orderList = ref([])
const summaryLoading = ref(false)
const orderListLoading = ref(false)

// 加载汇总数据
const loadSummary = async () => {
  summaryLoading.value = true
  try {
    const data = await getFinancialSummary(activePeriod.value)
    summary.value = data.data
  } catch (error) {
    ElMessage.error('加载财务数据失败')
  } finally {
    summaryLoading.value = false
  }
}

// 加载订单明细
const loadOrderList = async () => {
  if (!dateRange.value || dateRange.value.length !== 2) return

  try {
    orderListLoading.value = true
    const [startDate, endDate] = dateRange.value
    const data = await getFinancialOrderList({ startDate, endDate })
    orderList.value = data.data
  } catch (error) {
    ElMessage.error('加载订单明细失败')
  } finally {
    orderListLoading.value = false
  }
}

// 刷新数据
const handleRefresh = () => {
  loadSummary()
  loadOrderList()
  ElMessage.success('数据已刷新')
}

const getPayTypeName = (type) => {
  return PAYMENT_TYPE_LABELS[type] || '-'
}

const formatDateTimeLabel = (dateTime) => {
  return formatDateTime(dateTime)
}

const goTo = (path) => {
  router.push(path)
}

onMounted(() => {
  loadSummary()

  // 默认查询本月订单
  const today = new Date()
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
  dateRange.value = [
    firstDay.toISOString().split('T')[0],
    today.toISOString().split('T')[0]
  ]
  loadOrderList()
})
</script>

<style scoped>
.financial-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.summary-card {
  margin-bottom: 20px;
}

.stat-item {
  text-align: center;
  padding: 20px 0;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin-bottom: 10px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
}

.stat-value.revenue {
  color: #67C23A;
}

.stat-value.cost {
  color: #E6A23C;
}

.stat-value.profit {
  color: #409EFF;
}

.stat-value.rate {
  color: #F56C6C;
}

.stat-item-small {
  padding: 10px 0;
}

.stat-item-small .label {
  color: #606266;
  margin-right: 10px;
}

.stat-item-small .value {
  font-weight: bold;
  font-size: 18px;
  color: #303133;
}

.profit-positive {
  color: #67C23A;
}

.profit-negative {
  color: #F56C6C;
}
</style>
