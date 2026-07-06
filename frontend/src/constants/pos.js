export const RECIPE_CATEGORIES = [
  { label: '全部', value: '' },
  { label: '朗姆基酒', value: '朗姆基酒' },
  { label: '伏特加基酒', value: '伏特加基酒' },
  { label: '威士忌基酒', value: '威士忌基酒' },
  { label: '龙舌兰基酒', value: '龙舌兰基酒' },
  { label: '无酒精', value: '无酒精' }
]

export const PAYMENT_OPTIONS = [
  { label: '现金', value: 1 },
  { label: '微信', value: 2 },
  { label: '支付宝', value: 3 },
  { label: '会员卡', value: 4 }
]

export const PAYMENT_TYPE_LABELS = PAYMENT_OPTIONS.reduce((acc, option) => {
  acc[option.value] = option.label
  return acc
}, {})
