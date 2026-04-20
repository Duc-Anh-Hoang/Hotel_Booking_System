import React from 'react'
import { Box, Typography, Button, Avatar } from '@mui/material'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../../shared/hooks/useAuth'

const Header = () => {
  const { user, isAuthenticated, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <Box sx={{
      height: (theme) => theme.hotel_booking.headerHeight,
      width: '100%',
      p: 2,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      backgroundColor: 'primary.light',
      color: 'primary.contrastText',
      boxShadow: 1,
      zIndex: (theme) => theme.zIndex.drawer + 1
    }}>
      <Typography variant="h6" sx={{ fontWeight: 'bold', cursor: 'pointer' }} onClick={() => navigate('/')}>
        Hotel Booking
      </Typography>

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        {isAuthenticated && user ? (
          <>
            <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main' }}>
              {user.fullName?.charAt(0).toUpperCase() || 'U'}
            </Avatar>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>
              {user.fullName}
            </Typography>
            <Button 
              variant="outlined" 
              color="inherit" 
              size="small" 
              onClick={handleLogout}
              sx={{ borderColor: 'white', '&:hover': { borderColor: 'white', backgroundColor: 'rgba(255,255,255,0.1)' } }}
            >
              Đăng xuất
            </Button>
          </>
        ) : (
          <Button 
            variant="contained" 
            color="primary"
            onClick={() => navigate('/login')}
          >
            Đăng nhập
          </Button>
        )}
      </Box>
    </Box>
  )
}

export default Header