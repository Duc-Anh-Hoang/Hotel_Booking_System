import KingBedOutlinedIcon from '@mui/icons-material/KingBedOutlined'
import VerifiedOutlinedIcon from '@mui/icons-material/VerifiedOutlined'
import { Typography } from '@mui/material'
import Checkbox from '@mui/material/Checkbox'
import FormControlLabel from '@mui/material/FormControlLabel'
import FormGroup from '@mui/material/FormGroup'
import { Box } from '@mui/system'

const InfoBooking = () => {
  const roomOptions = [
    'Phòng không hút thuốc',
    'Phòng liên thông',
    'Tầng lầu',
    'Ban công',
    'Máy chiếu',
    'Bàn bida',
    'Loại giường'
  ]
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
      <Box >
        <Typography variant='h6' sx={{ display: 'flex', alignItems: 'center', gap: 1, fontWeight: '550' }}>
          <KingBedOutlinedIcon />Thông tin đặt phòng
        </Typography>
        <Typography variant='b4' sx={{ color: '#606060' }}>Thêm thông tin đặt phòng để xác nhận phòng</Typography>
      </Box>
      <Box sx={{
        padding: 3,
        backgroundColor: '#ff2fee11',
        borderRadius: '12px',
        display: 'flex',
        justifyContent: 'space-between'
      }}>
        <Box sx={{ display: 'flex', gap: 2.5 }}>
          <Box>
            <Typography sx={{ textAlign: 'center', color: 'primary.main', fontWeight: '600', fontSize: '1rem', borderBottom: '1px solid #f19fb9' }}>Checkin</Typography>
            <Typography sx={{ textAlign: 'center', color: '#3f3f3f', fontWeight: '600', fontSize: '1.125rem', marginTop: 2 }}>Thứ 7, 4 tháng 04 2026</Typography>
            <Typography sx={{ textAlign: 'center', color: '#5e5e5e', fontWeight: '500', fontSize: '0.875rem' }}>Từ 14:00</Typography>
          </Box>
          <Box>
            <Typography sx={{ textAlign: 'center', color: 'primary.main', fontWeight: '600', fontSize: '1rem', borderBottom: '1px solid #f19fb9' }}>checkout</Typography>
            <Typography sx={{ textAlign: 'center', color: '#3f3f3f', fontWeight: '600', fontSize: '1.125rem', marginTop: 2 }}>Thứ 2, 8 tháng 04 2026</Typography>
            <Typography sx={{ textAlign: 'center', color: '#5e5e5e', fontWeight: '500', fontSize: '0.875rem' }}>Trước 12:00</Typography>
          </Box>
        </Box>
        <Box sx={{ display: 'flex', gap: 2.5 }}>
          <Box>
            <Typography sx={{ textAlign: 'center', color: 'primary.main', fontWeight: '600', fontSize: '1rem', borderBottom: '1px solid #f19fb9' }}>Nights</Typography>
            <Typography sx={{ textAlign: 'center', color: '#3f3f3f', fontWeight: '600', fontSize: '1.125rem', marginTop: 2 }}>2</Typography>
          </Box>
          <Box>
            <Typography sx={{ textAlign: 'center', color: 'primary.main', fontWeight: '600', fontSize: '1rem', borderBottom: '1px solid #f19fb9' }}>People</Typography>
            <Typography sx={{ textAlign: 'center', color: '#3f3f3f', fontWeight: '600', fontSize: '1.125rem', marginTop: 2 }}>4</Typography>
          </Box>
        </Box>
      </Box>

      <Box sx={{ marginTop: 1 }}>
        <Typography variant='h6' sx={{ display: 'flex', alignItems: 'center', gap: 1, fontWeight: '550' }}>
          <VerifiedOutlinedIcon />Yêu cầu đặt biệt
        </Typography>
        <Typography variant='b4' sx={{ color: '#606060' }}>Tất cả các yêu cầu đặc biệt tùy thuộc vào tình trạng sẵn có và không được đảm bảo. Nhận phòng sớm hoặc đưa đón sân bay có thể phát sinh thêm phí</Typography>
      </Box>
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: '8px 24px', mt: 1 }}>
        {roomOptions.map((option, index) => (
          <FormControlLabel
            key={index}
            control={<Checkbox size="small" sx={{ color: 'primary.main', '&.Mui-checked': { color: 'primary.main' } }} />}
            label={<Typography sx={{ color: '#501157', fontWeight: '600', fontSize: '0.875rem' }}>{option}</Typography>}
          />
        ))}
      </Box>
    </Box>
  )
}

export default InfoBooking