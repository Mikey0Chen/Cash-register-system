import axios from 'axios'
import { ElMessage } from 'element-plus'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

const request = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000
})

function getErrorMessage(error) {
  if (error.response?.data?.message) {
    return error.response.data.message
  }

  if (error.code === 'ECONNABORTED') {
    return '请求超时，请稍后重试'
  }

  if (error.response?.status >= 500) {
    return '服务暂时不可用，请稍后重试'
  }

  if (error.message) {
    return error.message
  }

  return '网络错误'
}

// 请求拦截器
request.interceptors.request.use(
  config => {
    config.headers.Accept = 'application/json'
    return config
  },
  error => {
    console.error('请求错误：', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  error => {
    console.error('响应错误：', error)
    ElMessage.error(getErrorMessage(error))
    return Promise.reject(error)
  }
)

export default request
