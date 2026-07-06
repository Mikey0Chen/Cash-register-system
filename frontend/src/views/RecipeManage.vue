<template>
  <div class="page-container">
    <div class="page-header">
      <h2>配方管理</h2>
      <div>
        <el-button @click="goTo('/pos')">返回收银台</el-button>
        <el-button type="primary" @click="handleCreate">新增配方</el-button>
      </div>
    </div>

    <div class="page-body">
      <el-table v-loading="tableLoading" :data="tableData" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="鸡尾酒名称" width="150" />
        <el-table-column prop="nameEn" label="英文名" width="150" />
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="price" label="售价" width="100">
          <template #default="{ row }">
            ¥{{ row.price }}
          </template>
        </el-table-column>
        <el-table-column prop="costPrice" label="成本价" width="100">
          <template #default="{ row }">
            ¥{{ row.costPrice || 0 }}
          </template>
        </el-table-column>
        <el-table-column prop="salesCount" label="销量" width="100" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '在售' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="loadData"
          @size-change="loadData"
        />
      </div>
    </div>

    <!-- 配方详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="配方详情" width="700px">
      <div v-if="currentRecipe">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="名称">{{ currentRecipe.name }}</el-descriptions-item>
          <el-descriptions-item label="英文名">{{ currentRecipe.nameEn }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ currentRecipe.category }}</el-descriptions-item>
          <el-descriptions-item label="售价">¥{{ currentRecipe.price }}</el-descriptions-item>
          <el-descriptions-item label="成本价">¥{{ currentRecipe.costPrice || 0 }}</el-descriptions-item>
          <el-descriptions-item label="销量">{{ currentRecipe.salesCount }}</el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">{{ currentRecipe.description }}</el-descriptions-item>
        </el-descriptions>

        <h4 style="margin-top: 20px;">原料配方：</h4>
        <el-table :data="currentRecipe.ingredients" border style="margin-top: 10px;">
          <el-table-column prop="ingredientName" label="原料名称" />
          <el-table-column prop="ingredientType" label="类型" width="100" />
          <el-table-column label="用量" width="120">
            <template #default="{ row }">
              {{ row.quantity }} {{ row.unit }}
            </template>
          </el-table-column>
          <el-table-column label="库存" width="120">
            <template #default="{ row }">
              {{ row.stock }} {{ row.unit }}
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>

    <!-- 配方编辑/新增对话框 -->
    <el-dialog v-model="formDialogVisible" :title="formMode === 'create' ? '新增配方' : '编辑配方'" width="800px">
      <el-form ref="recipeFormRef" :model="recipeForm" :rules="recipeFormRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="中文名称" prop="name" required>
              <el-input v-model="recipeForm.name" placeholder="请输入中文名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="英文名称" prop="nameEn" required>
              <el-input v-model="recipeForm.nameEn" placeholder="请输入英文名称" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分类" prop="category" required>
              <el-select v-model="recipeForm.category" placeholder="请选择分类" style="width: 100%">
                <el-option label="经典鸡尾酒" value="经典鸡尾酒" />
                <el-option label="创意鸡尾酒" value="创意鸡尾酒" />
                <el-option label="无酒精" value="无酒精" />
                <el-option label="特调" value="特调" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="售价" prop="price" required>
              <el-input-number v-model="recipeForm.price" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="描述">
          <el-input v-model="recipeForm.description" type="textarea" :rows="3" placeholder="请输入配方描述" />
        </el-form-item>

        <el-form-item label="原料配方">
          <el-button type="primary" size="small" @click="handleAddIngredient">添加原料</el-button>
          <el-button type="success" size="small" @click="handleCreateIngredient" style="margin-left: 10px;">新增原料</el-button>
          <el-table :data="recipeForm.ingredients" border style="margin-top: 10px;" max-height="300">
            <el-table-column label="原料名称" width="250">
              <template #default="{ row, $index }">
                <div style="display: flex; gap: 5px;">
                  <el-select v-model="row.ingredientId" placeholder="选择原料" style="flex: 1" @change="handleIngredientChange($index)">
                    <el-option v-for="ing in allIngredients" :key="ing.id" :label="ing.name" :value="ing.id" />
                  </el-select>
                  <el-button
                    v-if="row.ingredientId"
                    type="warning"
                    size="small"
                    @click="handleEditIngredient(row.ingredientId)"
                    :icon="Edit"
                    circle
                    title="编辑原料"
                  />
                </div>
              </template>
            </el-table-column>
            <el-table-column label="用量" width="150">
              <template #default="{ row }">
                <el-input-number v-model="row.quantity" :min="0" :precision="2" size="small" style="width: 100%" />
              </template>
            </el-table-column>
            <el-table-column label="单位" width="100">
              <template #default="{ row }">
                <el-input v-model="row.unit" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80">
              <template #default="{ $index }">
                <el-button type="danger" size="small" @click="handleRemoveIngredient($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="formDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="recipeSubmitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 原料编辑/新增对话框 -->
    <el-dialog v-model="ingredientDialogVisible" :title="ingredientFormMode === 'create' ? '新增原料' : '编辑原料'" width="500px">
      <el-form ref="ingredientFormRef" :model="ingredientForm" :rules="ingredientFormRules" label-width="100px">
        <el-form-item label="原料名称" prop="name" required>
          <el-input v-model="ingredientForm.name" placeholder="请输入原料名称" />
        </el-form-item>
        <el-form-item label="原料类型" prop="type" required>
          <el-select v-model="ingredientForm.type" placeholder="选择类型" style="width: 100%">
            <el-option label="基酒" value="基酒" />
            <el-option label="辅料" value="辅料" />
            <el-option label="装饰物" value="装饰物" />
            <el-option label="工具" value="工具" />
          </el-select>
        </el-form-item>
        <el-form-item label="单位" prop="unit" required>
          <el-input v-model="ingredientForm.unit" placeholder="如: ml, g, 个" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="ingredientForm.unitPrice" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="规格">
          <el-input v-model="ingredientForm.spec" placeholder="如: 750ml/瓶" />
        </el-form-item>
        <el-form-item label="供应商">
          <el-input v-model="ingredientForm.supplier" placeholder="请输入供应商名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="ingredientDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="ingredientSubmitting" @click="handleSubmitIngredient">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit } from '@element-plus/icons-vue'
