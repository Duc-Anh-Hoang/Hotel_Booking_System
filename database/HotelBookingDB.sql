-- ============================================================
--  HOTEL BOOKING MANAGEMENT SYSTEM (HBMS)
--  Database: Microsoft SQL Server
--  Chuẩn: 3NF | Phiên bản: 1.0
--  Tác giả: Nhóm trưởng - Member 1
-- ============================================================

USE master;
GO

-- Tạo database nếu chưa tồn tại
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'HotelBookingDB')
BEGIN
    CREATE DATABASE HotelBookingDB
    COLLATE Vietnamese_CI_AS;
END
GO

USE HotelBookingDB;
GO

-- ============================================================
-- PHẦN 1: XÓA CÁC BẢNG CŨ (NẾU CÓ) - Theo thứ tự phụ thuộc
-- ============================================================
IF OBJECT_ID('dbo.Reviews',          'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.InvoiceItems',     'U') IS NOT NULL DROP TABLE dbo.InvoiceItems;
IF OBJECT_ID('dbo.Invoices',         'U') IS NOT NULL DROP TABLE dbo.Invoices;
IF OBJECT_ID('dbo.Payments',         'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.BookingServices',  'U') IS NOT NULL DROP TABLE dbo.BookingServices;
IF OBJECT_ID('dbo.Bookings',         'U') IS NOT NULL DROP TABLE dbo.Bookings;
IF OBJECT_ID('dbo.RoomAmenityMap',   'U') IS NOT NULL DROP TABLE dbo.RoomAmenityMap;
IF OBJECT_ID('dbo.Amenities',        'U') IS NOT NULL DROP TABLE dbo.Amenities;
IF OBJECT_ID('dbo.Rooms',            'U') IS NOT NULL DROP TABLE dbo.Rooms;
IF OBJECT_ID('dbo.RoomTypes',        'U') IS NOT NULL DROP TABLE dbo.RoomTypes;
IF OBJECT_ID('dbo.ExtraServices',    'U') IS NOT NULL DROP TABLE dbo.ExtraServices;
IF OBJECT_ID('dbo.UserRoles',        'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID('dbo.Roles',            'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID('dbo.Users',            'U') IS NOT NULL DROP TABLE dbo.Users;
GO


-- ============================================================
-- PHẦN 2: TẠO BẢNG
-- ============================================================

-- ----------------------------------------------------------
-- 2.1 BẢNG: Users
-- Mục đích: Lưu thông tin người dùng, hỗ trợ JWT Authentication.
-- Thiết kế: email là unique identifier (dùng làm username đăng nhập).
--           password_hash lưu BCrypt hash, KHÔNG bao giờ lưu plaintext.
--           refresh_token: lưu Refresh Token để renew Access Token (JWT).
--           is_active: soft-delete, không xóa user thật sự khỏi DB.
-- ----------------------------------------------------------
CREATE TABLE Users (
    user_id         BIGINT          NOT NULL IDENTITY(1,1),
    full_name       NVARCHAR(150)   NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NULL,
    password_hash   VARCHAR(255)    NOT NULL,
    refresh_token   VARCHAR(512)    NULL,
    avatar_url      VARCHAR(512)    NULL,
    is_active       BIT             NOT NULL DEFAULT 1,
    created_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Users         PRIMARY KEY (user_id),
    CONSTRAINT UQ_Users_Email   UNIQUE (email),
    CONSTRAINT CK_Users_Email   CHECK (email LIKE '%_@__%.__%')
);
GO

-- ----------------------------------------------------------
-- 2.2 BẢNG: Roles
-- Mục đích: Định nghĩa vai trò (RBAC).
-- Giá trị: ADMIN, STAFF, CUSTOMER
-- ----------------------------------------------------------
CREATE TABLE Roles (
    role_id     INT             NOT NULL IDENTITY(1,1),
    role_name   VARCHAR(50)     NOT NULL,
    description NVARCHAR(255)   NULL,

    CONSTRAINT PK_Roles         PRIMARY KEY (role_id),
    CONSTRAINT UQ_Roles_Name    UNIQUE (role_name)
);
GO

-- ----------------------------------------------------------
-- 2.3 BẢNG: UserRoles (N-N: Users <-> Roles)
-- Mục đích: Một user có thể có nhiều role (ví dụ vừa là STAFF vừa là CUSTOMER).
-- ----------------------------------------------------------
CREATE TABLE UserRoles (
    user_id     BIGINT  NOT NULL,
    role_id     INT     NOT NULL,
    assigned_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_UserRoles         PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_UserRoles_User    FOREIGN KEY (user_id)  REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Role    FOREIGN KEY (role_id)  REFERENCES Roles(role_id) ON DELETE CASCADE
);
GO

-- ----------------------------------------------------------
-- 2.4 BẢNG: RoomTypes
-- Mục đích: Chuẩn hóa loại phòng (3NF), tách khỏi bảng Rooms.
-- Ví dụ: Standard, VIP, Suite, Deluxe
-- ----------------------------------------------------------
CREATE TABLE RoomTypes (
    type_id         INT             NOT NULL IDENTITY(1,1),
    type_name       NVARCHAR(100)   NOT NULL,
    description     NVARCHAR(500)   NULL,
    base_price      DECIMAL(18,2)   NOT NULL,   -- Giá gốc theo đêm (VND)
    max_occupancy   TINYINT         NOT NULL DEFAULT 2,

    CONSTRAINT PK_RoomTypes         PRIMARY KEY (type_id),
    CONSTRAINT UQ_RoomTypes_Name    UNIQUE (type_name),
    CONSTRAINT CK_RoomTypes_Price   CHECK (base_price > 0),
    CONSTRAINT CK_RoomTypes_Cap     CHECK (max_occupancy BETWEEN 1 AND 10)
);
GO

-- ----------------------------------------------------------
-- 2.5 BẢNG: Rooms
-- Mục đích: Thông tin chi tiết từng phòng.
-- Thiết kế địa chỉ: Tách thành province/district/address (hỗ trợ filter theo tỉnh/thành).
-- bed_type: SINGLE | DOUBLE | TRIPLE | KING | QUEEN
-- status: AVAILABLE | OCCUPIED | MAINTENANCE | INACTIVE
-- ----------------------------------------------------------
CREATE TABLE Rooms (
    room_id         BIGINT          NOT NULL IDENTITY(1,1),
    type_id         INT             NOT NULL,
    room_number     VARCHAR(20)     NOT NULL,
    floor           SMALLINT        NULL,
    bed_type        VARCHAR(20)     NOT NULL DEFAULT 'DOUBLE',
    -- Địa chỉ - Hỗ trợ filter theo tỉnh/thành phố, quận/huyện
    province        NVARCHAR(100)   NOT NULL,   -- Tỉnh/Thành phố (TP. Hồ Chí Minh, Hà Nội...)
    district        NVARCHAR(100)   NOT NULL,   -- Quận/Huyện
    address         NVARCHAR(500)   NULL,        -- Địa chỉ chi tiết (số nhà, đường)
    -- Thông tin giá (override base_price của RoomType nếu cần)
    price_per_night DECIMAL(18,2)   NOT NULL,
    -- Hình ảnh (lưu JSON array URL hoặc URL ảnh chính)
    thumbnail_url   VARCHAR(512)    NULL,
    image_urls      NVARCHAR(MAX)   NULL,        -- Lưu dạng JSON: ["url1","url2",...]
    -- Mô tả & trạng thái
    description     NVARCHAR(MAX)   NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'AVAILABLE',
    created_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Rooms             PRIMARY KEY (room_id),
    CONSTRAINT FK_Rooms_Type        FOREIGN KEY (type_id)  REFERENCES RoomTypes(type_id),
    CONSTRAINT UQ_Rooms_Number      UNIQUE (room_number),
    CONSTRAINT CK_Rooms_Price       CHECK (price_per_night > 0),
    CONSTRAINT CK_Rooms_BedType     CHECK (bed_type IN ('SINGLE','DOUBLE','TRIPLE','KING','QUEEN')),
    CONSTRAINT CK_Rooms_Status      CHECK (status   IN ('AVAILABLE','OCCUPIED','MAINTENANCE','INACTIVE'))
);
GO

-- ----------------------------------------------------------
-- 2.6 BẢNG: Amenities (Tiện nghi/Tiện ích)
-- Mục đích: Danh sách tiện ích (Hồ bơi, Gym, Spa, WiFi, Nhà hàng...)
-- Tách thành bảng riêng để dễ mở rộng (3NF).
-- ----------------------------------------------------------
CREATE TABLE Amenities (
    amenity_id      INT             NOT NULL IDENTITY(1,1),
    amenity_name    NVARCHAR(100)   NOT NULL,
    icon_class      VARCHAR(100)    NULL,   -- CSS icon class (FontAwesome/Material)
    description     NVARCHAR(255)   NULL,

    CONSTRAINT PK_Amenities         PRIMARY KEY (amenity_id),
    CONSTRAINT UQ_Amenities_Name    UNIQUE (amenity_name)
);
GO

-- ----------------------------------------------------------
-- 2.7 BẢNG: RoomAmenityMap (N-N: Rooms <-> Amenities)
-- Mục đích: Phòng nào có tiện ích nào.
-- Dùng để filter: "Tìm phòng có Hồ bơi VÀ Gym".
-- ----------------------------------------------------------
CREATE TABLE RoomAmenityMap (
    room_id     BIGINT  NOT NULL,
    amenity_id  INT     NOT NULL,

    CONSTRAINT PK_RoomAmenityMap        PRIMARY KEY (room_id, amenity_id),
    CONSTRAINT FK_RAM_Room              FOREIGN KEY (room_id)    REFERENCES Rooms(room_id)     ON DELETE CASCADE,
    CONSTRAINT FK_RAM_Amenity           FOREIGN KEY (amenity_id) REFERENCES Amenities(amenity_id) ON DELETE CASCADE
);
GO

-- ----------------------------------------------------------
-- 2.8 BẢNG: ExtraServices (Dịch vụ đi kèm khi đặt phòng)
-- Mục đích: Dịch vụ khách hàng có thể thêm vào booking.
-- Ví dụ: Đưa đón sân bay, Bữa sáng, Cho thuê xe...
-- price_type: PER_BOOKING (tính 1 lần) | PER_NIGHT (tính theo đêm) | PER_PERSON
-- ----------------------------------------------------------
CREATE TABLE ExtraServices (
    service_id      INT             NOT NULL IDENTITY(1,1),
    service_name    NVARCHAR(150)   NOT NULL,
    description     NVARCHAR(500)   NULL,
    unit_price      DECIMAL(18,2)   NOT NULL,
    price_type      VARCHAR(20)     NOT NULL DEFAULT 'PER_BOOKING',
    is_active       BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_ExtraServices         PRIMARY KEY (service_id),
    CONSTRAINT CK_Services_Price        CHECK (unit_price >= 0),
    CONSTRAINT CK_Services_PriceType    CHECK (price_type IN ('PER_BOOKING','PER_NIGHT','PER_PERSON'))
);
GO

-- ----------------------------------------------------------
-- 2.9 BẢNG: Bookings ⭐ (BẢNG TRUNG TÂM)
-- Mục đích: Lưu toàn bộ thông tin đặt phòng.
-- LOGIC CHỐNG OVERBOOKING:
--   - Mỗi booking có status: PENDING | CONFIRMED | CHECKED_IN | CHECKED_OUT | CANCELLED
--   - Chỉ các booking có status IN ('PENDING','CONFIRMED','CHECKED_IN')
--     mới được tính là "đang chiếm phòng".
--   - expires_at: Thời điểm hết hạn PENDING (15 phút sau khi tạo).
--     Nếu quá hạn mà chưa thanh toán => tự động CANCELLED (xử lý bởi Scheduler).
--
-- VERSION (Optimistic Locking): Spring JPA tự động tăng khi update.
--   Nếu 2 transaction cùng đọc version=1 và cùng update => 1 cái sẽ fail (OptimisticLockException).
-- ----------------------------------------------------------
CREATE TABLE Bookings (
    booking_id      BIGINT          NOT NULL IDENTITY(1,1),
    user_id         BIGINT          NOT NULL,
    room_id         BIGINT          NOT NULL,
    -- Thời gian
    check_in_date   DATE            NOT NULL,
    check_out_date  DATE            NOT NULL,
    actual_checkin  DATETIME2       NULL,   -- Giờ thực tế check-in (STAFF cập nhật)
    actual_checkout DATETIME2       NULL,   -- Giờ thực tế check-out
    -- Khách
    num_guests      TINYINT         NOT NULL DEFAULT 1,
    special_request NVARCHAR(500)   NULL,
    -- Tài chính (snapshot tại thời điểm đặt, tránh ảnh hưởng khi giá thay đổi)
    room_price_snapshot DECIMAL(18,2) NOT NULL,  -- Giá phòng/đêm tại lúc đặt
    total_nights    SMALLINT        NOT NULL,
    -- Trạng thái & kiểm soát
    status          VARCHAR(20)     NOT NULL DEFAULT 'PENDING',
    expires_at      DATETIME2       NULL,   -- Hết hạn PENDING (= created_at + 15 phút)
    booking_code    VARCHAR(20)     NOT NULL,   -- Mã đặt phòng (VD: HB20240615-0001)
    -- Optimistic Locking
    version         INT             NOT NULL DEFAULT 0,
    created_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Bookings              PRIMARY KEY (booking_id),
    CONSTRAINT FK_Bookings_User         FOREIGN KEY (user_id)  REFERENCES Users(user_id),
    CONSTRAINT FK_Bookings_Room         FOREIGN KEY (room_id)  REFERENCES Rooms(room_id),
    CONSTRAINT UQ_Bookings_Code         UNIQUE (booking_code),
    CONSTRAINT CK_Bookings_Dates        CHECK (check_out_date > check_in_date),
    CONSTRAINT CK_Bookings_Guests       CHECK (num_guests >= 1),
    CONSTRAINT CK_Bookings_Nights       CHECK (total_nights >= 1),
    CONSTRAINT CK_Bookings_Status       CHECK (status IN (
        'PENDING','CONFIRMED','CHECKED_IN','CHECKED_OUT','CANCELLED','REFUNDED'
    ))
);
GO

-- Index hỗ trợ truy vấn chống Overbooking (thường xuyên được gọi)
CREATE NONCLUSTERED INDEX IX_Bookings_Room_Status_Dates
    ON Bookings (room_id, status, check_in_date, check_out_date);
GO

-- Index hỗ trợ lọc booking của 1 user
CREATE NONCLUSTERED INDEX IX_Bookings_User
    ON Bookings (user_id, status);
GO

-- Index hỗ trợ Scheduler tìm PENDING booking hết hạn
CREATE NONCLUSTERED INDEX IX_Bookings_Expires
    ON Bookings (expires_at, status)
    WHERE status = 'PENDING';
GO

-- ----------------------------------------------------------
-- 2.10 BẢNG: BookingServices (N-N: Bookings <-> ExtraServices)
-- Mục đích: Dịch vụ đi kèm cho từng booking.
-- quantity: Số lượng (ví dụ: 2 bữa sáng).
-- subtotal: Giá tại thời điểm đặt (snapshot).
-- ----------------------------------------------------------
CREATE TABLE BookingServices (
    booking_id      BIGINT          NOT NULL,
    service_id      INT             NOT NULL,
    quantity        SMALLINT        NOT NULL DEFAULT 1,
    unit_price_snap DECIMAL(18,2)   NOT NULL,   -- Snapshot giá dịch vụ lúc đặt
    subtotal        AS (quantity * unit_price_snap) PERSISTED, -- Computed Column

    CONSTRAINT PK_BookingServices       PRIMARY KEY (booking_id, service_id),
    CONSTRAINT FK_BS_Booking            FOREIGN KEY (booking_id)  REFERENCES Bookings(booking_id)     ON DELETE CASCADE,
    CONSTRAINT FK_BS_Service            FOREIGN KEY (service_id)  REFERENCES ExtraServices(service_id),
    CONSTRAINT CK_BS_Quantity           CHECK (quantity >= 1)
);
GO

-- ----------------------------------------------------------
-- 2.11 BẢNG: Payments
-- Mục đích: Lưu thông tin giao dịch thanh toán.
-- transaction_id: ID giao dịch từ MoMo/VNPAY (lưu để đối soát).
-- gateway: MOMO | VNPAY | ZALOPAY | CASH | TRANSFER
-- status: PENDING | SUCCESS | FAILED | REFUNDED
-- raw_response: Lưu toàn bộ JSON response từ cổng thanh toán (để debug/audit).
-- ----------------------------------------------------------
CREATE TABLE Payments (
    payment_id      BIGINT          NOT NULL IDENTITY(1,1),
    booking_id      BIGINT          NOT NULL,
    gateway         VARCHAR(20)     NOT NULL,
    transaction_id  VARCHAR(255)    NULL,   -- TxnRef/OrderId từ MoMo, VNPAY
    amount          DECIMAL(18,2)   NOT NULL,
    currency        VARCHAR(10)     NOT NULL DEFAULT 'VND',
    status          VARCHAR(20)     NOT NULL DEFAULT 'PENDING',
    paid_at         DATETIME2       NULL,   -- Thời điểm thanh toán thành công
    raw_response    NVARCHAR(MAX)   NULL,   -- JSON response từ gateway (audit log)
    ip_address      VARCHAR(50)     NULL,   -- IP của khách lúc thanh toán
    created_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Payments              PRIMARY KEY (payment_id),
    CONSTRAINT FK_Payments_Booking      FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CONSTRAINT UQ_Payments_TxnId        UNIQUE (transaction_id),
    CONSTRAINT CK_Payments_Amount       CHECK (amount > 0),
    CONSTRAINT CK_Payments_Gateway      CHECK (gateway IN ('MOMO','VNPAY','ZALOPAY','CASH','TRANSFER')),
    CONSTRAINT CK_Payments_Status       CHECK (status  IN ('PENDING','SUCCESS','FAILED','REFUNDED'))
);
GO

-- ----------------------------------------------------------
-- 2.12 BẢNG: Invoices (Hóa đơn)
-- Mục đích: Hóa đơn phát sinh sau khi thanh toán thành công.
-- tax_rate: VAT (thường 10%).
-- pdf_url: Đường dẫn file PDF đã xuất (lưu trên server hoặc S3).
-- ----------------------------------------------------------
CREATE TABLE Invoices (
    invoice_id      BIGINT          NOT NULL IDENTITY(1,1),
    booking_id      BIGINT          NOT NULL,
    payment_id      BIGINT          NOT NULL,
    invoice_number  VARCHAR(30)     NOT NULL,   -- VD: INV-20240615-00001
    subtotal        DECIMAL(18,2)   NOT NULL,   -- Tổng trước thuế (phòng + dịch vụ)
    tax_rate        DECIMAL(5,2)    NOT NULL DEFAULT 10.00,  -- VAT 10%
    tax_amount      DECIMAL(18,2)   NOT NULL,
    discount_amount DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total_amount    DECIMAL(18,2)   NOT NULL,   -- = subtotal + tax_amount - discount
    pdf_url         VARCHAR(512)    NULL,
    issued_at       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    notes           NVARCHAR(500)   NULL,

    CONSTRAINT PK_Invoices              PRIMARY KEY (invoice_id),
    CONSTRAINT FK_Invoices_Booking      FOREIGN KEY (booking_id)  REFERENCES Bookings(booking_id),
    CONSTRAINT FK_Invoices_Payment      FOREIGN KEY (payment_id)  REFERENCES Payments(payment_id),
    CONSTRAINT UQ_Invoices_Number       UNIQUE (invoice_number),
    CONSTRAINT UQ_Invoices_Booking      UNIQUE (booking_id),     -- 1 booking chỉ có 1 invoice
    CONSTRAINT CK_Invoices_Total        CHECK (total_amount >= 0)
);
GO

-- ----------------------------------------------------------
-- 2.13 BẢNG: InvoiceItems (Chi tiết dòng hóa đơn)
-- Mục đích: Liệt kê từng mục trong hóa đơn (phòng, từng dịch vụ).
-- item_type: ROOM | SERVICE
-- ----------------------------------------------------------
CREATE TABLE InvoiceItems (
    item_id         BIGINT          NOT NULL IDENTITY(1,1),
    invoice_id      BIGINT          NOT NULL,
    item_type       VARCHAR(20)     NOT NULL,
    description     NVARCHAR(255)   NOT NULL,   -- "Phòng 101 - 3 đêm", "Bữa sáng x2"
    quantity        SMALLINT        NOT NULL DEFAULT 1,
    unit_price      DECIMAL(18,2)   NOT NULL,
    line_total      AS (quantity * unit_price) PERSISTED,

    CONSTRAINT PK_InvoiceItems          PRIMARY KEY (item_id),
    CONSTRAINT FK_InvoiceItems_Invoice  FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id) ON DELETE CASCADE,
    CONSTRAINT CK_InvoiceItems_Type     CHECK (item_type IN ('ROOM','SERVICE','DISCOUNT','TAX'))
);
GO

