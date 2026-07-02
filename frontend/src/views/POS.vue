<template>
  <div class="pos-container">
    <!-- 顶部导航栏 -->
    <div class="pos-header">
      <div class="header-left">
        <h1>🍸 鸡尾酒收银系统</h1>
      </div>
      <div class="header-right">
        <el-button @click="$router.push('/financial')">财务统计</el-button>
        <el-button @click="$router.push('/recipe')">配方管理</el-button>
        <el-button @click="$router.push('/ingredient')">库存管理</el-button>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="pos-body">
      <!-- 左侧：商品区 -->
      <div class="product-area">
        <!-- 分类标签 -->
        <div class="category-tabs">
          <el-button
            v-for="cat in categories"
            :key="cat.value"
            :type="currentCategory === cat.value ? 'primary' : ''"
            @click="currentCategory = cat.value"
          >
            {{ cat.label }}
          </el-button>
        </div>

        <!-- 搜索框 -->
        <div class="search-box">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索鸡尾酒..."
            clearable
            @input="loadRecipes"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <!-- 商品列表 -->
        <div class="product-list">
          <div
            v-for="recipe in recipes"
            :key="recipe.id"
            class="product-card"
            @click="addToCart(recipe)"
          >
            <div class="product-image">
              <img v-if="recipe.imageUrl" :src="recipe.imageUrl" alt="">
              <div v-else class="image-placeholder">🍸</div>
            </div>
            <div class="product-info">
              <div class="product-name">{{ recipe.name }}</div>
              <div class="product-name-en">{{ recipe.nameEn }}</div>
              <div class="product-price">¥{{ recipe.price }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：购物车 -->
      <div class="cart-area">
        <div class="cart-header">
          <h3>购物车</h3>
          <el-button type="danger" size="small" @click="clearCart" v-if="cartItems.length > 0">
            清空
          </el-button>
        </div>

        <div class="cart-list">
          <div v-if="cartItems.length === 0" class="empty-cart">
            <el-empty description="购物车为空" />
          </div>
          <div v-else>
            <div v-for="(item, index) in cartItems" :key="index" class="cart-item">
              <div class="item-info">
                <div class="item-name">{{ item.name }}</div>
                <div class="item-price">¥{{ item.price }}</div>
              </div>
              <div class="item-actions">
                <el-input-number
                  v-model="item.quantity"
                  :min="1"
                  :max="99"
                  size="small"
                  @change="updateCart"
                />
                <el-button
                  type="danger"
                  size="small"
                  icon="Delete"
                  circle
                  @click="removeFromCart(index)"
                />
              </div>
              <div class="item-total">
                小计: ¥{{ (item.price * item.quantity).toFixed(2) }}
              </div>
            </div>
          </div>
        </div>

        <div class="cart-summary">
          <div class="summary-row">
            <span>商品总额：</span>
            <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
          </div>
          <div class="summary-row">
            <span>优惠金额：</span>
            <span class="amount discount">-¥{{ discountAmount.toFixed(2) }}</span>
          </div>
          <div class="summary-row total">
            <span>实付金额：</span>
            <span class="amount">¥{{ actualAmount.toFixed(2) }}</span>
          </div>
        </div>

        <div class="cart-actions">
          <el-button type="success" size="large" @click="checkout" :disabled="cartItems.length === 0">
            结账
          </el-button>
        </div>
      </div>
    </div>

    <!-- 结账对话框 -->
    <el-dialog v-model="checkoutDialogVisible" title="结账" width="500px">
      <el-form :model="checkoutForm" label-width="100px">
        <el-form-item label="支付方式">
          <el-radio-group v-model="checkoutForm.payType">
            <el-radio :label="1">现金</el-radio>
            <el-radio :label="2">微信</el-radio>
            <el-radio :label="3">支付宝</el-radio>
            <el-radio :label="4">会员卡</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="实付金额">
          <el-input v-model="actualAmount" disabled>
            <template #prepend>¥</template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="checkoutDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmCheckout">确认支付</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { getRecipePage } from '@/api/recipe'
import request from '@/utils/request'

// 分类列表
const categories = [
  { label: '全部', value: '' },
  { label: '朗姆基酒', value: '朗姆基酒' },
  { label: '伏特加基酒', value: '伏特加基酒' },
  { label: '威士忌基酒', value: '威士忌基酒' },
  { label: '龙舌兰基酒', value: '龙舌兰基酒' },
  { label: '无酒精', value: '无酒精' }
]

const currentCategory = ref('')
const searchKeyword = ref('')
const recipes = ref([])
const cartItems = ref([])
const checkoutDialogVisible = ref(false)
const paymentMethod = ref(1)  // 默认现金支付
const checkoutForm = ref({
  payType: 1
})

// 加载配方列表
const loadRecipes = async () => {
  try {
    const res = await getRecipePage({
      current: 1,
      size: 100,
      category: currentCategory.value,
      keyword: searchKeyword.value
    })
    recipes.value = res.data.records
  } catch (error) {
    ElMessage.error('加载配方失败')
  }
}

// 监听分类变化
watch(currentCategory, () => {
  loadRecipes()
})

// 添加到购物车
const addToCart = (recipe) => {
  const existItem = cartItems.value.find(item => item.id === recipe.id)
  if (existItem) {
    existItem.quantity++
  } else {
    cartItems.value.push({
      id: recipe.id,
      name: recipe.name,
      price: recipe.price,
      quantity: 1
    })
  }
  ElMessage.success('已添加到购物车')
}

// 从购物车移除
const removeFromCart = (index) => {
  cartItems.value.splice(index, 1)
}

// 清空购物车
const clearCart = () => {
  cartItems.value = []
}

// 更新购物车
const updateCart = () => {
  // 自动触发
}

// 计算总额
const totalAmount = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
})

