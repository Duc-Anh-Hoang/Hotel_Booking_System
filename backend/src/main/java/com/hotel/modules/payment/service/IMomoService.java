package com.hotel.modules.payment.service;

import com.hotel.modules.payment.dto.request.MoMoRequest;
import com.hotel.modules.payment.dto.response.MomoResponse;

import java.util.Map;

public interface IMomoService {
    public MomoResponse createQR(MoMoRequest request);
    public boolean verifyIpn(Map<String, String> params);
}
