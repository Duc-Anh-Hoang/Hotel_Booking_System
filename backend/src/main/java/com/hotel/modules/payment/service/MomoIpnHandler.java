package com.hotel.modules.payment.service;

import com.hotel.modules.payment.constant.MomoIpnResponseConst;
import com.hotel.modules.payment.dto.response.IpnResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service("momoIpnHandler")
@RequiredArgsConstructor
public class MomoIpnHandler implements IpnHandler{
    private final IMomoService momoService;
    @Override
    public IpnResponse process(Map<String, String> params) {
        if (!momoService.verifyIpn(params)) {
            return MomoIpnResponseConst.SIGNATURE_MISMATCH;
        }

        String orderId = params.get("orderId");
        String resultCode = params.get("resultCode");

        try {
            if ("0".equals(resultCode)) {
                // Xử lý booking o day
                // Long bookingId = Long.parseLong(orderId);
                // bookingService.markAsPaid(bookingId);

                return MomoIpnResponseConst.SUCCESS;
            } else {
                return MomoIpnResponseConst.UNKNOWN_ERROR;
            }
        } catch (Exception e) {
            return MomoIpnResponseConst.UNKNOWN_ERROR;
        }
    }
}