import { getRecipePage, getRecipeDetail, deleteRecipe, createRecipe, updateRecipe } from '@/api/recipe'
import {
  getIngredientList,
  getIngredientById,
  createIngredient,
  updateIngredient
} from '@/api/ingredient'

const router = useRouter()
const tableData = ref([])
const tableLoading = ref(false)
const recipeSubmitting = ref(false)
const ingredientSubmitting = ref(false)
const pagination = ref({
  current: 1,
  size: 10,
  total: 0
})
const detailDialogVisible = ref(false)
const currentRecipe = ref(null)

const formDialogVisible = ref(false)
const formMode = ref('create')
const recipeFormRef = ref()
const recipeForm = ref({
  id: null,
  name: '',
  nameEn: '',
  category: '',
  price: 0,
  description: '',
  ingredients: []
})
const recipeFormRules = {
  name: [{ required: true, message: '请输入中文名称', trigger: 'blur' }],
  nameEn: [{ required: true, message: '请输入英文名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入售价', trigger: 'blur' }]
}
const allIngredients = ref([])

// 原料编辑相关
const ingredientDialogVisible = ref(false)
const ingredientFormMode = ref('create')
const ingredientFormRef = ref()
const ingredientForm = ref({
  id: null,
  name: '',
  type: '',
  unit: 'ml',
  unitPrice: 0,
  spec: '',
  supplier: ''
})
const ingredientFormRules = {
  name: [{ required: true, message: '请输入原料名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择原料类型', trigger: 'change' }],
  unit: [{ required: true, message: '请输入单位', trigger: 'blur' }]
}

function createEmptyRecipeForm() {
  return {
    id: null,
    name: '',
    nameEn: '',
    category: '',
    price: 0,
    description: '',
    ingredients: []
  }
}

function createEmptyIngredientForm() {
  return {
    id: null,
    name: '',
    type: '',
    unit: 'ml',
    unitPrice: 0,
    spec: '',
    supplier: ''
  }
}

const loadData = async () => {
  tableLoading.value = true
  try {
    const res = await getRecipePage({
      current: pagination.value.current,
      size: pagination.value.size
    })
    tableData.value = res.data.records
    pagination.value.total = res.data.total
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    tableLoading.value = false
  }
}