-- ----------------------------------------------------------
-- 2.14 BẢNG: Reviews (Đánh giá - Điểm sáng tạo)
-- Mục đích: Khách hàng đánh giá sau khi check-out.
-- Ràng buộc: Chỉ được review sau khi booking.status = 'CHECKED_OUT'.
-- is_approved: Admin duyệt trước khi hiển thị công khai.
-- ----------------------------------------------------------
CREATE TABLE Reviews (
    review_id       BIGINT          NOT NULL IDENTITY(1,1),
    booking_id      BIGINT          NOT NULL,
    user_id         BIGINT          NOT NULL,
    room_id         BIGINT          NOT NULL,
    -- Đánh giá chi tiết theo từng tiêu chí
    rating_overall  TINYINT         NOT NULL,   -- 1-5 sao tổng thể
    rating_clean    TINYINT         NULL,        -- Vệ sinh
    rating_service  TINYINT         NULL,        -- Dịch vụ
    rating_location TINYINT         NULL,        -- Vị trí
    rating_value    TINYINT         NULL,        -- Giá trị/tiền
    comment         NVARCHAR(MAX)   NULL,
    is_approved     BIT             NOT NULL DEFAULT 0,
    admin_reply     NVARCHAR(MAX)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Reviews               PRIMARY KEY (review_id),
    CONSTRAINT FK_Reviews_Booking       FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CONSTRAINT FK_Reviews_User          FOREIGN KEY (user_id)    REFERENCES Users(user_id),
    CONSTRAINT FK_Reviews_Room          FOREIGN KEY (room_id)    REFERENCES Rooms(room_id),
    CONSTRAINT UQ_Reviews_Booking       UNIQUE (booking_id),  -- 1 booking chỉ review 1 lần
    CONSTRAINT CK_Reviews_Rating        CHECK (rating_overall BETWEEN 1 AND 5),
    CONSTRAINT CK_Reviews_Clean         CHECK (rating_clean    IS NULL OR rating_clean    BETWEEN 1 AND 5),
    CONSTRAINT CK_Reviews_Service       CHECK (rating_service  IS NULL OR rating_service  BETWEEN 1 AND 5),
    CONSTRAINT CK_Reviews_Location      CHECK (rating_location IS NULL OR rating_location BETWEEN 1 AND 5),
    CONSTRAINT CK_Reviews_Value         CHECK (rating_value    IS NULL OR rating_value    BETWEEN 1 AND 5)
);
GO
-- ----------------------------------------------------------
-- 2.15 BẢNG: Conversations (Phiên hội thoại)
-- Kết nối: Users (1-N)
-- ----------------------------------------------------------
CREATE TABLE Conversations (
    conversation_id  BIGINT        NOT NULL IDENTITY(1,1),
    user_id          BIGINT        NULL,      -- Khách đã login (FK từ bảng Users)
    session_id       VARCHAR(100)  NOT NULL,  -- UUID cho khách vãng lai/vừa vào web
    title            NVARCHAR(255) NULL,      -- VD: "Hỏi về phòng Penthouse"
    status           VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    created_at       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    updated_at       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Conversations        PRIMARY KEY (conversation_id),
    -- Khớp với bảng Users của ông
    CONSTRAINT FK_Conv_Users           FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    CONSTRAINT CK_Conv_Status          CHECK (status IN ('ACTIVE','CLOSED'))
);
GO

