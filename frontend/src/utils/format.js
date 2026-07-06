export function formatCurrency(value) {
  const amount = Number(value ?? 0)
  return amount.toFixed(2)
}

export function formatDateTime(value, locale = 'zh-CN') {
  if (!value) {
    return ''
  }

  return new Date(value).toLocaleString(locale, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}