// 优惠金额（暂时写死）
const discountAmount = ref(0)

// 实付金额
const actualAmount = computed(() => {
  return totalAmount.value - discountAmount.value
})

// 结账
const checkout = () => {
  checkoutDialogVisible.value = true
}

// 确认结账
const confirmCheckout = async () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning('购物车为空')
    return
  }

  try {
    // 构建订单数据
    const orderData = {
      orderType: 1,  // 堂食
      payType: paymentMethod.value,
      totalAmount: totalAmount.value,
      discountAmount: discountAmount.value,
      actualAmount: actualAmount.value,
      items: cartItems.value.map(item => ({
        recipeId: item.id,
        itemName: item.name,
        quantity: item.quantity,
        price: item.price,
        total: item.price * item.quantity
      }))
    }

    // 调用后端API创建订单
    const data = await request.post('/order', orderData)

    ElMessage.success('支付成功！订单号：' + data.data)
    checkoutDialogVisible.value = false
    clearCart()
  } catch (error) {
    ElMessage.error('支付失败：' + (error.message || '未知错误'))
  }
}

onMounted(() => {
  loadRecipes()
})
</script>

<style scoped>
.pos-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f5f5;
}

.pos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 60px;
  background: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-left h1 {
  font-size: 20px;
  font-weight: 600;
  color: #333;
}

.pos-body {
  display: flex;
  flex: 1;
  overflow: hidden;
  padding: 20px;
  gap: 20px;
}

.product-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  overflow: hidden;
}

.category-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.search-box {
  margin-bottom: 20px;
}

.product-list {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 15px;
  overflow-y: auto;
  padding: 5px;
}

.product-card {
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 15px;
  cursor: pointer;
  transition: all 0.3s;
}

.product-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transform: translateY(-2px);
}

.product-image {
  width: 100%;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
  border-radius: 6px;
  overflow: hidden;
  background: #f5f5f5;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  font-size: 48px;
}

.product-info {
  text-align: center;
}

.product-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 4px;
}

.product-name-en {
  font-size: 12px;
  color: #999;
  margin-bottom: 8px;
}

.product-price {
  font-size: 18px;
  font-weight: 700;
  color: #409eff;
}

.cart-area {
  width: 400px;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 8px;
  padding: 20px;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #e4e7ed;
}

.cart-header h3 {
  font-size: 18px;
  font-weight: 600;
}

.cart-list {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 20px;
}

.empty-cart {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.cart-item {
  padding: 15px;
  border-bottom: 1px solid #e4e7ed;
}

.item-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.item-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
}

.item-price {
  color: #409eff;
  font-weight: 600;
}

.item-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.item-total {
  text-align: right;
  font-size: 14px;
  color: #666;
}

.cart-summary {
  padding: 15px 0;
  border-top: 2px solid #e4e7ed;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 15px;
}

.summary-row.total {
  font-size: 18px;
  font-weight: 700;
  color: #333;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #e4e7ed;
}

.amount {
  font-weight: 600;
}

.discount {
  color: #f56c6c;
}

.cart-actions {
  margin-top: 15px;
}

.cart-actions .el-button {
  width: 100%;
  height: 50px;
  font-size: 18px;
  font-weight: 600;
}
</style>
