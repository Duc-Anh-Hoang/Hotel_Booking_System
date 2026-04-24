package com.hotel.modules.dashboard.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class RecentBookingDTO {
    private Long id;
    private String customerName;
    private String roomNumber;
    private LocalDateTime bookingDate;
    private double amount;
    private String status;
}
