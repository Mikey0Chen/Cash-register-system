import request from '@/utils/request'

export function createOrder(data) {
  return request({
    url: '/order',
    method: 'post',
    data
  })
}
