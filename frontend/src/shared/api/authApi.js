import axios from 'axios'
import { createVnpayPaymentUrl, createMomoPaytUrl } from './index'

// API base URL configuration
const API_URL = '/api/v1/auth'

export const loginApi = async (email, password) => {
  const response = await axios.post(`${API_URL}/login`, { email, password })
  return response.data
}

export const registerApi = async (fullName, email, phone, password) => {
  const response = await axios.post(`${API_URL}/register`, {
    fullName,
    email,
    phone,
    password
  })
  return response.data
}

export { createVnpayPaymentUrl, createMomoPaytUrl }