-- ----------------------------------------------------------
-- 2.16 BẢNG: ChatMessages (Chi tiết tin nhắn)
-- Kết nối: Conversations, Rooms, Bookings
-- ----------------------------------------------------------
CREATE TABLE ChatMessages (
    message_id       BIGINT         NOT NULL IDENTITY(1,1),
    conversation_id  BIGINT         NOT NULL,
    role             VARCHAR(20)    NOT NULL, -- 'user' | 'assistant' | 'system'
    content          NVARCHAR(MAX)  NOT NULL,
    
    -- Liên kết nghiệp vụ (AI có thể nhắc đến phòng hoặc booking cụ thể)
    ref_room_id      BIGINT         NULL, -- Liên kết đến bảng Rooms
    ref_booking_id   BIGINT         NULL, -- Liên kết đến bảng Bookings
    
    tokens_used      INT            NULL, -- Theo dõi chi phí OpenAI
    created_at       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_ChatMessages         PRIMARY KEY (message_id),
    CONSTRAINT FK_CM_Conversation      FOREIGN KEY (conversation_id) REFERENCES Conversations(conversation_id) ON DELETE CASCADE,
    -- Khớp với bảng Rooms và Bookings của ông
    CONSTRAINT FK_CM_Rooms             FOREIGN KEY (ref_room_id)    REFERENCES Rooms(room_id) ON DELETE SET NULL,
    CONSTRAINT FK_CM_Bookings          FOREIGN KEY (ref_booking_id) REFERENCES Bookings(booking_id) ON DELETE SET NULL,
    CONSTRAINT CK_CM_Role              CHECK (role IN ('user','assistant','system'))
);
GO
CREATE NONCLUSTERED INDEX IX_ChatMessages_Conv_Date
ON ChatMessages (conversation_id, created_at);
GO 


