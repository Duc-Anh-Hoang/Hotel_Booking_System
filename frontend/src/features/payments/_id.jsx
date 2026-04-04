import Container from '@mui/material/Container'
import PaymentBar from './PaymentBar/paymentBar'
import Header from '~/shared/components/layout/Header/Header'
import PaymentContent from './PaymentContent/PaymentContent'
function Payments() {
  return (
    <Container disableGutters maxWidth={false} sx={{ height: '100vh' }}>
      <Header />
      <PaymentBar />
      <PaymentContent />
    </Container>
  )
}

export default Payments