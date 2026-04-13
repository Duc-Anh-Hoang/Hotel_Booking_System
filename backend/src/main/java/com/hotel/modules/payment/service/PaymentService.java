package com.hotel.modules.payment.service;


import com.hotel.modules.payment.dto.request.PaymentRequest;
import com.hotel.modules.payment.dto.response.PaymentResponse;

import java.util.Map;

public interface PaymentService {
    public PaymentResponse init(PaymentRequest request);
    public boolean verifyIpn(Map<String, String > params);
}