-- ============================================================
-- PHẦN 3: STORED PROCEDURES & VIEWS QUAN TRỌNG
-- ============================================================

-- ----------------------------------------------------------
-- VIEW: vw_RoomAvailabilitySummary
-- Mục đích: Xem nhanh phòng nào đang được đặt (không cần query phức tạp mỗi lần).
-- ----------------------------------------------------------
CREATE OR ALTER VIEW vw_ActiveBookingsPerRoom AS
    SELECT
        r.room_id,
        r.room_number,
        r.province,
        r.status AS room_status,
        b.booking_id,
        b.check_in_date,
        b.check_out_date,
        b.status AS booking_status,
        b.expires_at
    FROM Rooms r
    LEFT JOIN Bookings b ON b.room_id = r.room_id
        AND b.status IN ('PENDING', 'CONFIRMED', 'CHECKED_IN')
GO

-- ----------------------------------------------------------
-- SP: sp_CheckRoomAvailability
-- Mục đích: Kiểm tra phòng có trống trong khoảng thời gian không.
--           Trả về 1 nếu trống, 0 nếu đã được đặt.
-- Tham số:
--   @room_id       : ID phòng cần kiểm tra
--   @check_in      : Ngày check-in
--   @check_out     : Ngày check-out
--   @exclude_booking: ID booking cần loại trừ (dùng khi chỉnh sửa booking hiện tại)
-- ----------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_CheckRoomAvailability
    @room_id            BIGINT,
    @check_in           DATE,
    @check_out          DATE,
    @exclude_booking_id BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Logic kiểm tra xung đột thời gian (Overlap Detection):
    -- Booking B xung đột với [check_in, check_out) nếu:
    --   B.check_in_date  < @check_out   (B bắt đầu trước khi mình kết thúc)
    --   B.check_out_date > @check_in    (B kết thúc sau khi mình bắt đầu)
    -- => Phủ định: KHÔNG xung đột khi B.check_out <= @check_in OR B.check_in >= @check_out

    DECLARE @conflict_count INT;

    SELECT @conflict_count = COUNT(*)
    FROM   Bookings
    WHERE  room_id          = @room_id
      AND  status           IN ('PENDING', 'CONFIRMED', 'CHECKED_IN')
      AND  check_in_date    <  @check_out   -- Booking cũ bắt đầu trước khi mình kết thúc
      AND  check_out_date   >  @check_in    -- Booking cũ kết thúc sau khi mình bắt đầu
      AND  (@exclude_booking_id IS NULL OR booking_id <> @exclude_booking_id);

    -- Trả kết quả: 1 = Available, 0 = Not Available
    SELECT
        CASE WHEN @conflict_count = 0 THEN 1 ELSE 0 END AS is_available,
        @conflict_count AS conflict_count;
