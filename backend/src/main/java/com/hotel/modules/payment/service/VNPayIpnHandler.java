package com.hotel.modules.payment.service;

import com.hotel.modules.payment.constant.VNPayParams;
import com.hotel.modules.payment.constant.VnpIpnResponseConst;
import com.hotel.modules.payment.dto.response.IpnResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class VNPayIpnHandler implements  IpnHandler {
    private final VNPayService vnPayService;

    @Override
    public IpnResponse process(Map<String, String> params){
        if(!vnPayService.verifyIpn(params)){
            return VnpIpnResponseConst.SIGNATURE_FAILED;
        }
        IpnResponse ipnResponse;
        String txnRef=  params.get(VNPayParams.TXN_REF);
        try{
//            xử lý booking thanh cong
//            Long BookingId = Long.parseLong(txnRef);
//            bookingService.markBooked(bookingId);
                ipnResponse = VnpIpnResponseConst.SUCCESS;
        }
//        catch (Exception e){
//            kh co don boong king do
//        }
        catch (Exception e){
            ipnResponse = VnpIpnResponseConst.UNKNOWN_ERROR;
        }
        return ipnResponse;
    }
}
