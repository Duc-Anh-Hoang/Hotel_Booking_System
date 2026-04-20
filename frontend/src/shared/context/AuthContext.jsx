import React, { createContext, useState, useEffect } from 'react'

export const AuthContext = createContext(null)

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Check for token in localStorage on app load
    const storedToken = localStorage.getItem('token')
    const storedUserStr = localStorage.getItem('user')
    
    if (storedToken && storedUserStr) {
      try {
        const storedUser = JSON.parse(storedUserStr)
        setToken(storedToken)
        setUser(storedUser)
        setIsAuthenticated(true)
        
        // Cấu hình axios default header nếu cần
        // axios.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`;
      } catch (error) {
        console.error('Failed to parse user info', error)
        logout()
      }
    }
    setLoading(false)
  }, [])

  const login = (accessToken, userInfo) => {
    setToken(accessToken)
    setUser(userInfo)
    setIsAuthenticated(true)
    
    localStorage.setItem('token', accessToken)
    localStorage.setItem('user', JSON.stringify(userInfo))
  }

  const logout = () => {
    setToken(null)
    setUser(null)
    setIsAuthenticated(false)
    
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    // delete axios.defaults.headers.common['Authorization'];
  }

  return (
    <AuthContext.Provider value={{ user, token, isAuthenticated, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  )
}
