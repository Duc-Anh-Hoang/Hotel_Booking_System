import React from 'react'
import Box from '@mui/material/Box'
import Stepper from '@mui/material/Stepper'
import Step from '@mui/material/Step'
import StepLabel from '@mui/material/StepLabel'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import { styled } from '@mui/material/styles'
import StepConnector, { stepConnectorClasses } from '@mui/material/StepConnector'

const steps = ['Review Booking', 'Guest & Payment Detail', 'Booking Confirmation']
const ColorlibConnector = styled(StepConnector)(({ theme }) => ({
  [`&.${stepConnectorClasses.alternativeLabel}`]: {
    top: 12,
  },
  [`&.${stepConnectorClasses.active}`]: {
    [`& .${stepConnectorClasses.line}`]: {
      backgroundColor: theme.palette.primary.main,
    },
  },
  [`&.${stepConnectorClasses.completed}`]: {
    [`& .${stepConnectorClasses.line}`]: {
      backgroundColor: theme.palette.primary.main,
    },
  },
  [`& .${stepConnectorClasses.line}`]: {
    height: 2,
    border: 0,
    backgroundColor: '#d8d7d7e0',
    borderRadius: 1,
  },
}))
const StepCircle = styled('div')(({ theme }) => ({
  width: 24,
  height: 24,
  borderRadius: '50%',
  display: 'flex',
  border: '1px solid #d8d7d7e0',
  alignItems: 'center',
  justifyContent: 'center',
  color: '#757575',
  fontSize: '12px',
  backgroundColor: 'transparent',
  '.Mui-completed &': {
    backgroundColor: theme.palette.primary.main,
    color: '#fff',
    border: 'none',
  },
  '.Mui-active &': {
    backgroundColor: theme.palette.primary.main,
    color: '#fff',
    border: 'none',
  }
}))

const CustomStepLabel = styled(StepLabel)(({ theme }) => ({
  '& .MuiStepLabel-label': { color: '#757575' },
  '& .MuiStepLabel-label.Mui-active': { color: theme.palette.primary.main },
  '& .MuiStepLabel-label.Mui-completed': { color: theme.palette.primary.main }
}))

const CustomStepIcon = (props) => {
  const { icon } = props
  return <StepCircle>{icon}</StepCircle>
}

const PaymentBar = () => {
  const [activeStep, setActiveStep] = React.useState(0)

  const handleNext = () => {
    setActiveStep((prevActiveStep) => prevActiveStep + 1)
  }

  const handleBack = () => {
    setActiveStep((prevActiveStep) => prevActiveStep - 1)
  }

  const handleReset = () => {
    setActiveStep(0)
  }

  return (
    <Box sx={{ display: 'flex', justifyContent: 'center', padding: 1 }}>
      <Box sx={{ width: '80%' }}>
        <Stepper activeStep={activeStep} connector={<ColorlibConnector />}
          alternativeLabel>
          {steps.map((label) => (
            <Step key={label}>
              <CustomStepLabel StepIconComponent={CustomStepIcon}>{label}</CustomStepLabel>
            </Step>
          ))}
        </Stepper>


        {/* {activeStep === steps.length ?
          <Box>
            <Typography sx={{ mt: 2, mb: 1 }}>
              All steps completed - you&apos;re finished
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'row', pt: 2 }}>
              <Box sx={{ flex: '1 1 auto' }} />
              <Button onClick={handleReset}>Reset</Button>
            </Box>
          </Box>
          :
          <Box>

            <Box sx={{ display: 'flex', flexDirection: 'row', pt: 2 }}>
              <Button
                color="inherit"
                disabled={activeStep === 0}
                onClick={handleBack}
                sx={{ mr: 1 }}
              >
                Back
              </Button>
              <Box sx={{ flex: '1 1 auto' }} />
              <Button onClick={handleNext}>
                {activeStep === steps.length - 1 ? 'Finish' : 'Next'}
              </Button>
            </Box>
          </Box>
        } */}
      </Box>
    </Box>

  )
}

export default PaymentBar