package com.hotel.modules.payment.constant;

import com.hotel.modules.payment.dto.response.IpnResponse;

public class MomoIpnResponseConst {
    public static final IpnResponse SUCCESS = new IpnResponse("0", "Success");

    public static final IpnResponse SIGNATURE_MISMATCH = new IpnResponse("98", "Signature mismatch");
    public static final IpnResponse ORDER_NOT_FOUND = new IpnResponse("01", "Order not found");
    public static final IpnResponse AMOUNT_MISMATCH = new IpnResponse("04", "Amount mismatch");
    public static final IpnResponse ORDER_ALREADY_CONFIRMED = new IpnResponse("02", "Order already confirmed");
    public static final IpnResponse UNKNOWN_ERROR = new IpnResponse("99", "Unknown error");
}
