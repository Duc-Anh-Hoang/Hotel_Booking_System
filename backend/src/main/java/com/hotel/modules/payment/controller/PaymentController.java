package com.hotel.modules.payment.controller;

import com.hotel.modules.payment.dto.request.PaymentRequest;
import com.hotel.modules.payment.dto.response.IpnResponse;
import com.hotel.modules.payment.dto.response.PaymentResponse;
import com.hotel.modules.payment.service.IpnHandler;
import com.hotel.modules.payment.service.PaymentService;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@Slf4j
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {
    private  final IpnHandler ipnHandler;
    private final PaymentService paymentService;
    @GetMapping("/vnpay_ipn")
    IpnResponse processIpn(@RequestParam Map<String, String> params){
        return ipnHandler.process(params);
    }

    @PostConstruct
    public void init() {
        log.info(">>> PaymentController LOADED <<<");
    }
    @PostMapping("/vnpay_url")
    PaymentResponse createVNPayUrl(@RequestBody PaymentRequest request){
    return paymentService.init(request);
    }
}

