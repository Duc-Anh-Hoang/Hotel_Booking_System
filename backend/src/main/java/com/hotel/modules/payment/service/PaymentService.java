package com.hotel.modules.payment.service;

import com.hotel.modules.booking.entity.Booking;
import com.hotel.modules.booking.entity.BookingStatus;
import com.hotel.modules.email.service.EmailService;
import com.hotel.modules.payment.entity.Payment;
import com.hotel.modules.payment.entity.PaymentGateway;
import com.hotel.modules.payment.entity.PaymentStatus;
import com.hotel.modules.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final PaymentRepository paymentRepository;


    @Transactional
    public Payment createInitialPayment(Booking booking, BigDecimal amount, PaymentGateway gateway) {
        Payment payment = Payment.builder()
                .booking(booking)
                .amount(amount)
                .gateway(gateway)
                .status(PaymentStatus.PENDING)
                .currency("VND")
                .build();
        return paymentRepository.save(payment);
    }

    @Transactional
    public void processPaymentCallback(String transactionId, String responseJson, boolean isSuccess) {
        Payment payment = paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch"));

        if (isSuccess) {
            payment.setStatus(PaymentStatus.SUCCESS);
            payment.setPaidAt(LocalDateTime.now());
        } else {
            payment.setStatus(PaymentStatus.FAILED);
        }

        payment.setRawResponse(responseJson);
        paymentRepository.save(payment);
    }

    public Payment findByTransactionId(String transactionId) {
        return paymentRepository.findByTransactionId(transactionId).orElse(null);
    }

    @Transactional
    public void updatePaymentResult(Payment payment, String gatewayTransactionNo, String rawResponse, boolean isSuccess) {

        if (isSuccess) {

            payment.setStatus(PaymentStatus.SUCCESS);
            payment.setPaidAt(LocalDateTime.now());

            Booking booking = payment.getBooking();
            if (booking != null) {
                booking.setStatus(BookingStatus.CONFIRMED);
            }

        } else {
            payment.setStatus(PaymentStatus.FAILED);
//           Booking booking = payment.getBooking();
//            if (booking != null) {
//                booking.setStatus(BookingStatus.CANCEL);
//            }
        }

        payment.setRawResponse(rawResponse);
        paymentRepository.save(payment);
    }
}
