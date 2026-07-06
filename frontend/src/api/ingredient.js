import request from '@/utils/request'

export function getIngredientList() {
  return request({
    url: '/ingredient/list',
    method: 'get'
  })
}

export function getIngredientById(id) {
  return request({
    url: `/ingredient/${id}`,
    method: 'get'
  })
}

export function createIngredient(data) {
  return request({
    url: '/ingredient',
    method: 'post',
    data
  })
}

export function updateIngredient(data) {
  return request({
    url: '/ingredient',
    method: 'put',
    data
  })
}
