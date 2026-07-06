import request from '@/utils/request'

export function getFinancialSummary(period) {
  return request({
    url: `/financial/${period}`,
    method: 'get'
  })
}

export function getFinancialOrderList(params) {
  return request({
    url: '/financial/orders',
    method: 'get',
    params
  })
}
