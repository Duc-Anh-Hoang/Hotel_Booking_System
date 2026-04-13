package com.hotel.modules.payment.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VNPayRequest {
    private String amount;
    private String txnRef;
    private String ipAddress;
    private String requestId;
}
