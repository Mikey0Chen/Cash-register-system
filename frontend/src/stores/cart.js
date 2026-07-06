import { computed, ref, watch } from 'vue'
import { defineStore } from 'pinia'

const STORAGE_KEY = 'cash-register-cart'

function loadCartItems() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : []
  } catch (error) {
    console.error('Failed to load cart from localStorage:', error)
    return []
  }
}

export const useCartStore = defineStore('cart', () => {
  const items = ref(loadCartItems())

  const totalAmount = computed(() => {
    return items.value.reduce((sum, item) => sum + Number(item.price) * Number(item.quantity), 0)
  })

  const itemCount = computed(() => {
    return items.value.reduce((sum, item) => sum + Number(item.quantity), 0)
  })

  function addItem(recipe) {
    const existing = items.value.find((item) => item.id === recipe.id)
    if (existing) {
      existing.quantity += 1
      return
    }

    items.value.push({
      id: recipe.id,
      name: recipe.name,
      price: Number(recipe.price),
      quantity: 1
    })
  }

  function updateQuantity(index, quantity) {
    if (!items.value[index]) {
      return
    }

    items.value[index].quantity = Math.max(1, Number(quantity) || 1)
  }

  function removeItem(index) {
    items.value.splice(index, 1)
  }

  function clear() {
    items.value = []
  }

  watch(items, (value) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(value))
  }, { deep: true })

  return {
    items,
    itemCount,
    totalAmount,
    addItem,
    updateQuantity,
    removeItem,
    clear
  }
})
