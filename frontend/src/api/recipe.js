import request from '@/utils/request'

/**
 * 获取配方分页列表
 */
export function getRecipePage(params) {
  return request({
    url: '/recipe/page',
    method: 'get',
    params
  })
}

/**
 * 获取配方详情
 */
export function getRecipeDetail(id) {
  return request({
    url: `/recipe/${id}`,
    method: 'get'
  })
}

/**
 * 创建配方
 */
export function createRecipe(data) {
  return request({
    url: '/recipe',
    method: 'post',
    data
  })
}

/**
 * 更新配方
 */
export function updateRecipe(data) {
  return request({
    url: '/recipe',
    method: 'put',
    data
  })
}

/**
 * 删除配方
 */
export function deleteRecipe(id) {
  return request({
    url: `/recipe/${id}`,
    method: 'delete'
  })
}

/**
 * 检查配方库存
 */
export function checkRecipeStock(id, quantity) {
  return request({
    url: `/recipe/check-stock/${id}`,
    method: 'get',
    params: { quantity }
  })
}
