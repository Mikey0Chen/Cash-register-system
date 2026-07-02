<template>
  <div class="page-container">
    <div class="page-header">
      <h2>库存管理</h2>
      <div>
        <el-button @click="$router.push('/pos')">返回收银台</el-button>
        <el-button type="primary">入库</el-button>
      </div>
    </div>

    <div class="page-body">
      <el-alert
        title="库存预警"
        type="warning"
        description="部分原料库存不足，请及时采购补货"
        show-icon
        :closable="false"
        style="margin-bottom: 20px;"
      />

      <el-table :data="[]" border stripe>
        <el-table-column prop="name" label="原料名称" />
        <el-table-column prop="type" label="类型" width="120" />
        <el-table-column label="库存" width="150">
          <template #default="{ row }">
            {{ row.stock }} {{ row.unit }}
          </template>
        </el-table-column>
        <el-table-column label="最小库存" width="150">
          <template #default="{ row }">
            {{ row.minStock }} {{ row.unit }}
          </template>
        </el-table-column>
        <el-table-column prop="supplier" label="供应商" width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.stock < row.minStock" type="danger">库存不足</el-tag>
            <el-tag v-else type="success">正常</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small">入库</el-button>
            <el-button type="warning" size="small">盘点</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty description="功能开发中..." />
    </div>
  </div>
</template>

<script setup>
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
