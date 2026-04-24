package com.hotel.modules.payment.service;

import com.hotel.modules.booking.entity.Booking;
import com.hotel.modules.booking.entity.BookingStatus;
import com.hotel.modules.invoice.dto.request.InvoiceCreateRequest;
import com.hotel.modules.invoice.dto.request.InvoiceItemRequest;
import com.hotel.modules.invoice.service.IInvoiceService;
import com.hotel.modules.payment.entity.Payment;
import com.hotel.modules.payment.entity.PaymentGateway;
import com.hotel.modules.payment.entity.PaymentStatus;
import com.hotel.modules.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final IInvoiceService invoiceService;

    // ── Tạo payment ban đầu (PENDING) khi khách bắt đầu thanh toán ──
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

    // ── Tìm payment theo transactionId ──────────────────────────────
    public Payment findByTransactionId(String transactionId) {
        return paymentRepository.findByTransactionId(transactionId).orElse(null);
    }

    // ── Cập nhật kết quả thanh toán từ IPN callback ─────────────────
    @Transactional
    public void updatePaymentResult(Payment payment,
                                    String gatewayTransactionNo,
                                    String rawResponse,
                                    boolean isSuccess) {
        if (isSuccess) {
            payment.setStatus(PaymentStatus.SUCCESS);
            payment.setPaidAt(LocalDateTime.now());

            // Cập nhật trạng thái booking → CONFIRMED
            Booking booking = payment.getBooking();
            if (booking != null) {
                booking.setStatus(BookingStatus.CONFIRMED);

                // Tự động tạo hóa đơn sau khi thanh toán thành công
                autoCreateInvoice(payment, booking);
            }

        } else {
            payment.setStatus(PaymentStatus.FAILED);

            // Huỷ booking khi thanh toán thất bại
            Booking booking = payment.getBooking();
            if (booking != null && booking.getStatus() == BookingStatus.PENDING) {
                booking.setStatus(BookingStatus.CANCELLED);
            }
        }

        payment.setRawResponse(rawResponse);
        paymentRepository.save(payment);
    }

    // ── Private: tự động tạo invoice từ thông tin booking/payment ───
    private void autoCreateInvoice(Payment payment, Booking booking) {
        try {
            // Kiểm tra invoice chưa tồn tại để tránh duplicate
            if (invoiceService.existsByBookingId(booking.getBookingId())) {
                log.warn("Invoice đã tồn tại cho bookingId={}, bỏ qua tạo mới", booking.getBookingId());
                return;
            }

            // Tạo invoice item từ thông tin phòng trong booking
            InvoiceItemRequest roomItem = new InvoiceItemRequest();
            roomItem.setItemType("ROOM");
            roomItem.setDescription("Phòng " + booking.getRoom().getRoomNumber()
                    + " x " + booking.getTotalNights() + " đêm");
            roomItem.setQuantity(booking.getTotalNights());
            roomItem.setUnitPrice(booking.getRoomPriceSnapshot());

            InvoiceCreateRequest invoiceRequest = new InvoiceCreateRequest();
            invoiceRequest.setBookingId(booking.getBookingId());
            invoiceRequest.setPaymentId(payment.getPaymentId());
            invoiceRequest.setDiscountAmount(BigDecimal.ZERO);
            invoiceRequest.setNotes("Tự động tạo sau khi thanh toán qua " + payment.getGateway());
            invoiceRequest.setItems(List.of(roomItem));

            invoiceService.createInvoice(invoiceRequest);
            log.info("Đã tự động tạo invoice cho bookingId={}", booking.getBookingId());

        } catch (Exception e) {
            // Không để lỗi invoice làm rollback transaction payment
            log.error("Lỗi khi tự động tạo invoice cho bookingId={}: {}",
                    booking.getBookingId(), e.getMessage());
        }
    }
}
