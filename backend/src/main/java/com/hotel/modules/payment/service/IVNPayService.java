package com.hotel.modules.payment.service;


import com.hotel.modules.payment.dto.request.VNPayRequest;
import com.hotel.modules.payment.dto.response.VNPayResponse;

import java.util.Map;

public interface IVNPayService {
    public VNPayResponse init(VNPayRequest request);
    public boolean verifyIpn(Map<String, String > params);
}
