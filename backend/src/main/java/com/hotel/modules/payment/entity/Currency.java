package com.hotel.modules.payment.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum Currency {
    VND("VND"),
    USD("USD");

    private final String value;
}
