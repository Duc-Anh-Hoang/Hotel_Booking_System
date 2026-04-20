import { Box, Grid } from '@mui/material'
import InfomationRental from './Components/InfomationRental'
import InfomationCustomer from './Components/InfomationCustomer'
import Checkout from './Components/Checkout'
import Policy from './Components/Policy'

const Review = () => {
  return (
    <Box sx={{ flexGrow: 1, p: { xs: 2, md: 4 }, maxWidth: '1440px', mx: 'auto' }}>
      <Grid container spacing={4} columns={10}>
        <Grid size={{ xs: 10, md: 6 }}>
          <Grid container direction="column" spacing={4}>
            <Grid>
              <InfomationCustomer />
            </Grid>
            <Grid>
              <Policy />
            </Grid>
          </Grid>
        </Grid>
        <Grid size={{ xs: 10, md: 4 }}>
          <Grid container direction="column" spacing={4}>
            <Grid>
              <InfomationRental />
            </Grid>
            <Grid>
              <Checkout />
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </Box>
  )
}

export default Review