END
GO

-- ----------------------------------------------------------
-- SP: sp_CancelExpiredPendingBookings
-- Mục đích: Chạy bởi Spring @Scheduled (mỗi 1 phút).
--           Tự động CANCEL các booking PENDING đã hết hạn.
-- ----------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_CancelExpiredPendingBookings
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Bookings
    SET    status     = 'CANCELLED',
           updated_at = SYSDATETIME()
    WHERE  status     = 'PENDING'
      AND  expires_at < SYSDATETIME();

    SELECT @@ROWCOUNT AS cancelled_count;
END
GO


-- ============================================================
-- PHẦN 4: SEED DATA (Dữ liệu mẫu)
-- ============================================================

-- 4.1 Roles
INSERT INTO Roles (role_name, description) VALUES
    ('ADMIN',    N'Quản trị viên hệ thống, toàn quyền'),
    ('STAFF',    N'Nhân viên lễ tân, quản lý booking'),
    ('CUSTOMER', N'Khách hàng đặt phòng thông thường');

-- 4.2 Users (password = BCrypt của "Admin@123")
INSERT INTO Users (full_name, email, phone, password_hash, is_active) VALUES
    (N'Nguyễn Văn Admin', 'admin@hbms.vn', '0901000001',
     '$2a$12$K7GoZ/D5Q4J3R.xB7pHrYuvbvAfPIGBiE7Nwl3TygTsKJn4OZ4Wfe', 1),
    (N'Trần Thị Staff',   'staff@hbms.vn', '0901000002',
     '$2a$12$K7GoZ/D5Q4J3R.xB7pHrYuvbvAfPIGBiE7Nwl3TygTsKJn4OZ4Wfe', 1),
    (N'Lê Văn Khách',     'customer1@gmail.com', '0901000003',
     '$2a$12$K7GoZ/D5Q4J3R.xB7pHrYuvbvAfPIGBiE7Nwl3TygTsKJn4OZ4Wfe', 1),
    (N'Phạm Thị Hoa',     'customer2@gmail.com', '0901000004',
     '$2a$12$K7GoZ/D5Q4J3R.xB7pHrYuvbvAfPIGBiE7Nwl3TygTsKJn4OZ4Wfe', 1),
    (N'Hoàng Minh Tuấn',  'customer3@gmail.com', '0901000005',
     '$2a$12$K7GoZ/D5Q4J3R.xB7pHrYuvbvAfPIGBiE7Nwl3TygTsKJn4OZ4Wfe', 1);

