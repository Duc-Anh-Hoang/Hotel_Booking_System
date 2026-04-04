import React from 'react'
import Box from '@mui/material/Box'

const Header = () => {
  return (
    <Box sx={{
      height: (theme) => theme.hotel_booking.headerHeight,
      width: '100%',
      p: 2,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      backgroundColor: 'primary.light',
      color: 'primary.contrastText'
    }}>
      HEADER
    </Box>
  )
}

export default Header