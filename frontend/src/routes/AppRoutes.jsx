import { Route, Routes } from 'react-router-dom'
import Payments from '~/features/payments/_id'
import LoginPage from '~/features/auth/LoginPage'
import RegisterPage from '~/features/auth/RegisterPage'
import PrivateRoute from './PrivateRoute'
import MainLayout from '../shared/components/layout/MainLayout'

const AppRoutes = () => {
  return (
    <Routes>
      {/* Public route không có Header/Sidebar (Full màn hình) */}
      <Route path='/login' element={<LoginPage />} />
      <Route path='/register' element={<RegisterPage />} />
      
      {/* Các route nằm trong Layout chung */}
      <Route element={<MainLayout />}>
        {/* Route public nhưng vẫn có Header (nhưng Sidebar ẩn vì chưa đăng nhập) */}
        <Route path='/payment' element={<Payments />} />
        
        {/* Example protected blocks (cần đăng nhập, sẽ hiện sidebar) */}
        <Route element={<PrivateRoute />}>
          {/* <Route path="/dashboard" element={<DashboardPage />} /> */}
        </Route>
      </Route>
    </Routes>
  )
}

export default AppRoutes