-- 4.3 Gán quyền
INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id FROM Users u, Roles r
WHERE (u.email = 'admin@hbms.vn'    AND r.role_name = 'ADMIN')
   OR (u.email = 'staff@hbms.vn'    AND r.role_name = 'STAFF')
   OR (u.email = 'customer1@gmail.com' AND r.role_name = 'CUSTOMER')
   OR (u.email = 'customer2@gmail.com' AND r.role_name = 'CUSTOMER')
   OR (u.email = 'customer3@gmail.com' AND r.role_name = 'CUSTOMER');

-- 4.4 RoomTypes
INSERT INTO RoomTypes (type_name, description, base_price, max_occupancy) VALUES
    (N'Standard',  N'Phòng tiêu chuẩn, đầy đủ tiện nghi cơ bản',          500000,  2),
    (N'Deluxe',    N'Phòng cao cấp, view đẹp, nội thất sang trọng',         900000,  2),
    (N'VIP Suite', N'Suite hạng VIP, phòng khách riêng, bồn tắm jacuzzi',  2500000, 4),
    (N'Family',    N'Phòng gia đình rộng rãi, thích hợp 3-4 người',        1200000, 4),
    (N'Penthouse', N'Tầng thượng, view toàn thành phố, dịch vụ butler',    5000000, 2);

-- 4.5 Amenities
INSERT INTO Amenities (amenity_name, icon_class, description) VALUES
    (N'Hồ bơi',         'fa-swimming-pool',    N'Hồ bơi ngoài trời/trong nhà'),
    (N'Gym & Fitness',  'fa-dumbbell',         N'Phòng tập gym 24/7'),
    (N'Spa & Massage',  'fa-spa',              N'Dịch vụ spa và massage thư giãn'),
    (N'Nhà hàng',       'fa-utensils',         N'Nhà hàng phục vụ đa dạng món ăn'),
    (N'WiFi miễn phí',  'fa-wifi',             N'Kết nối WiFi tốc độ cao toàn khu vực'),
    (N'Bãi đỗ xe',      'fa-parking',          N'Bãi đỗ xe có bảo vệ 24/7'),
    (N'Khu vui chơi',   'fa-child',            N'Khu vui chơi trẻ em'),
    (N'Phòng họp',      'fa-chalkboard',       N'Phòng hội nghị/hội thảo'),
    (N'Bar & Lounge',   'fa-cocktail',         N'Quầy bar và khu lounge'),
    (N'Đưa đón sân bay','fa-shuttle-van',      N'Dịch vụ đưa đón sân bay');

-- 4.6 Rooms (5 phòng mẫu tại các tỉnh khác nhau)
INSERT INTO Rooms (type_id, room_number, floor, bed_type, province, district, address,
                   price_per_night, thumbnail_url, description, status)
VALUES
    -- Phòng 1: Standard - HCM
    (1, '101', 1, 'DOUBLE',
     N'TP. Hồ Chí Minh', N'Quận 1', N'15 Nguyễn Huệ, Phường Bến Nghé',
     550000,
     'https://cdn.hbms.vn/rooms/101-thumb.jpg',
     N'Phòng standard thoáng mát, nhìn ra phố đi bộ Nguyễn Huệ sầm uất.',
     'AVAILABLE'),

    -- Phòng 2: Deluxe - HCM
    (2, '205', 2, 'KING',
     N'TP. Hồ Chí Minh', N'Quận 1', N'15 Nguyễn Huệ, Phường Bến Nghé',
     950000,
     'https://cdn.hbms.vn/rooms/205-thumb.jpg',
     N'Phòng deluxe view sông Sài Gòn, giường King size, bồn tắm đứng.',
     'AVAILABLE'),

    -- Phòng 3: VIP Suite - Đà Nẵng
    (3, '301', 3, 'KING',
     N'Đà Nẵng', N'Quận Sơn Trà', N'168 Võ Nguyên Giáp, Phước Mỹ',
     2600000,
     'https://cdn.hbms.vn/rooms/301-thumb.jpg',
     N'Suite VIP hướng biển Mỹ Khê, phòng khách riêng và bồn tắm jacuzzi.',
     'AVAILABLE'),

    -- Phòng 4: Family - Hà Nội
    (4, '402', 4, 'TRIPLE',
     N'Hà Nội', N'Quận Hoàn Kiếm', N'9 Đinh Tiên Hoàng, Phường Hàng Trống',
     1300000,
     'https://cdn.hbms.vn/rooms/402-thumb.jpg',
     N'Phòng gia đình view hồ Hoàn Kiếm, 2 phòng ngủ, bếp nhỏ tiện lợi.',
     'AVAILABLE'),

    -- Phòng 5: Penthouse - Phú Quốc
    (5, 'PH01', 10, 'KING',
     N'Kiên Giang', N'Huyện Phú Quốc', N'18 Trần Hưng Đạo, Dương Đông',
     5200000,
     'https://cdn.hbms.vn/rooms/ph01-thumb.jpg',
     N'Penthouse tầng thượng view 360° biển đảo Phú Quốc, butler service.',
     'AVAILABLE');

