import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/pos'
  },
  {
    path: '/pos',
    name: 'POS',
    component: () => import('@/views/POS.vue'),
    meta: { title: '收银台' }
  },
  {
    path: '/recipe',
    name: 'Recipe',
    component: () => import('@/views/RecipeManage.vue'),
    meta: { title: '配方管理' }
  },
  {
    path: '/ingredient',
    name: 'Ingredient',
    component: () => import('@/views/IngredientManage.vue'),
    meta: { title: '库存管理' }
  },
  {
    path: '/financial',
    name: 'Financial',
    component: () => import('@/views/Financial.vue'),
    meta: { title: '财务统计' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - Cash Register System` : 'Cash Register System'
  next()
})

export default router
