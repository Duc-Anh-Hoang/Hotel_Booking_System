import React, { useState, useEffect } from 'react'
import { 
  Box, Typography, Paper, TextField, Button, Avatar, 
  Grid, Divider, Alert, CircularProgress, Chip,
  Dialog, DialogTitle, DialogContent, DialogActions,
  IconButton, InputAdornment
} from '@mui/material'
import { 
  Person, Phone, Email, Shield, Save, Lock, 
  Visibility, VisibilityOff, LockOpen 
} from '@mui/icons-material'
import { getMyProfileApi, updateMyProfileApi } from '../../shared/api/userApi'
import { changePasswordApi } from '../../shared/api/authApi'

const ProfilePage = () => {
  const [profile, setProfile] = useState(null)
  const [formData, setFormData] = useState({ fullName: '', phone: '' })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState({ type: '', content: '' })

  // State cho đổi mật khẩu
  const [openPwDialog, setOpenPwDialog] = useState(false)
  const [pwData, setPwData] = useState({ oldPassword: '', newPassword: '', confirmPassword: '' })
  const [pwLoading, setPwLoading] = useState(false)
  const [pwError, setPwError] = useState('')
  const [showPw, setShowPw] = useState({ old: false, new: false, confirm: false })

  useEffect(() => {
    fetchProfile()
  }, [])

  const fetchProfile = async () => {
    try {
      const data = await getMyProfileApi()
      setProfile(data)
      setFormData({ fullName: data.fullName, phone: data.phone || '' })
    } catch (err) {
      setMessage({ type: 'error', content: 'Không thể tải thông tin cá nhân.' })
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setMessage({ type: '', content: '' })
    try {
      const updated = await updateMyProfileApi(formData)
      setProfile(updated)
      setMessage({ type: 'success', content: 'Cập nhật thông tin thành công!' })
    } catch (err) {
      setMessage({ type: 'error', content: 'Có lỗi xảy ra khi cập nhật.' })
    } finally {
      setSaving(false)
    }
  }

  const handlePwChange = (e) => {
    setPwData({ ...pwData, [e.target.name]: e.target.value })
  }

  const handlePwSubmit = async () => {
    setPwError('')
    if (pwData.newPassword !== pwData.confirmPassword) {
      setPwError('Mật khẩu xác nhận không khớp!')
      return
    }
    if (pwData.newPassword.length < 6) {
      setPwError('Mật khẩu mới phải có ít nhất 6 ký tự!')
      return
    }

    setPwLoading(true)
    try {
      await changePasswordApi(pwData.oldPassword, pwData.newPassword)
      setOpenPwDialog(false)
      setPwData({ oldPassword: '', newPassword: '', confirmPassword: '' })
      setMessage({ type: 'success', content: 'Đổi mật khẩu thành công!' })
    } catch (err) {
      const data = err.response?.data;
      let errMsg = 'Mật khẩu cũ không chính xác hoặc có lỗi xảy ra.';
      if (typeof data === 'string') errMsg = data;
      else if (data?.message) errMsg = data.message;
      else if (data?.error) errMsg = data.error;
      
      setPwError(errMsg);
    } finally {
      setPwLoading(false)
    }
  }

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
        <CircularProgress color="secondary" />
      </Box>
    )
  }

  return (
    <Box sx={{ maxWidth: 1000, mx: 'auto', p: { xs: 2, md: 4 } }}>
      <Typography variant="h4" sx={{ mb: 4, fontWeight: 800, color: 'secondary.main' }}>
        Trang cá nhân
      </Typography>

      <Grid container spacing={4}>
        <Grid item xs={12} md={4}>
          <Paper elevation={0} sx={{ 
            p: 4, textAlign: 'center', borderRadius: 4, 
            border: '1px solid', borderColor: 'divider', bgcolor: 'background.paper'
          }}>
            <Avatar sx={{ 
              width: 120, height: 120, mx: 'auto', mb: 2, 
              bgcolor: 'secondary.main', fontSize: '3rem',
              boxShadow: '0 8px 24px rgba(231, 78, 134, 0.2)'
            }}>
              {profile?.fullName?.charAt(0).toUpperCase()}
            </Avatar>
            <Typography variant="h6" sx={{ fontWeight: 700 }}>{profile?.fullName}</Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>{profile?.email}</Typography>
            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1 }}>
              {profile?.roles?.map(role => (
                <Chip key={role} label={role} size="small" color="secondary" variant="outlined" sx={{ fontWeight: 600 }} />
              ))}
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} md={8}>
          <Paper elevation={0} sx={{ p: 4, borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
            <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1, fontWeight: 700 }}>
              <Person color="secondary" /> Thông tin cơ bản
            </Typography>

            {message.content && <Alert severity={message.type} sx={{ mb: 3, borderRadius: 2 }}>{message.content}</Alert>}

            <form onSubmit={handleSubmit}>
              <Grid container spacing={3}>
                <Grid item xs={12}><TextField fullWidth label="Họ và tên" name="fullName" value={formData.fullName} onChange={handleChange} required /></Grid>
                <Grid item xs={12} md={6}><TextField fullWidth label="Email" value={profile?.email} disabled helperText="Email không thể thay đổi" /></Grid>
                <Grid item xs={12} md={6}><TextField fullWidth label="Số điện thoại" name="phone" value={formData.phone} onChange={handleChange} /></Grid>
              </Grid>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4 }}>
                <Button type="submit" variant="contained" color="secondary" disabled={saving} startIcon={saving ? <CircularProgress size={20} /> : <Save />} sx={{ px: 4, borderRadius: 2, fontWeight: 700 }}>
                  Lưu thay đổi
                </Button>
              </Box>
            </form>
          </Paper>

          <Paper elevation={0} sx={{ p: 4, mt: 3, borderRadius: 4, border: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Shield color="secondary" />
              <Box>
                <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>Bảo mật tài khoản</Typography>
                <Typography variant="body2" color="text.secondary">Thay đổi mật khẩu để bảo vệ tài khoản</Typography>
              </Box>
            </Box>
            <Button variant="outlined" color="secondary" onClick={() => setOpenPwDialog(true)} sx={{ borderRadius: 2, fontWeight: 700 }}>
              Đổi mật khẩu
            </Button>
          </Paper>
        </Grid>
      </Grid>

      {/* Dialog Đổi mật khẩu */}
      <Dialog open={openPwDialog} onClose={() => setOpenPwDialog(false)} fullWidth maxWidth="xs">
        <DialogTitle sx={{ fontWeight: 800, textAlign: 'center', pt: 3 }}>Thay đổi mật khẩu</DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 1, display: 'flex', flexDirection: 'column', gap: 3 }}>
            {pwError && <Alert severity="error">{pwError}</Alert>}
            <TextField
              fullWidth label="Mật khẩu hiện tại" name="oldPassword" type={showPw.old ? 'text' : 'password'}
              value={pwData.oldPassword} onChange={handlePwChange}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShowPw({...showPw, old: !showPw.old})}>{showPw.old ? <VisibilityOff /> : <Visibility />}</IconButton>
                  </InputAdornment>
                ),
              }}
            />
            <TextField
              fullWidth label="Mật khẩu mới" name="newPassword" type={showPw.new ? 'text' : 'password'}
              value={pwData.newPassword} onChange={handlePwChange}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShowPw({...showPw, new: !showPw.new})}>{showPw.new ? <VisibilityOff /> : <Visibility />}</IconButton>
                  </InputAdornment>
                ),
              }}
            />
            <TextField
              fullWidth label="Xác nhận mật khẩu mới" name="confirmPassword" type={showPw.confirm ? 'text' : 'password'}
              value={pwData.confirmPassword} onChange={handlePwChange}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShowPw({...showPw, confirm: !showPw.confirm})}>{showPw.confirm ? <VisibilityOff /> : <Visibility />}</IconButton>
                  </InputAdornment>
                ),
              }}
            />
          </Box>
        </DialogContent>
        <DialogActions sx={{ p: 3, justifyContent: 'center', gap: 2 }}>
          <Button onClick={() => setOpenPwDialog(false)} color="inherit" sx={{ fontWeight: 700 }}>Hủy</Button>
          <Button onClick={handlePwSubmit} variant="contained" color="secondary" disabled={pwLoading} sx={{ px: 4, borderRadius: 2, fontWeight: 700 }}>
            {pwLoading ? <CircularProgress size={24} /> : 'Cập nhật'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default ProfilePage
