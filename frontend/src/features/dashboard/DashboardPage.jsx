import React from 'react';
import { Box, Typography, Paper } from '@mui/material';
import { useAuth } from '../../shared/hooks/useAuth';

const DashboardPage = () => {
  const { user } = useAuth();

  return (
    <Box sx={{ p: 4 }}>
      <Paper elevation={3} sx={{ p: 4, borderRadius: 2 }}>
        <Typography variant="h4" gutterBottom>
          Xin chào, {user?.fullName || 'Người dùng'}!
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Chào mừng bạn quay trở lại với Hệ thống Quản lý Khách sạn. Bạn đã đăng nhập thành công.
        </Typography>
        {/* We can add more components like "My Bookings" or charts here later */}
      </Paper>
    </Box>
  );
};

export default DashboardPage;
