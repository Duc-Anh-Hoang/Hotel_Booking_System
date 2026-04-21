import axios from 'axios';

// Tạo một instance (bản sao) của axios để dùng chung cho toàn bộ app
const axiosInstance = axios.create({
  // baseURL: 'http://localhost:8080/api/v1', // Có thể bật lên nếu bạn không dùng proxy, hiện tại bạn đang dùng Vite proxy
});

// Chú ý: Đưa đoạn code chặn request (Interceptor) vào đây
axiosInstance.interceptors.request.use(
  (config) => {
    // 1. Lấy token từ kho chứa (localStorage)
    const token = localStorage.getItem('token');
    
    // 2. Nếu có token, tự động gắn lệnh "Bearer " + token vào Header
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // 3. Trả về cho nó bay đi gọi server
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Bắt luôn lỗi 401 (Hết hạn Token) để văng ra màn hình đăng nhập
axiosInstance.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      // Ép xóa hết token cũ đi
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      // Nhảy sang trang đăng nhập ngay lập tức
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default axiosInstance;