-- 4.7 Gán tiện ích cho phòng
-- Room 101 (Standard): WiFi, Bãi đỗ xe, Nhà hàng
INSERT INTO RoomAmenityMap (room_id, amenity_id) VALUES (1,5),(1,6),(1,4);
-- Room 205 (Deluxe): WiFi, Hồ bơi, Nhà hàng, Bar
INSERT INTO RoomAmenityMap (room_id, amenity_id) VALUES (2,5),(2,1),(2,4),(2,9);
-- Room 301 (VIP Suite): Tất cả tiện ích
INSERT INTO RoomAmenityMap (room_id, amenity_id) VALUES (3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,9),(3,10);
-- Room 402 (Family): WiFi, Khu vui chơi, Bãi đỗ xe, Nhà hàng
INSERT INTO RoomAmenityMap (room_id, amenity_id) VALUES (4,5),(4,7),(4,6),(4,4);
-- Room PH01 (Penthouse): Tất cả tiện ích
INSERT INTO RoomAmenityMap (room_id, amenity_id) VALUES (5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,8),(5,9),(5,10);

-- 4.8 ExtraServices (3 loại dịch vụ mẫu)
INSERT INTO ExtraServices (service_name, description, unit_price, price_type, is_active) VALUES
    (N'Bữa sáng Buffet',    N'Bữa sáng buffet quốc tế dành cho 1 người',       150000, 'PER_PERSON',  1),
    (N'Đưa đón sân bay',    N'Xe đưa đón sân bay gần nhất (1 chiều)',           350000, 'PER_BOOKING', 1),
    (N'Thuê xe máy',        N'Thuê xe máy khám phá thành phố (50cc)',           120000, 'PER_NIGHT',   1),
    (N'Dọn phòng buổi tối', N'Dịch vụ dọn phòng + trải giường buổi tối',        80000, 'PER_NIGHT',   1),
    (N'Thuê xe đạp',        N'Thuê xe đạp tham quan (bao gồm mũ bảo hiểm)',     50000, 'PER_NIGHT',   1);

-- 4.9 Booking mẫu (1 booking đã CONFIRMED, 1 đang PENDING)
-- Booking 1: Lê Văn Khách đặt phòng 205 (đã CONFIRMED)
INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, num_guests,
                      room_price_snapshot, total_nights, status, expires_at, booking_code)
VALUES (3, 2, '2025-08-01', '2025-08-04', 2, 950000, 3, 'CONFIRMED', NULL, 'HB20250801-0001');

-- Booking 2: Phạm Thị Hoa đặt phòng 301 (đang PENDING, còn 15 phút)
INSERT INTO Bookings (user_id, room_id, check_in_date, check_out_date, num_guests,
                      room_price_snapshot, total_nights, status, expires_at, booking_code)
VALUES (4, 3, '2025-08-10', '2025-08-12', 2, 2600000, 2, 'PENDING',
        DATEADD(MINUTE, 15, SYSDATETIME()), 'HB20250810-0002');

-- Dịch vụ đi kèm booking 1
INSERT INTO BookingServices (booking_id, service_id, quantity, unit_price_snap)
VALUES (1, 1, 2, 150000),   -- 2 x Bữa sáng Buffet
       (1, 2, 1, 350000);   -- 1 x Đưa đón sân bay

-- 4.10 Payment cho booking 1
INSERT INTO Payments (booking_id, gateway, transaction_id, amount, status, paid_at)
VALUES (1, 'VNPAY', 'VNP20250801123456', 3150000, 'SUCCESS', '2025-08-01 09:30:00');
-- Tính: 950000 x 3 đêm + 2x150000 + 350000 = 3,500,000
-- (seed data đơn giản, chưa tính thuế)

-- 4.11 Invoice cho booking 1
INSERT INTO Invoices (booking_id, payment_id, invoice_number, subtotal, tax_rate, tax_amount, discount_amount, total_amount)
VALUES (1, 1, 'INV-20250801-00001', 3150000, 10.00, 315000, 0, 3465000);

INSERT INTO InvoiceItems (invoice_id, item_type, description, quantity, unit_price)
VALUES
    (1, 'ROOM',    N'Phòng 205 (Deluxe) - 3 đêm',     3, 950000),
    (1, 'SERVICE', N'Bữa sáng Buffet x2 người',        2, 150000),
    (1, 'SERVICE', N'Đưa đón sân bay (1 chiều)',        1, 350000),
    (1, 'TAX',     N'VAT 10%',                          1, 315000);

-- 4.12 Review mẫu
INSERT INTO Reviews (booking_id, user_id, room_id, rating_overall, rating_clean,
                     rating_service, rating_location, rating_value, comment, is_approved)
VALUES (1, 3, 2, 5, 5, 4, 5, 4,
        N'Phòng rất đẹp, view sông Sài Gòn tuyệt vời! Nhân viên nhiệt tình và chuyên nghiệp. Sẽ quay lại!',
        1);
GO


-- ============================================================
-- PHẦN 5: QUERY CHỐNG OVERBOOKING (Tài liệu kỹ thuật)
-- ============================================================

