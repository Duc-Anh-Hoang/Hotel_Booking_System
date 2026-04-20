import React from 'react'
import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '../shared/hooks/useAuth'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'

const PrivateRoute = ({ requiredRole }) => {
  const { isAuthenticated, user, loading } = useAuth()

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <CircularProgress color="primary" />
      </Box>
    )
  }

  // Not logged in -> Redirect to Login
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  // If a specific role is required, check roles
  if (requiredRole && user && user.roles) {
    const hasRole = user.roles.some(role => role.roleName === requiredRole || role.authority === `ROLE_${requiredRole}`)
    if (!hasRole) {
      // Forbidden -> Could redirect to a 'Not Authorized' page or home
      return <Navigate to="/" replace />
    }
  }

  return <Outlet />
}

export default PrivateRoute
