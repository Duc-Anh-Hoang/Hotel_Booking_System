import { Box, Grid } from '@mui/material'
import InfomationRental from './Content/InfomationRental'
import InfomationCustomer from './Content/InfomationCustomer'
import Checkout from './Content/checkout'

const PaymentContent = () => {
  return (
    <Box sx={{ flexGrow: 1, p: 2 }}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          <InfomationCustomer />
        </Grid>

        <Grid item xs={12} md={6} container direction="column" spacing={2}>
          <Grid item>
            <InfomationRental />
          </Grid>
          <Grid item>
            <Checkout />
          </Grid>
        </Grid>
      </Grid>
    </Box>
  )
}

export default PaymentContent