const loadIngredients = async () => {
  try {
    const data = await getIngredientList()
    allIngredients.value = data.data
  } catch (error) {
    ElMessage.error('加载原料列表失败')
  }
}

// 别名方法
const loadAllIngredients = loadIngredients

const handleCreate = () => {
  formMode.value = 'create'
  recipeForm.value = createEmptyRecipeForm()
  formDialogVisible.value = true
  recipeFormRef.value?.clearValidate()
  loadIngredients()
}

const handleView = async (row) => {
  try {
    const res = await getRecipeDetail(row.id)
    currentRecipe.value = res.data
    detailDialogVisible.value = true
  } catch (error) {
    ElMessage.error('获取详情失败')
  }
}

const handleEdit = async (row) => {
  formMode.value = 'edit'
  try {
    const res = await getRecipeDetail(row.id)
    const detail = res.data
    recipeForm.value = {
      id: detail.id,
      name: detail.name,
      nameEn: detail.nameEn,
      category: detail.category,
      price: detail.price,
      description: detail.description,
      ingredients: detail.ingredients.map(ing => ({
        ingredientId: ing.ingredientId,
        quantity: ing.quantity,
        unit: ing.unit,
        isOptional: ing.isOptional,
        sortOrder: ing.sortOrder
      }))
    }
    formDialogVisible.value = true
    recipeFormRef.value?.clearValidate()
    loadIngredients()
  } catch (error) {
    ElMessage.error('获取配方详情失败')
  }
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该配方吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteRecipe(row.id)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

const handleAddIngredient = () => {
  recipeForm.value.ingredients.push({
    ingredientId: null,
    quantity: 0,
    unit: 'ml',
    isOptional: 0,
    sortOrder: recipeForm.value.ingredients.length
  })
}

const handleRemoveIngredient = (index) => {
  recipeForm.value.ingredients.splice(index, 1)
}

const handleIngredientChange = (index) => {
  const ingredient = allIngredients.value.find(
    ing => ing.id === recipeForm.value.ingredients[index].ingredientId
  )
  if (ingredient) {
    recipeForm.value.ingredients[index].unit = ingredient.unit
  }
}

const handleSubmit = async () => {
  const valid = await recipeFormRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }

  if (recipeForm.value.ingredients.length === 0) {
    ElMessage.warning('请至少添加一个原料')
    return
  }

  try {
    recipeSubmitting.value = true
    if (formMode.value === 'create') {
      await createRecipe(recipeForm.value)
      ElMessage.success('创建成功')
    } else {
      await updateRecipe(recipeForm.value)
      ElMessage.success('更新成功')
    }
    formDialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error(formMode.value === 'create' ? '创建失败' : '更新失败')
  } finally {
    recipeSubmitting.value = false
  }
}

// 原料管理方法
const handleCreateIngredient = () => {
  ingredientFormMode.value = 'create'
  ingredientForm.value = createEmptyIngredientForm()
  ingredientDialogVisible.value = true
  ingredientFormRef.value?.clearValidate()
}

const handleEditIngredient = async (ingredientId) => {
  try {
    const data = await getIngredientById(ingredientId)
    ingredientFormMode.value = 'edit'
    ingredientForm.value = { ...data.data }
    ingredientDialogVisible.value = true
    ingredientFormRef.value?.clearValidate()
  } catch (error) {
    ElMessage.error('加载原料信息失败')
  }
}

const handleSubmitIngredient = async () => {
  const valid = await ingredientFormRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }

  try {
    ingredientSubmitting.value = true
    if (ingredientFormMode.value === 'create') {
      await createIngredient(ingredientForm.value)
      ElMessage.success('原料创建成功')
    } else {
      await updateIngredient(ingredientForm.value)
      ElMessage.success('原料更新成功')
    }
    ingredientDialogVisible.value = false
    loadAllIngredients() // 重新加载原料列表
  } catch (error) {
    ElMessage.error(ingredientFormMode.value === 'create' ? '创建失败' : '更新失败')
  } finally {
    ingredientSubmitting.value = false
  }
}

const goTo = (path) => {
  router.push(path)
}

onMounted(() => {
  loadData()
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

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
