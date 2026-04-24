package com.hotel.modules.invoice.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class InvoiceItemResponse {

    private Long id;
    private Long invoiceId;
    private String itemType;
    private String description;
    private Short quantity;
    private BigDecimal unitPrice;
    private BigDecimal lineTotal;
}
