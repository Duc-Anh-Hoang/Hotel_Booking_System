package com.hotel.modules.payment.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {
    private String amount;
    private String txnRef;
    private String ipAddress;
    private String requestId;
}
