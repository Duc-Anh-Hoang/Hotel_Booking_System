package com.hotel.modules.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class IpnResponse {
    @JsonProperty("RspCode")
    private String rspCode;

    @JsonProperty("Message")
    private String message;
}
