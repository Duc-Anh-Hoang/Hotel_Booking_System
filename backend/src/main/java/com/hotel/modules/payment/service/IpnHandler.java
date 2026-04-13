package com.hotel.modules.payment.service;

import com.hotel.modules.payment.dto.response.IpnResponse;

import java.util.Map;

public interface IpnHandler {
    public IpnResponse process(Map<String, String> params);
}
