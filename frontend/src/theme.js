import { extendTheme } from '@mui/material/styles'

const HEADER_HEIGHT = '58px'
const PAYMENT_BAR_HEIGHT = '50px'

const theme = extendTheme({
  typography: {
    fontFamily: '"Inter", sans-serif',
  },
  hotel_booking: {
    headerHeight: HEADER_HEIGHT,
    payment: {
      paymentBarHeight: PAYMENT_BAR_HEIGHT,
      paymentContentHeight: `calc(100vh - ${HEADER_HEIGHT} - ${PAYMENT_BAR_HEIGHT})`
    }
  },
  colorSchemes: {
    light: {
      palette: {
        primary: {
          main: '#ffc7dbff',      // Màu nền nút bấm chính
          dark: '#c02860ff',      // Màu nền nút khi hover
          contrastText: '#a01b4ccd' // Màu chữ trong nút
        },
        secondary: {
          main: '#9a1c48ff',      // Màu chữ Welcome, Link chính
          dark: '#c02860ff'       // Màu Link khi hover
        },
        text: {
          primary: '#000000',     // Màu chữ chính (đen)
          secondary: '#606060'    // Màu chữ phụ (xám)
        },
        background: {
          paper: 'rgba(255, 255, 255, 0.92)', // Nền trắng mờ (Glassmorphism)
          default: '#ccebffff'                // Nền xanh nhạt của trang
        },
        // Thêm các màu tùy chỉnh cho Input
        action: {
          inputBg: '#e8f6ffff',
          inputLabel: '#cbbbc2ff',
          inputLabelFocus: '#ac184ecd',
          inputBorder: '#c8acb8ff',
          inputBorderFocus: '#b0305fcd'
        }
      }
    }
  },
  colorSchemeSelector: 'class',
  components: {
    MuiTypography: {
      styleOverrides: {
        root: {
          fontFamily: '"Inter", sans-serif'
        },
        body1: { fontSize: '0.875rem' },
        h6: { fontWeight: '550' }
      }
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backdropFilter: 'blur(10px)',
          boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.37)'
        }
      }
    },
    MuiInputLabel: {
      styleOverrides: {
        root: ({ theme }) => ({
          fontSize: '0.875rem',
          color: theme.vars.palette.action.inputLabel,
          '&.Mui-focused': {
            color: theme.vars.palette.action.inputLabelFocus
          }
        })
      }
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: ({ theme }) => ({
          borderRadius: '16px',
          fontSize: '0.875rem',
          backgroundColor: theme.vars.palette.action.inputBg,
          '& fieldset': {
            borderColor: theme.vars.palette.action.inputBorder
          },
          '&:hover fieldset': {
            borderColor: `${theme.vars.palette.action.inputBorderFocus} !important`,
            borderWidth: '1.5px'
          },
          '&.Mui-focused fieldset': {
            borderColor: `${theme.vars.palette.action.inputBorderFocus} !important`,
            borderWidth: '1.5px'
          }
        }),
        input: {
          padding: '8px 12px'
        }
      }
    },
    MuiTextField: {
      defaultProps: {
        size: 'small'
      },
      styleOverrides: {
        root: ({ theme }) => ({
          '&:hover .MuiInputLabel-root': {
            color: theme.vars.palette.action.inputLabelFocus
          }
        })
      }
    },
    MuiButton: {
      styleOverrides: {
        root: {
          '&:hover': {
            color: '#fff'
          }
        }
      }
    },
    MuiSelect: {
      styleOverrides: {
        select: {
          padding: '8px 12px',
          display: 'flex',
          alignItems: 'center'
        }
      }
    }
  }
})

export default theme