/*
=================================================================
[A] SQL QUERY: Kiểm tra phòng trống theo khoảng thời gian
=================================================================
-- Đây là câu query cốt lõi để tránh Overbooking.
-- Sử dụng trong Service Layer trước khi INSERT booking mới.
-- Logic: Tìm xem có booking nào "xung đột" với khoảng [check_in, check_out) không.
-- Hai khoảng thời gian [A,B) và [C,D) xung đột khi: A < D AND B > C

-- Phiên bản SQL thuần:
SELECT COUNT(*) AS conflict_count
FROM   Bookings
WHERE  room_id          = :roomId
  AND  status           IN ('PENDING', 'CONFIRMED', 'CHECKED_IN')
  AND  check_in_date    <  :checkOutDate
  AND  check_out_date   >  :checkInDate;
-- Nếu conflict_count = 0 => Phòng trống, được phép đặt.


-- Phiên bản JPQL (dùng trong Spring Data JPA Repository):
--
-- @Query("""
--     SELECT COUNT(b) FROM Booking b
--     WHERE  b.room.roomId         = :roomId
--       AND  b.status              IN ('PENDING','CONFIRMED','CHECKED_IN')
--       AND  b.checkInDate         < :checkOutDate
--       AND  b.checkOutDate        > :checkInDate
--       AND  (:excludeBookingId IS NULL OR b.bookingId <> :excludeBookingId)
-- """)
-- long countConflictingBookings(
--     @Param("roomId")            Long roomId,
--     @Param("checkInDate")       LocalDate checkInDate,
--     @Param("checkOutDate")      LocalDate checkOutDate,
--     @Param("excludeBookingId")  Long excludeBookingId
-- );


=================================================================
[B] XỬ LÝ CONCURRENCY - Locking Strategy
=================================================================

-----------------------------
[B1] PESSIMISTIC LOCKING (Khóa bi quan - Khuyến nghị cho Production)
-----------------------------
-- Cơ chế: Khóa dòng Room ngay khi SELECT, không cho phép session khác đọc/ghi
--         cho đến khi transaction hiện tại COMMIT hoặc ROLLBACK.
-- Phù hợp: Tần suất tranh chấp CAO (nhiều user đặt phòng cùng lúc).
-- Nhược điểm: Giảm throughput, có thể gây deadlock nếu không cẩn thận.
--
-- Triển khai trong Spring JPA:
--
-- // Trong RoomRepository.java
-- @Lock(LockModeType.PESSIMISTIC_WRITE)  // => SELECT ... WITH (UPDLOCK, ROWLOCK) trên SQL Server
-- @Query("SELECT r FROM Room r WHERE r.roomId = :roomId")
-- Optional<Room> findByIdWithLock(@Param("roomId") Long roomId);
--
-- // Trong BookingService.java
-- @Transactional
-- public Booking createBooking(BookingRequest request) {
--     // 1. Lock dòng room - Các thread khác phải CHỜ tại đây
--     Room room = roomRepository.findByIdWithLock(request.getRoomId())
--         .orElseThrow(() -> new RoomNotFoundException(...));
--
--     // 2. Kiểm tra xung đột (đã có lock, an toàn 100%)
--     long conflicts = bookingRepository.countConflictingBookings(
--         request.getRoomId(), request.getCheckIn(), request.getCheckOut(), null);
--     if (conflicts > 0) throw new RoomNotAvailableException("Phòng đã được đặt!");
--
--     // 3. Tạo booking với PENDING + expires_at = now() + 15 phút
--     Booking booking = new Booking();
--     booking.setStatus(BookingStatus.PENDING);
--     booking.setExpiresAt(LocalDateTime.now().plusMinutes(15));
--     // ... set các field khác
--     return bookingRepository.save(booking);
--     // => COMMIT: Giải phóng lock, thread tiếp theo mới được vào
-- }

-----------------------------
[B2] OPTIMISTIC LOCKING (Khóa lạc quan - Phù hợp với tần suất thấp)
-----------------------------
-- Cơ chế: Không khóa khi đọc. Khi UPDATE, kiểm tra @Version có thay đổi không.
--         Nếu version đã bị thay đổi bởi thread khác => Ném OptimisticLockException.
-- Phù hợp: Tần suất tranh chấp THẤP, cần throughput cao.
-- Xử lý exception: Retry tối đa N lần hoặc báo lỗi cho user.
--
-- Bảng Bookings đã có cột `version INT DEFAULT 0` để hỗ trợ cơ chế này.
--
-- // Trong Booking.java (Entity)
-- @Version
-- private Integer version;  // JPA tự động tăng khi UPDATE
--
-- // Trong BookingService.java
-- @Transactional
-- @Retryable(value = OptimisticLockingFailureException.class, maxAttempts = 3)
-- public Booking createBooking(BookingRequest request) {
--     long conflicts = bookingRepository.countConflictingBookings(...);
--     if (conflicts > 0) throw new RoomNotAvailableException(...);
--
--     Booking booking = new Booking();
--     return bookingRepository.save(booking);
--     // Nếu 2 thread cùng save => 1 cái sẽ gặp OptimisticLockingFailureException
--     // => @Retryable sẽ tự retry
-- }

=================================================================
[C] BOOKING WORKFLOW - Sơ đồ trạng thái
=================================================================

Booking Status Flow:
    [User chọn phòng]
           |
           v
       PENDING ──────(15 phút hết hạn / Payment FAILED)──────> CANCELLED
           |
           | (MoMo/VNPAY Callback - Payment SUCCESS)
           v
       CONFIRMED
           |
           | (Staff check-in thực tế)
           v
       CHECKED_IN
           |
           | (Staff check-out, tính tiền cuối)
           v
       CHECKED_OUT ──> [Tạo Invoice PDF] ──> [Gửi Email] ──> [Mở khóa Review]
           |
           | (Yêu cầu hoàn tiền)
           v
       REFUNDED

=================================================================
*/

PRINT N'====================================================';
PRINT N'HBMS Database Schema đã được tạo thành công!';
PRINT N'  - 14 bảng chính (3NF)';
PRINT N'  - Index tối ưu cho Overbooking query';
PRINT N'  - Seed data: 5 users, 5 phòng, 5 dịch vụ';
PRINT N'  - SP: sp_CheckRoomAvailability, sp_CancelExpiredPendingBookings';
PRINT N'  - VIEW: vw_ActiveBookingsPerRoom';
PRINT N'====================================================';
GO
