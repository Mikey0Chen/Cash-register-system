<template>
  <div class="page-container">
    <div class="page-header">
      <h2>库存管理</h2>
      <div>
        <el-button @click="goTo('/pos')">返回收银台</el-button>
      </div>
    </div>

    <div class="page-body">
      <el-alert
        :title="alertTitle"
        type="warning"
        :description="alertDescription"
        show-icon
        :closable="false"
        style="margin-bottom: 20px;"
      />

      <el-table v-loading="tableLoading" :data="ingredients" border stripe>
        <el-table-column prop="name" label="原料名称" />
        <el-table-column prop="type" label="类型" width="120" />
        <el-table-column label="库存" width="150">
          <template #default="{ row }">
            {{ formatCurrency(row.stock) }} {{ row.unit }}
          </template>
        </el-table-column>
        <el-table-column label="最小库存" width="150">
          <template #default="{ row }">
            {{ formatCurrency(row.minStock) }} {{ row.unit }}
          </template>
        </el-table-column>
        <el-table-column label="成本价" width="120">
          <template #default="{ row }">
            ¥{{ formatCurrency(row.costPrice) }}
          </template>
        </el-table-column>
        <el-table-column prop="supplier" label="供应商" width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="isLowStock(row) ? 'danger' : 'success'">
              {{ isLowStock(row) ? '库存不足' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="启用状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getIngredientList } from '@/api/ingredient'
import { formatCurrency } from '@/utils/format'

const router = useRouter()
const tableLoading = ref(false)
const ingredients = ref([])

const lowStockCount = computed(() => {
  return ingredients.value.filter(isLowStock).length
})

const alertTitle = computed(() => {
  return lowStockCount.value > 0 ? '库存预警' : '库存状态正常'
})

const alertDescription = computed(() => {
  if (lowStockCount.value > 0) {
    return `当前有 ${lowStockCount.value} 个原料低于最小库存，请及时补货。`
  }

  return '当前所有原料库存均高于预警线。'
})

function isLowStock(row) {
  return Number(row.stock || 0) < Number(row.minStock || 0)
}

async function loadIngredients() {
  tableLoading.value = true
  try {
    const response = await getIngredientList()
    ingredients.value = response.data
  } catch (error) {
    ElMessage.error('加载库存列表失败')
  } finally {
    tableLoading.value = false
  }
}

function goTo(path) {
  router.push(path)
}

onMounted(() => {
  loadIngredients()
})
</script>

<style scoped>
.page-container {
  padding: 20px;
  background: #f5f5f5;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
}

.page-body {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
}
</style>
