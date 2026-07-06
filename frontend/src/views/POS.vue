<template>
  <div class="pos-container">
    <!-- 顶部导航栏 -->
    <div class="pos-header">
      <div class="header-left">
        <h1>Cash Register System</h1>
      </div>
      <div class="header-right">
        <el-button @click="goTo('/financial')">财务统计</el-button>
        <el-button @click="goTo('/recipe')">配方管理</el-button>
        <el-button @click="goTo('/ingredient')">库存管理</el-button>
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
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <!-- 商品列表 -->
        <div v-loading="recipesLoading" class="product-list">
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
              <div class="product-price">¥{{ formatCurrency(recipe.price) }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：购物车 -->
      <div class="cart-area">
        <div class="cart-header">
          <h3>购物车</h3>
          <el-button type="danger" size="small" @click="handleClearCart" v-if="cartItems.length > 0">
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
                  @change="(value) => handleQuantityChange(index, value)"
                />
                <el-button
                  type="danger"
                  size="small"
                  :icon="Delete"
                  circle
                  @click="handleRemoveFromCart(index)"
                />
              </div>
              <div class="item-total">
                小计: ¥{{ formatCurrency(item.price * item.quantity) }}
              </div>
            </div>
          </div>
        </div>

        <div class="cart-summary">
          <div class="summary-row">
            <span>商品总额：</span>
            <span class="amount">¥{{ formatCurrency(totalAmount) }}</span>
          </div>
          <div class="summary-row">
            <span>优惠金额：</span>
            <span class="amount discount">-¥{{ formatCurrency(discountAmount) }}</span>
          </div>
          <div class="summary-row total">
            <span>实付金额：</span>
            <span class="amount">¥{{ formatCurrency(actualAmount) }}</span>
          </div>
        </div>

        <div class="cart-actions">
          <el-button type="success" size="large" @click="openCheckout" :disabled="cartItems.length === 0">
            结账
          </el-button>
        </div>
      </div>
    </div>

    <!-- 结账对话框 -->
    <el-dialog v-model="checkoutDialogVisible" title="结账" width="500px">
      <el-form ref="checkoutFormRef" :model="checkoutForm" :rules="checkoutRules" label-width="100px">
        <el-form-item label="支付方式" prop="payType">
          <el-radio-group v-model="checkoutForm.payType">
            <el-radio
              v-for="option in paymentOptions"
              :key="option.value"
              :label="option.value"
            >
              {{ option.label }}
            </el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="实付金额">
          <el-input :model-value="formatCurrency(actualAmount)" disabled>
            <template #prepend>¥</template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="checkoutDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="checkoutSubmitting" @click="confirmCheckout">确认支付</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, ref, watch, onBeforeUnmount } from 'vue'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Delete, Search } from '@element-plus/icons-vue'
import { getRecipePage } from '@/api/recipe'
import { createOrder } from '@/api/order'
import { PAYMENT_OPTIONS, RECIPE_CATEGORIES } from '@/constants/pos'
import { useCartStore } from '@/stores/cart'
import { debounce } from '@/utils/debounce'
import { formatCurrency } from '@/utils/format'

const router = useRouter()
const cartStore = useCartStore()
const { items: cartItems, totalAmount } = storeToRefs(cartStore)
const categories = RECIPE_CATEGORIES
const paymentOptions = PAYMENT_OPTIONS
const currentCategory = ref('')
const searchKeyword = ref('')
const recipes = ref([])
const checkoutDialogVisible = ref(false)
const recipesLoading = ref(false)
const checkoutSubmitting = ref(false)
const checkoutFormRef = ref()
const checkoutForm = ref({
  payType: 1
})
const checkoutRules = {
  payType: [{ required: true, message: '请选择支付方式', trigger: 'change' }]
}

// 加载配方列表
const loadRecipes = async () => {
  recipesLoading.value = true
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
  } finally {
    recipesLoading.value = false
  }
}

const debouncedLoadRecipes = debounce(loadRecipes, 300)

watch([currentCategory, searchKeyword], () => {
  debouncedLoadRecipes()
}, { immediate: true })

const addToCart = (recipe) => {
  cartStore.addItem(recipe)
  ElMessage.success('已添加到购物车')
}

const handleRemoveFromCart = (index) => {
  cartStore.removeItem(index)
}

const handleClearCart = () => {
  cartStore.clear()
  checkoutForm.value.payType = 1
}

const handleQuantityChange = (index, quantity) => {
  cartStore.updateQuantity(index, quantity)
}

// 优惠金额（暂时写死）
const discountAmount = ref(0)

// 实付金额
const actualAmount = computed(() => {
  return totalAmount.value - discountAmount.value
})

const openCheckout = () => {
  checkoutDialogVisible.value = true
}

const goTo = (path) => {
  router.push(path)
}

// 确认结账
const confirmCheckout = async () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning('购物车为空')
    return
  }

  try {
    const valid = await checkoutFormRef.value?.validate().catch(() => false)
    if (!valid) {
      return
    }

    checkoutSubmitting.value = true
    const orderData = {
      orderType: 1,
      payType: checkoutForm.value.payType,
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

    const data = await createOrder(orderData)

    ElMessage.success('支付成功！订单号：' + data.data)
    checkoutDialogVisible.value = false
    handleClearCart()
  } catch (error) {
    ElMessage.error('支付失败：' + (error.message || '未知错误'))
  } finally {
    checkoutSubmitting.value = false
  }
}

onBeforeUnmount(() => {
  debouncedLoadRecipes.cancel()
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
