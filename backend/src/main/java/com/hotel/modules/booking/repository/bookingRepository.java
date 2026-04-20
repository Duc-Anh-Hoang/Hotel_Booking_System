package com.hotel.modules.booking.repository;


import com.hotel.modules.booking.entity.Booking;
import com.hotel.modules.booking.entity.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface bookingRepository extends JpaRepository<Booking, Long> {

    @Query("SELECT b FROM Booking b WHERE b.user.userId = :userId")
    List<Booking> findByUserId(@Param("userId") Long userId);

    List<Booking> findByStatus(BookingStatus status);

    @Query("SELECT b FROM Booking b WHERE b.room.roomId = :roomId")
    List<Booking> findByRoomId(@Param("roomId") Long roomId);


    @Query("""
       SELECT COUNT(b) FROM Booking b
       WHERE b.room.roomId = :roomId
       AND b.status IN :statuses
       AND b.checkInDate < :checkOutDate
       AND b.checkOutDate > :checkInDate
       AND (:excludeBookingId IS NULL OR b.bookingId <> :excludeBookingId)
       """)
    List<Booking> findConflictingBookings(
       @Param("roomId")            Long roomId,
       @Param("checkInDate")       LocalDate checkInDate,
       @Param("checkOutDate")      LocalDate checkOutDate,
       @Param("excludeBookingId")  Long excludeBookingId
    );
}

