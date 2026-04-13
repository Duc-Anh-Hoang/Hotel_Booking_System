package com.hotel.modules.payment.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum Locale {
    VIETNAM("vn"),
    ENGLISH("en");

    private final String code;
}
