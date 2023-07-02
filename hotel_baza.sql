CREATE DATABASE HotelDatabase

ALTER DATABASE HotelDatabase
ADD FILEGROUP Dictionaries;
GO
ALTER DATABASE HotelDatabase
ADD FILE
( NAME=HotelDatabase_dictionaries,
	FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HotelDatabase.ndf',
	SIZE=10 MB,
	MAXSIZE=50 MB,
	FILEGROWTH=5 MB
)
TO FILEGROUP Dictionaries;
GO

USE HotelDatabase
GO
CREATE SCHEMA hotel
GO
CREATE SCHEMA room
GO
CREATE SCHEMA employee
GO
CREATE SCHEMA payment
GO
CREATE SCHEMA reservation
GO

USE HotelDatabase
GO
CREATE TABLE room.tbl_status
(
IdRoomStatus int NOT NULL IDENTITY(1,1) PRIMARY KEY,
RoomStatusName varchar(20) NOT NULL
)
ON Dictionaries;

GO
CREATE TABLE room.tbl_room_type
(
IdRoomType int NOT NULL IDENTITY(1,1) PRIMARY KEY,
RoomName varchar(30) NOT NULL,
MaxNumberOfGuests int NOT NULL,
RoomPrice decimal NOT NULL,

)
ON Dictionaries;

CREATE TABLE employee.tbl_employee_position
(
IdEmployeePosition int NOT NULL IDENTITY(1,1) PRIMARY KEY,
PositionName varchar(18) NOT NULL,

)
ON Dictionaries;

CREATE TABLE payment.tbl_payment_type
(
IdPaymentType int NOT NULL IDENTITY(1,1) PRIMARY KEY,
PaymentName varchar(20) NOT NULL,

)
ON Dictionaries;

CREATE TABLE reservation.tbl_reservation_status
(
IdReservationStatus int NOT NULL IDENTITY(1,1) PRIMARY KEY,
StatusName varchar(20) NOT NULL,

)
ON Dictionaries;


--walidacja numeru pesel
CREATE OR ALTER FUNCTION dbo.uf_IsPeselOK (@pesel varchar(11))
RETURNS tinyint
AS
BEGIN
    DECLARE @wagi AS TABLE (
        pozycja tinyint NOT NULL,
        waga tinyint NOT NULL)
    DECLARE @result tinyint = 0
    IF ISNUMERIC(@pesel) = 0
        RETURN @result
    INSERT INTO @wagi (pozycja, waga)
    VALUES (1, 1), (2, 3), (3, 7), (4, 9), (5, 1),
           (6, 3), (7, 7), (8, 9), (9, 1), (10, 3), (11, 1)

    IF (SELECT SUM(CAST(SUBSTRING(@pesel, pozycja, 1) AS tinyint) * waga) % 10
        FROM @wagi) = 0
    BEGIN
        SET @result = 1
    END
    RETURN @result
END
GO

--walidacja numeru NIP
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION dbo.uf_IsNIPNumberOK (@NIPNumber varchar(10))
RETURNS tinyint
AS
BEGIN
    DECLARE @wagi AS TABLE (
        pozycja tinyint NOT NULL,
        waga tinyint NOT NULL)
    IF ISNUMERIC(@NIPNumber) = 0
        RETURN 0
    INSERT INTO @wagi (pozycja, waga)
    VALUES (1, 6), (2, 5), (3, 7), (4, 2), (5, 3),
           (6, 4), (7, 5), (8, 6), (9, 7)
    IF (SELECT SUM(CAST(SUBSTRING(@NIPNumber, pozycja, 1) AS tinyint) * waga) % 10
        FROM @wagi) <> CAST(SUBSTRING(@NIPNumber, 10, 1) AS tinyint)
        RETURN 0

    RETURN 1
END;
GO

CREATE TABLE hotel.tbl_hotels
(
IdHotel int NOT NULL IDENTITY(1,1) PRIMARY KEY,
ZipCode varchar(6) NOT NULL,
NumberOfTheBuilding varchar(6) NOT NULL,
Street varchar(30) NULL, 
City varchar(30) NOT NULL,
HotelName varchar(30) NOT NULL,
LandlinePhoneNumber varchar(12) NULL,
MobilelinePhoneNumber varchar(11) NULL,
Email varchar(30) NULL,
);
GO

CREATE TABLE hotel.tbl_rooms
(
IdRoom int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdRoomType int NOT NULL FOREIGN KEY REFERENCES room.tbl_room_type(IdRoomType) ON UPDATE CASCADE,
IdRoomStatus int NOT NULL FOREIGN KEY REFERENCES room.tbl_status(IdRoomStatus) ON UPDATE CASCADE,
RoomNumber int NOT NULL,
FloorNumber int NOT NULL,
IdHotel int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_hotels(IdHotel) ON UPDATE CASCADE,
);
GO


CREATE TABLE hotel.tbl_reservations
(
IdReservation int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdRoom int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_rooms(IdRoom),
CheckInDate date NOT NULL,
CheckOutDate date NOT NULL,
NumberOfGuests varchar(3) NOT NULL,
IdReservationStatus int NOT NULL FOREIGN KEY REFERENCES reservation.tbl_reservation_status(IdReservationStatus),
IdHotel int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_hotels(IdHotel),
);
GO

CREATE TABLE hotel.tbl_people_data
(
IdPersonData int NOT NULL IDENTITY(1,1) PRIMARY KEY,
ZipCode varchar(6) NOT NULL,
ApartmentNumber varchar(4) NULL,
NumberOfTheBuilding varchar(6) NOT NULL,
Street varchar(30) NULL, 
City varchar(30) NOT NULL,
Country varchar(30) NOT NULL,
DateOfBirth date NOT NULL CHECK ((YEAR(GETDATE()) - YEAR(DateOfBirth)) >= 18), 
MobilelinePhoneNumber varchar(11) NULL,
Email varchar(30) NULL,
);
GO

CREATE TABLE hotel.tbl_guests
(
IdGuest int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdPersonData int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_people_data(IdPersonData) ON UPDATE CASCADE,
[Name] varchar(15) NOT NULL, 
LastName varchar(30) NOT NULL, 
IDNumber varchar(9) NOT NULL UNIQUE, 
PassportNumber varchar(9) NOT NULL UNIQUE, 
);
GO

CREATE TABLE hotel.tbl_employees
(
IdEmployee int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdPersonData int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_people_data(IdPersonData) ON UPDATE CASCADE,
[Name] varchar(15) NOT NULL, 
LastName varchar(30) NOT NULL, 
IdEmployeePosition int NOT NULL FOREIGN KEY REFERENCES employee.tbl_employee_position(IdEmployeePosition) ON UPDATE CASCADE,
DateOfEmployment date NOT NULL CHECK (DateOfEmployment <= GETDATE()), 
IdHotel int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_hotels(IdHotel) ON UPDATE CASCADE,
PeselNumber varchar(11) NOT NULL CHECK (dbo.uf_IsPeselOK(PeselNumber) = 1)
);
GO


CREATE TABLE hotel.tbl_payments
(
IdPayment int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdPaymentType int NOT NULL FOREIGN KEY REFERENCES payment.tbl_payment_type(IdPaymentType) ON UPDATE CASCADE,
PaymentDate date NOT NULL
);
GO

CREATE TABLE hotel.tbl_transactions
(
IdTransaction int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdReservation int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_reservations(IdReservation),
IdPayment int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_payments(IdPayment),
IdEmployee int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_employees(IdEmployee),
IdGuest int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_guests(IdGuest),
IdHotel int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_hotels(IdHotel),
TransactionDate Date NOT NULL
);
GO

CREATE TABLE hotel.tbl_billing
(
IdBilling int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdTransaction int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_transactions(IdTransaction) ON UPDATE CASCADE,
IdGuest int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_guests(IdGuest) ON UPDATE CASCADE,
CompanyName varchar(30) NOT NULL, 
NIPNumber varchar(10) NOT NULL CHECK (dbo.uf_IsNIPNumberOK(NIPNumber) = 1),
SumOfBilling money Null);
GO

--indeksy 
CREATE NONCLUSTERED INDEX [idx_email] ON hotel.tbl_people_data
(
	[Email] ASC
)
CREATE NONCLUSTERED INDEX [idx_country] ON hotel.tbl_people_data
(
	[Country] ASC
)
CREATE NONCLUSTERED INDEX [idx_city] ON hotel.tbl_people_data
(
	[City] ASC
)
CREATE NONCLUSTERED INDEX [idx_city_hotel] ON hotel.tbl_hotels
(
	[City] ASC
)
CREATE NONCLUSTERED INDEX [idx_hotelName] ON hotel.tbl_hotels
(
	[HotelName] ASC
)
CREATE NONCLUSTERED INDEX [idx_TransactionDate] ON hotel.tbl_transactions
(
	[TransactionDate] ASC
)
CREATE NONCLUSTERED INDEX [idx_idReservation] ON hotel.tbl_transactions
(
	[IdReservation] ASC
)
CREATE NONCLUSTERED INDEX [idx_IdPayment] ON hotel.tbl_transactions
(
	[IdPayment] ASC
)

CREATE NONCLUSTERED INDEX [idx_checkInDate] ON hotel.tbl_reservations
(
	[CheckInDate] ASC
)
CREATE NONCLUSTERED INDEX [idx_checkOutDate] ON hotel.tbl_reservations
(
	[CheckOutDate] ASC
)
CREATE NONCLUSTERED INDEX [idx_numberOfGuests] ON hotel.tbl_reservations
(
	[NumberOfGuests] ASC
)
CREATE NONCLUSTERED INDEX [idx_IdReservationStatus] ON hotel.tbl_reservations
(
	[IdReservationStatus] ASC
)
CREATE NONCLUSTERED INDEX [idx_IdHotel] ON hotel.tbl_reservations
(
	[IdHotel] ASC
)

CREATE NONCLUSTERED INDEX [idx_lastName] ON hotel.tbl_guests
(
	[LastName] ASC
)

CREATE NONCLUSTERED INDEX [idx_lastName_employees] ON hotel.tbl_employees
(
	[LastName] ASC
)

CREATE NONCLUSTERED INDEX [idx_IdEmployeePositions] ON hotel.tbl_employees
(
	[IdEmployeePosition] ASC
)


CREATE NONCLUSTERED INDEX [idx_dateOfEmployment_employees] ON hotel.tbl_employees
(
	[DateOfEmployment] ASC
)

CREATE NONCLUSTERED INDEX [idx_roomNumber] ON  hotel.tbl_rooms
(
	[RoomNumber] ASC
)

CREATE NONCLUSTERED INDEX [idx_status] ON  hotel.tbl_rooms
(
	[IdRoomStatus] ASC
)
CREATE NONCLUSTERED INDEX [idx_type] ON  hotel.tbl_rooms
(
	[IdRoomType] ASC
)
CREATE NONCLUSTERED INDEX [idx_paymentDate] ON  hotel.tbl_payments
(
	[PaymentDate] ASC
)
CREATE NONCLUSTERED INDEX [idx_IdPaymentType] ON  hotel.tbl_payments
(
	[IdPaymentType] ASC
)

CREATE NONCLUSTERED INDEX [idx_NIPNumber] ON   hotel.tbl_billing
(
	[NIPNumber] ASC
)
CREATE NONCLUSTERED INDEX [idx_CompanyName] ON   hotel.tbl_billing
(
	[CompanyName] ASC
)


--inserty

INSERT INTO room.tbl_status (RoomStatusName) VALUES
('clean'),
('occupied'),
('maintenance'),
('out of order'),
('reserved');

INSERT INTO room.tbl_room_type (RoomName, MaxNumberOfGuests, RoomPrice) VALUES
('Single Room', 1, 100.00),
('Double Room', 2, 150.00),
('Twin Room', 2, 150.00),
('Triple Room', 3, 200.00),
('Quad Room', 4, 250.00),
('Deluxe Double Room', 2, 300.00),
('Deluxe Twin Room', 2, 300.00),
('Junior Suite', 2, 400.00),
('Executive Suite', 2, 500.00),
('Presidential Suite', 2, 1000.00);

INSERT INTO employee.tbl_employee_position (PositionName)
VALUES ('Manager'), ('Receptionist'), ('Cleaner'), ('Cook'), ('Waiter'), ('Bartender'), ('Security Guard'), ('IT Specialist'), ('Accountant'), ('HR Specialist');

INSERT INTO payment.tbl_payment_type (PaymentName) VALUES
('Cash'),
('Credit Card'),
('Debit Card'),
('Bank Transfer'),
('PayPal'),
('Google Pay'),
('Apple Pay'),
('Bitcoin'),
('Ethereum'),
('Dogecoin');

INSERT INTO reservation.tbl_reservation_status (StatusName) VALUES
('Pending'),
('Confirmed'),
('Checked In'),
('Checked Out'),
('Cancelled'),
('No Show'),
('Expired'),
('Invoiced'),
('Paid'),
('Partially Paid');

INSERT INTO hotel.tbl_hotels (ZipCode, NumberOfTheBuilding, Street, City, HotelName, LandlinePhoneNumber, MobilelinePhoneNumber, Email)
VALUES
('00-001', '1', 'First Street', 'Warsaw', 'The First Hotel', NULL, '48678901244', 'info@thefirsthotel.com'),
('00-002', '2', 'Second Street', 'Lodz', 'The Second Hotel', NULL, '48678901234', 'info@thesecondhotel.com'),
('00-003', '3', 'Third Street', 'Poznan', 'The Third Hotel', NULL, '48500123458', 'info@thethirdhotel.com'),
('00-004', '4', 'Fourth Street', 'Warsaw', 'The Fourth Hotel', NULL, '48500123459', 'info@thefourthhotel.com'),
('00-005', '5', 'Fifth Street', 'Gdansk', 'The Fifth Hotel', NULL, '48500123450', 'info@thefifthhotel.com'),
('00-006', '6', 'Sixth Street', 'Szczecin', 'The Sixth Hotel', NULL, '48500123451', 'info@thesixthhotel.com'),
('00-007', '7', 'Seventh Street', 'Gdynia', 'The Seventh Hotel', NULL, '48500123452', 'info@theseventhhotel.com'),
('00-008', '8', 'Eighth Street', 'Sopot', 'The Eighth Hotel', NULL, '48500123453', 'info@theeighthhotel.com'),
('00-009', '9', 'Ninth Street', 'Zakopane', 'The Ninth Hotel', NULL, '48500123454', 'info@theninthhotel.com'),
('00-010', '10', 'Tenth Street', 'Cracow', 'The Tenth Hotel', NULL, '48500123455', 'info@thetenthhotel.com');

INSERT INTO hotel.tbl_people_data (ZipCode, ApartmentNumber, NumberOfTheBuilding, Street, City, Country, DateOfBirth, MobilelinePhoneNumber, Email) 
VALUES 
('12-345', '12', '45', 'Black Street', 'Lodz', 'Poland', '1985-01-01', '48777777777', 'example1@example.com'),
('23-456', NULL, '34', 'Blue Street', 'Berlin', 'Germany', '1990-02-12', '48555555555', 'example2@example.com'),
('34-567', '22', '5', 'Orange Street', 'Galway', 'Ireland', '1988-08-15', '48666666666', 'example3@example.com'),
('45-678', '33', '11', 'White Street', 'Warsaw', 'Poland', '1977-05-03', '48555555566', 'example4@example.com'),
('56-789', '44', '9', 'Brown Street', 'Glasgow', 'Scotland', '1995-12-25', '48777777678', 'example5@example.com'),
('67-890', NULL, '2', 'Yellow Street', 'Gdansk', 'Poland', '1992-07-09', '48666666666', 'example6@example.com'),
('78-901', '7', '14', 'Color Street', 'Copenhagen', 'Denmark', '1981-04-22', '48777777777', 'example7@example.com'),
('78-901', '7', '14', 'Red Street', 'Oslo', 'Norway', '1999-05-03', '48777777778', 'example8@example.com'),
('78-901', '7', '14', 'Green Street', 'Poznan', 'Poland', '2001-07-15', '48777777779', 'example9@example.com'),
('78-901', '7', '14', 'Violet Street', 'Lodz', 'Poland', '2002-11-16', '48777777776', 'example10@example.com');


INSERT INTO hotel.tbl_rooms (IdRoomType, IdRoomStatus, RoomNumber, FloorNumber, IdHotel)
VALUES (1, 1, 101, 1, 1),
       (2, 1, 102, 2, 9),
       (3, 2, 103, 3, 3),
       (4, 2, 104, 4, 4),
       (5, 3, 201, 1, 1),
       (6, 3, 202, 2, 2),
       (7, 4, 203, 3, 2),
       (8, 4, 204, 4, 1),
       (9, 5, 301, 3, 8),
       (10, 5, 302, 3, 1);


INSERT INTO hotel.tbl_reservations (IdRoom, CheckInDate, CheckOutDate, NumberOfGuests, IdReservationStatus, IdHotel)
VALUES (1, '2023-04-01', '2023-04-05', '2', 1, 1),
(2, '2023-04-02', '2023-04-06', '3', 2, 2),
(3, '2023-04-01', '2023-04-03', '1', 3, 3),
(4, '2023-04-07', '2023-04-10', '2', 4, 4),
(5, '2023-04-15', '2023-04-18', '1', 5, 5),
(6, '2023-04-10', '2023-04-14', '3', 6, 6),
(7, '2023-04-12', '2023-04-15', '2', 7, 7),
(8, '2023-04-20', '2023-04-23', '1', 8, 8),
(9, '2023-04-21', '2023-04-25', '4', 9, 9),
(10, '2023-04-30', '2023-05-03', '2', 10, 10);

INSERT INTO hotel.tbl_guests (IdPersonData, Name, LastName, IDNumber, PassportNumber)
VALUES
(1, 'John', 'Doe', 'ABC123456', 'AB1234567'),
(2, 'Jane', 'Doe', 'DEF987654', 'DE7654321'),
(3, 'David', 'Smith', 'GHI456789', 'GH9876543'),
(4, 'Emily', 'Johnson', 'JKL234567', 'JK4321098'),
(5, 'Michael', 'Brown', 'MNO876543', 'MN6543210'),
(6, 'Sophia', 'Garcia', 'PQR345678', 'PQ0987654'),
(7, 'Robert', 'Taylor', 'STU912345', 'ST8765432'),
(8, 'Olivia', 'Wilson', 'VWX678901', 'VW7654321'),
(9, 'William', 'Martinez', 'YZA234567', 'YZ1234567'),
(10, 'Ava', 'Anderson', 'BCD890123', 'BC0987654');

INSERT INTO hotel.tbl_employees (IdPersonData, Name, LastName, IdEmployeePosition, DateOfEmployment, IdHotel, PeselNumber)
VALUES 
(1, 'Anna', 'Nowak', 1, '2022-01-01', 1, '58110187843'),
(2, 'Jan', 'Kowalski', 2, '2021-06-01', 2, '92061115432'),
(3, 'Katarzyna', 'W�jcik', 3, '2020-03-01', 3, '55090228281'),
(4, 'Piotr', 'Kowalczyk', 4, '2022-02-15', 1, '86112485874'),
(5, 'Marta', 'Lewandowska', 5, '2021-09-01', 2, '74092062244'),
(6, 'Micha�', 'Szyma�ski', 6, '2022-01-15', 3, '54042475931'),
(7, 'Kamil', 'Jankowski', 7, '2021-11-01', 1, '52102883577'),
(8, 'Karolina', 'W�jcik', 8, '2022-03-01', 2, '04301014645'),
(9, 'Adam', 'Kaczmarek', 9, '2021-08-01', 3, '56082015957'),
(10, 'Izabela', 'D�browska', 10, '2022-02-01', 1, '66031247728');


INSERT INTO hotel.tbl_payments (IdPaymentType, PaymentDate)
VALUES
(1, '2022-01-01'),
(2, '2022-02-03'),
(3, '2022-01-15'),
(4, '2022-02-07'),
(5, '2022-03-10'),
(6, '2022-04-21'),
(7, '2022-03-18'),
(8, '2022-02-28'),
(9, '2022-05-05'),
(10, '2022-04-12');

INSERT INTO hotel.tbl_transactions (IdReservation, IdPayment, IdEmployee, IdGuest, IdHotel, TransactionDate)
VALUES (1, 1, 2, 3, 1, '2023-03-14'),
 (2, 2, 3, 4, 1, '2023-03-15'),
(3, 3, 1, 5, 2, '2023-03-16'),
(4, 4, 2, 6, 2, '2023-03-17'),
(5, 5, 3, 7, 3, '2023-03-18'),
(6, 6, 4, 8, 3, '2023-03-19'),
(7, 7, 1, 9, 4, '2023-03-20'),
(8, 8, 2, 10, 4, '2023-03-21'),
(9, 9, 3, 1, 5, '2023-03-22'),
(10, 10, 4, 2, 5, '2023-03-23');

INSERT INTO hotel.tbl_billing (IdGuest, IdTransaction, CompanyName, NIPNumber)
VALUES 
(1,1, 'ABC Company', '1234567890'),
(2,2, 'XYZ Corporation', '0987654325'),
(3,3, 'PQR Industries', '1357902463'),
(4,4, 'LMN Enterprises', '8642097532'),
(5,5, 'DEF Inc.', '2468013578'),
(6,6, 'GHI Corporation', '9753108647'),
(7,7, 'JKL Industries', '7049182534');


-- widoki
-- Tworzenie widoku vw_warsaw_hotels
CREATE VIEW vw_warsaw_hotels
AS
SELECT
h.HotelName,
h.City,
h.Street,
h.NumberOfTheBuilding,
h.ZipCode
  FROM
    [hotel].[tbl_hotels] h
WHERE
    h.City = 'Warsaw';
GO

-- Tworzenie widoku vw_employees_poland
CREATE VIEW vw_employees_poland
AS
SELECT
e.Name,
e.LastName,
e.PeselNumber,
p.DateOfBirth,
p.Email,
p.Country
  FROM
[hotel].[tbl_people_data] p, [hotel].[tbl_employees] e  
WHERE
    p.Country = 'Poland' AND p.IdPersonData = e.IdPersonData;
GO

-- Tworzenie widoku vw_guests_poland
CREATE VIEW vw_guests_poland
AS
SELECT
g.Name,
g.LastName,
g.PassportNumber,
p.DateOfBirth,
p.Email,
p.Country
  FROM
[hotel].[tbl_people_data] p,  [hotel].[tbl_guests] g
WHERE
    p.Country = 'Poland' AND p.IdPersonData = g.IdPersonData;
GO

-- Tworzenie widoku vw_employees_position_IT
CREATE VIEW vw_employees_position_IT
AS
SELECT
e.Name,
e.LastName,
ep.PositionName
  FROM
[hotel].[tbl_employees] e, [employee].[tbl_employee_position] ep
WHERE
    ep.PositionName = 'IT Specialist' AND  e.IdEmployeePosition = ep.IdEmployeePosition;
GO

-- Tworzenie widoku vw_employees_position_manager
CREATE VIEW vw_employees_position_manager
AS
SELECT
e.Name,
e.LastName,
ep.PositionName
  FROM
[hotel].[tbl_employees] e, [employee].[tbl_employee_position] ep
WHERE
    ep.PositionName = 'Manager' AND  e.IdEmployeePosition = ep.IdEmployeePosition;
GO

-- Tworzenie widoku vw_rooms_reserved
CREATE VIEW vw_rooms_reserved
AS
SELECT
rt.RoomName,
rt.RoomPrice,
r.RoomNumber,
r.FloorNumber,
rt.MaxNumberOfGuests,
rs.RoomStatusName
  FROM
[hotel].[tbl_rooms] r, [room].[tbl_room_type] rt, [room].[tbl_status] rs
WHERE
    rs.RoomStatusName  = 'reserved' AND  rs.IdRoomStatus = r.IdRoomStatus AND rt.IdRoomType = r.IdRoomType;
GO

-- Tworzenie widoku vw_rooms_clean
CREATE VIEW vw_rooms_clean
AS
SELECT
rt.RoomName,
rt.RoomPrice,
r.RoomNumber,
r.FloorNumber,
rt.MaxNumberOfGuests,
rs.RoomStatusName
  FROM
[hotel].[tbl_rooms] r, [room].[tbl_room_type] rt, [room].[tbl_status] rs
WHERE
    rs.RoomStatusName  = 'clean' AND  rs.IdRoomStatus = r.IdRoomStatus AND rt.IdRoomType = r.IdRoomType;
GO

-- Tworzenie widoku vw_rooms_ooo
CREATE VIEW vw_rooms_ooo
AS
SELECT
rt.RoomName,
rt.RoomPrice,
r.RoomNumber,
r.FloorNumber,
rt.MaxNumberOfGuests,
rs.RoomStatusName
  FROM
[hotel].[tbl_rooms] r, [room].[tbl_room_type] rt, [room].[tbl_status] rs
WHERE
    rs.RoomStatusName  = 'out of order' AND  rs.IdRoomStatus = r.IdRoomStatus AND rt.IdRoomType = r.IdRoomType;
GO

-- Tworzenie widoku vw_reservation_pending
CREATE VIEW vw_reservation_pending
AS
SELECT
h.HotelName,
roo.RoomNumber,
rs.StatusName
FROM
[hotel].[tbl_reservations] res, [reservation].[tbl_reservation_status] rs, [hotel].[tbl_rooms] roo, [hotel].[tbl_hotels] h
WHERE
    rs.StatusName  = 'Pending' AND  rs.IdReservationStatus = res.IdReservationStatus AND res.IdRoom = roo.IdRoom AND res.IdHotel = h.IdHotel;
GO

-- Tworzenie widoku vw_reservation_confirmed
CREATE VIEW vw_reservation_confirmed
AS
SELECT
h.HotelName,
roo.RoomNumber,
rs.StatusName
FROM
[hotel].[tbl_reservations] res, [reservation].[tbl_reservation_status] rs, [hotel].[tbl_rooms] roo, [hotel].[tbl_hotels] h
WHERE
    rs.StatusName  = 'Confirmed' AND  rs.IdReservationStatus = res.IdReservationStatus AND res.IdRoom = roo.IdRoom AND res.IdHotel = h.IdHotel;
GO

-- Tworzenie widoku vw_reservation_cancelled
CREATE VIEW vw_reservation_cancelled
AS
SELECT
h.HotelName,
roo.RoomNumber,
rs.StatusName
FROM
[hotel].[tbl_reservations] res, [reservation].[tbl_reservation_status] rs, [hotel].[tbl_rooms] roo, [hotel].[tbl_hotels] h
WHERE
    rs.StatusName  = 'Cancelled' AND  rs.IdReservationStatus = res.IdReservationStatus AND res.IdRoom = roo.IdRoom AND res.IdHotel = h.IdHotel;
GO

-- Tworzenie widoku vw_billing_guest
CREATE VIEW vw_billing_guest
AS
SELECT
g.Name,
g.LastName,
g.PassportNumber,
b.CompanyName,
b.NIPNumber
FROM
[hotel].[tbl_guests] g, [hotel].[tbl_billing] b
WHERE
    g.IdGuest = b.IdGuest;
GO

-- Tworzenie widoku vw_guests_payment
CREATE VIEW vw_guests_payment
AS
SELECT
g.Name,
g.LastName,
t.TransactionDate,
pt.PaymentName
FROM
[hotel].[tbl_payments] p, [payment].[tbl_payment_type] pt, [hotel].[tbl_transactions] t, [hotel].[tbl_guests] g
WHERE
p.IdPaymentType = pt.IdPaymentType AND t.IdPayment = p.IdPayment AND t.IdGuest = g.IdGuest;
GO

-- Tworzenie widoku vw_guests_payment_cash
CREATE VIEW vw_guests_payment_cash
AS
SELECT
g.Name,
g.LastName,
t.TransactionDate,
pt.PaymentName
FROM
[hotel].[tbl_payments] p, [payment].[tbl_payment_type] pt, [hotel].[tbl_transactions] t, [hotel].[tbl_guests] g
WHERE
pt.PaymentName = 'Cash' AND p.IdPaymentType = pt.IdPaymentType AND t.IdPayment = p.IdPayment AND t.IdGuest = g.IdGuest;
GO

-- Tworzenie widoku vw_guests_payment_credit_card
CREATE VIEW vw_guests_payment_credit_card
AS
SELECT
g.Name,
g.LastName,
t.TransactionDate,
pt.PaymentName
FROM
[hotel].[tbl_payments] p, [payment].[tbl_payment_type] pt, [hotel].[tbl_transactions] t, [hotel].[tbl_guests] g
WHERE
pt.PaymentName = 'Credit Card' AND p.IdPaymentType = pt.IdPaymentType AND t.IdPayment = p.IdPayment AND t.IdGuest = g.IdGuest;
GO


--funkcje

--wyszukiwanie go�ci po imieniu lub nazwisku
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SearchGuestByNameOrLastName(@NameOrSurname varchar(60))
RETURNS TABLE
AS
RETURN(
SELECT g.IdGuest,g.IDNumber, g.LastName, g.Name, g.PassportNumber, pd.* 
FROM [hotel].[tbl_guests] as g inner join [hotel].[tbl_people_data] as pd
on g.IdPersonData=pd.IdPersonData
WHERE LOWER([Name])+' '+LOWER([LastName]) LIKE LOWER('%'+@NameOrSurname+'%'))
GO

--aktualny status podanego pokoju
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_IsRoomFree(@id_room int)
RETURNS bit
AS
BEGIN
    DECLARE @is_free bit, @CheckInDate date, @CheckOutDate date, @status varchar(100);
        SELECT @CheckInDate = r.CheckInDate, @CheckOutDate = r.CheckOutDate, @status = s.StatusName
        FROM [hotel].[tbl_reservations] as r
        INNER JOIN [reservation].[tbl_reservation_status] as s
        ON r.IdReservationStatus = s.IdReservationStatus
        WHERE r.IdRoom = @id_room;
        IF (@status IS NULL OR @status = 'Cancelled' OR @CheckOutDate <= GETDATE() OR @CheckInDate >= GETDATE())
            SET @is_free = 1;
        ELSE
            SET @is_free = 0;
        RETURN @is_free;
END;
GO

--liczba rezerwacji dla go�cia o danym imieniu/nazwisku
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_NumberOfGuestReservations(@NameOrLastName varchar(50))
RETURNS TABLE
AS
    RETURN (
            SELECT p.Name, p.LastName, p.IdGuest, COUNT(r.IdReservation) AS NumberOfReservation
            FROM (
                SELECT g.Name, g.LastName, g.IdGuest, t.IdReservation
                FROM [hotel].[tbl_guests] AS g
                INNER JOIN [hotel].[tbl_transactions] AS t ON g.IdGuest = t.IdGuest
            ) AS p
            INNER JOIN [hotel].[tbl_reservations] AS r ON r.[IdReservation] = p.[IdReservation]
            WHERE LOWER(p.Name) + ' ' + LOWER(p.LastName) LIKE LOWER('%' + @NameOrLastName + '%')
            GROUP BY p.IdGuest, p.Name, p.LastName
    )
GO


--wydobywanie ceny danego pokoju
USE HotelDatabase
GO
CREATE OR ALTER FUNCTION uf_getRoomPrice(@id_room int)
RETURNS money
BEGIN
    DECLARE @price money;
	IF EXISTS (SELECT 1 FROM [hotel].[tbl_rooms] WHERE [IdRoom] = @id_room)
	BEGIN
    SET @price = (
        SELECT [RoomPrice]
        FROM [room].[tbl_room_type] AS rt
        INNER JOIN [hotel].[tbl_rooms] AS r ON rt.[IdRoomType] = r.[IdRoomType]
        WHERE r.[IdRoom] = @id_room
    );
	END
	ELSE
	BEGIN
		SET @price = NULL;
	END
	return @price
END

--numer go�cia na podstawie numeru faktury
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_getGuestId(@id_billing int)
RETURNS int
BEGIN
    DECLARE @id int;
	IF EXISTS (SELECT 1 FROM [hotel].[tbl_billing] WHERE [IdBilling] = @id_billing)
    BEGIN
		SET @id = (SELECT [IdPersonData] 
                   FROM [hotel].[tbl_billing] as b 
                   INNER JOIN [hotel].[tbl_guests] as g 
                   ON b.IdGuest = g.IdGuest 
                   WHERE IdBilling = @id_billing);
    END
    BEGIN
        SET @id = NULL;
    END;
    RETURN @id;
END;
GO


--data wymeldowania na podstawie numeru rezerwacji
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_getCheckOutDate(@id_reservation int)
RETURNS date
BEGIN
    DECLARE @CheckOutDate date;
    IF EXISTS (SELECT 1 FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
		BEGIN
		SET @CheckOutDate = (SELECT CheckOutDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation);
		END 
	else BEGIN 
			SET @CheckOutDate = NULL;
		END;

    RETURN @CheckOutDate;
END;
GO


--data zameldowania na podstawie numeru rezerwacji
USE HotelDatabase;
GO
CREATE FUNCTION uf_getCheckInDate(@id_reservation int)
RETURNS date
BEGIN
    DECLARE @CheckInDate date;
	IF EXISTS (SELECT 1 FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
	    BEGIN
			SET @CheckInDate = (SELECT CheckInDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation);
		END
	else BEGIN 
			SET @CheckInDate = NULL;
		END;

    RETURN @CheckInDate;
END;
GO

--obliczanie d�ugo�ci pobytu w dniach
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_LengthOfTheVisit(@id_Reservation int)
RETURNS int
AS
BEGIN
    DECLARE @days int, @CheckInDate date, @CheckOutDate date
    SELECT @CheckInDate = r.CheckInDate, @CheckOutDate = r.CheckOutDate
    FROM [hotel].[tbl_reservations] AS r
    JOIN [hotel].[tbl_transactions] AS t ON r.IdReservation = t.IdReservation
    WHERE r.IdReservation = @id_Reservation
    SET @days = DATEDIFF(day, @CheckInDate, @CheckOutDate)

    RETURN @days
END;
GO

--zmiana statusu pokoju na zarezerwowany
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_setRoomStatusReserved(@id_room int)
RETURNS bit
AS
BEGIN
    DECLARE @isRoomReserved bit, @CheckInDate date, @CheckOutDate date, @status varchar
    SELECT @CheckInDate = [CheckInDate], @CheckOutDate = [CheckOutDate] 
    FROM [hotel].[tbl_reservations]
    WHERE [IdRoom] = @id_room
    SELECT @status = [StatusName]
    FROM [reservation].[tbl_reservation_status] AS s
    INNER JOIN [hotel].[tbl_reservations] AS r ON s.[IdReservationStatus] = r.[IdReservationStatus]
    WHERE r.[IdRoom] = @id_room
    IF @CheckInDate < GETDATE() AND @CheckOutDate > GETDATE() AND @status <> 'Cancelled'
        SET @isRoomReserved = 1
    ELSE
        SET @isRoomReserved = 0
    RETURN @isRoomReserved
END;
GO

--obliczanie ��cznej kwoty faktury
USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_SumOfBilling(@id_transaction int)
RETURNS money
AS
BEGIN
    DECLARE @SumOfBilling money = 0
    
	IF EXISTS (SELECT 1 FROM [hotel].[tbl_transactions] WHERE [IdTransaction] = @id_transaction)
    BEGIN
        SELECT @SumOfBilling += dbo.uf_LengthOfTheVisit(r.IdReservation) * dbo.uf_getRoomPrice(r.IdRoom)
        FROM [hotel].[tbl_transactions] AS t
        JOIN [hotel].[tbl_reservations] AS r ON t.IdReservation = r.IdReservation
        WHERE t.IdTransaction = @id_transaction
    END
	ELSE
    BEGIN
        SET @SumOfBilling = NULL
    END
    RETURN @SumOfBilling
END;
GO


--regu�y i warto�ci domy�lne
--warto�ci domy�lne

CREATE DEFAULT df_EmploymentDate AS GETDATE()
EXEC sp_bindefault df_EmploymentDate, 'hotel.tbl_employees.DateOfEmployment'

CREATE DEFAULT df_TransactionDate AS GETDATE()
EXEC sp_bindefault df_TransactionDate, 'hotel.tbl_transactions.TransactionDate'

CREATE DEFAULT df_MobilePhone AS '48000000000'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_people_data.MobilelinePhoneNumber'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_hotels.MobilelinePhoneNumber'

CREATE DEFAULT df_email AS 'default.mail@default.com'
EXEC sp_bindefault df_email, 'hotel.tbl_people_data.Email'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_hotels.Email'

CREATE DEFAULT df_country AS 'Poland'
EXEC sp_bindefault df_email, 'hotel.tbl_people_data.Country'

CREATE DEFAULT df_PaymentDate AS GETDATE()
EXEC sp_bindefault df_PaymentDate, 'hotel.tbl_payments.PaymentDate'

CREATE DEFAULT df_LandlinePhoneNumber AS '(22) 123 45 67'
EXEC sp_bindefault df_LandlinePhoneNumber, 'hotel.tbl_hotels.LandlinePhoneNumber'


--regu�y

CREATE RULE rl_ZipCode as @ZipCode LIKE '[0-9][0-9]-[0-9][0-9][0-9]';
EXEC sp_bindrule rl_ZipCode, 'hotel.tbl_people_data.ZipCode'
EXEC sp_bindrule rl_ZipCode, 'hotel.tbl_hotels.ZipCode'

CREATE RULE rl_Email as @email LIKE '%[A-Z0-9][@][A-Z0-9]%[.][A-Z0-9]%' 
OR @email LIKE NULL;
EXEC sp_bindrule rl_Email, 'hotel.tbl_people_data.Email'
EXEC sp_bindrule rl_Email, 'hotel.tbl_hotels.Email'

CREATE RULE rl_DateOfBirth AS (@DateOfBirth < CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_DateOfBirth, 'hotel.tbl_people_data.DateOfBirth'

CREATE RULE rl_EmploymentDate AS (@EmploymentDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_EmploymentDate, 'hotel.tbl_employees.DateOfEmployment'

CREATE RULE rl_TransactionDate AS (@TransactionDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule  rl_TransactionDate,'hotel.tbl_transactions.TransactionDate'

CREATE RULE rl_PaymentDate AS (@PaymentDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_PaymentDate, 'hotel.tbl_payments.PaymentDate'

CREATE RULE rl_MobilePhone as @MobilePhone LIKE '48[5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
or @MobilePhone LIKE NULL;
EXEC sp_bindrule rl_MobilePhone, 'hotel.tbl_people_data.MobilelinePhoneNumber'
EXEC sp_bindrule rl_MobilePhone, 'hotel.tbl_hotels.MobilelinePhoneNumber'

CREATE RULE rl_IDNumber as @IDNumber LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]';
EXEC sp_bindrule rl_IDNumber, 'hotel.tbl_guests.IDNumber'

CREATE RULE rl_PassportNumber as @PassportNumber LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
EXEC sp_bindrule rl_PassportNumber, 'hotel.tbl_guests.PassportNumber'

CREATE RULE rl_LandlinePhoneNumber as @LandlinePhoneNumber LIKE '([1-9][0-9]) [0-9][0-9][0-9] [0-9][0-9][0-9]' 
OR @LandlinePhoneNumber LIKE NULL;
EXEC sp_bindrule rl_LandlinePhoneNumber, 'hotel.tbl_hotels.LandlinePhoneNumber'

--Procedury
CREATE OR ALTER PROCEDURE up_AddEmployee
    @FirstName varchar(15),
    @LastName varchar(30),
    @EmployeePosition varchar(18),
    @DateOfEmployment date,
    @HotelId int,
    @ZipCode varchar(6),
    @ApartmentNumber varchar(4),
    @NumberOfTheBuilding varchar(6),
    @Street varchar(30),
    @City varchar(30),
    @Country varchar(30),
    @DateOfBirth date,
    @MobilePhoneNumber varchar(11),
    @Email varchar(30),
    @PeselNumber varchar(11)
AS
BEGIN
    SET NOCOUNT ON;
        BEGIN TRANSACTION;
        DECLARE @PersonDataId int;
        INSERT INTO hotel.tbl_people_data (ZipCode, ApartmentNumber, NumberOfTheBuilding, Street, City, Country, DateOfBirth, MobilelinePhoneNumber, Email)
        VALUES (@ZipCode, @ApartmentNumber, @NumberOfTheBuilding, @Street, @City, @Country, @DateOfBirth, @MobilePhoneNumber, @Email);
        SET @PersonDataId = SCOPE_IDENTITY();
        DECLARE @EmployeePositionId int;
        SELECT @EmployeePositionId = IdEmployeePosition FROM employee.tbl_employee_position WHERE PositionName = @EmployeePosition;
        INSERT INTO hotel.tbl_employees (IdPersonData, [Name], LastName, IdEmployeePosition, DateOfEmployment, IdHotel, PeselNumber)
        VALUES (@PersonDataId, @FirstName, @LastName, @EmployeePositionId, @DateOfEmployment, @HotelId, @PeselNumber);
        COMMIT;
        IF @@TRANCOUNT > 0
            ROLLBACK;
END
GO

--Procedura dodająca nowego gościa hotelu--
USE HotelDatabase
GO
CREATE OR ALTER PROCEDURE up_AddGuest
(
    @Name varchar(15),
    @LastName varchar(30),
    @IDNumber varchar(9),
    @PassportNumber varchar(9),
    @ZipCode varchar(6),
    @ApartmentNumber varchar(4),
    @NumberOfTheBuilding varchar(6),
    @Street varchar(30),
    @City varchar(30),
    @Country varchar(30),
    @DateOfBirth date,
    @MobilelinePhoneNumber varchar(11),
    @Email varchar(30)
)
AS
BEGIN
    SET NOCOUNT ON;

        DECLARE @IdPersonData int;
        INSERT INTO hotel.tbl_people_data (ZipCode, ApartmentNumber, NumberOfTheBuilding, Street, City, Country, DateOfBirth, MobilelinePhoneNumber, Email)
        VALUES (@ZipCode, @ApartmentNumber, @NumberOfTheBuilding, @Street, @City, @Country, @DateOfBirth, @MobilelinePhoneNumber, @Email);
        SET @IdPersonData = SCOPE_IDENTITY();
        INSERT INTO hotel.tbl_guests (IdPersonData, [Name], LastName, IDNumber, PassportNumber)
        VALUES (@IdPersonData, @Name, @LastName, @IDNumber, @PassportNumber);
        SELECT 'Guest added successfully.' AS Result;
END
GO

---Procedura usuwająca gościa hotela--
CREATE OR ALTER PROCEDURE up_DeleteGuest
    @PassportNumber VARCHAR(9)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Sprawdź, czy gość istnieje na podstawie numeru paszportowego
        DECLARE @GuestId INT;

        SELECT @GuestId = IdGuest
        FROM hotel.tbl_guests
        WHERE PassportNumber = @PassportNumber;
        IF @GuestId IS NOT NULL
        BEGIN
            -- Usuń powiązane wpisy z tabeli hotel.tbl_billing
            DELETE FROM hotel.tbl_billing
            WHERE IdGuest = @GuestId;
            -- Usuń gościa z tabeli hotel.tbl_guests
            DELETE FROM hotel.tbl_guests
            WHERE IdGuest = @GuestId;

            SELECT 'Gość został pomyślnie usunięty.' AS Result;
        END
        ELSE
        BEGIN
            RAISERROR('Nie znaleziono gościa o podanym numerze paszportowym.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas usuwania gościa: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura aktualizująca pozycje pracownika--
CREATE PROCEDURE up_UpdateEmployeePositionByPesel
    @PeselNumber VARCHAR(11),
    @NewPosition VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
        UPDATE hotel.tbl_employees
        SET IdEmployeePosition = (
            SELECT IdEmployeePosition
            FROM HotelDatabase.employee.tbl_employee_position
            WHERE PositionName = @NewPosition
        )
        WHERE PeselNumber = @PeselNumber;

        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Stanowisko pracownika zostało zaktualizowane.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono pracownika o podanym numerze PESEL.';
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorState INT;

			SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();
			RAISERROR('Wystąpił błąd podczas aktualizowania stanowiska pracownika: %s', @ErrorState, 1, @ErrorMessage);
        END;
END;

--Procedura aktualizująca status rezerwacji--
CREATE PROCEDURE up_UpdateReservationStatusByRoom
    @RoomNumber INT,
    @NewStatusName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [HotelDatabase].[hotel].[tbl_reservations]
        SET IdReservationStatus = (SELECT IdReservationStatus FROM [HotelDatabase].[reservation].[tbl_reservation_status] WHERE StatusName = @NewStatusName)
        WHERE IdRoom IN (SELECT IdRoom FROM [HotelDatabase].[hotel].[tbl_rooms] WHERE RoomNumber = @RoomNumber);

        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Status rezerwacji został zaktualizowany dla pokoju o numerze ' + CAST(@RoomNumber AS VARCHAR(10)) + '.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono rezerwacji dla pokoju o numerze ' + CAST(@RoomNumber AS VARCHAR(10)) + '.';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();
        RAISERROR('Wystąpił błąd podczas aktualizowania statusu rezerwacji: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura usuwająca pracownika--
CREATE OR ALTER PROCEDURE up_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Usunięcie powiązanych rekordów w tabeli tbl_transactions
        DELETE FROM hotel.tbl_transactions
        WHERE IdEmployee = @EmployeeId;

        -- Usunięcie powiązanych rekordów w tabeli tbl_guests
        DELETE FROM hotel.tbl_guests
        WHERE IdPersonData = (SELECT IdPersonData FROM hotel.tbl_employees WHERE hotel.tbl_employees.IdEmployee = @EmployeeId);

        -- Usunięcie pracownika z tabeli tbl_employees
        DELETE FROM hotel.tbl_employees
        WHERE hotel.tbl_employees.IdEmployee = @EmployeeId;

        -- Usunięcie danych osobowych pracownika z tabeli tbl_people_data
        DELETE FROM hotel.tbl_people_data
        WHERE IdPersonData = (SELECT IdPersonData FROM hotel.tbl_employees WHERE hotel.tbl_employees.IdEmployee = @EmployeeId);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas usuwania pracownika: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura akutalizująca dane pracownika--
CREATE OR ALTER PROCEDURE up_UpdateEmployee
(
    @EmployeeId INT,
    @FirstName VARCHAR(15),
    @LastName VARCHAR(30),
    @EmployeePositionId INT,
    @DateOfEmployment DATE,
    @HotelId INT,
    @PeselNumber VARCHAR(11)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE hotel.tbl_employees
        SET
            [Name] = @FirstName,
            LastName = @LastName,
            IdEmployeePosition = @EmployeePositionId,
            DateOfEmployment = @DateOfEmployment,
            IdHotel = @HotelId,
            PeselNumber = @PeselNumber
        WHERE
            IdEmployee = @EmployeeId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas aktualizowania pracownika: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura usuwania hotelu--
CREATE OR ALTER PROCEDURE up_DeleteHotel
    @HotelName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM hotel.tbl_hotels
            WHERE HotelName = @HotelName
        )
        BEGIN
            RAISERROR('Nie znaleziono hotelu o podanej nazwie.', 16, 1);
            RETURN;
        END;
        DELETE FROM hotel.tbl_hotels
        WHERE HotelName = @HotelName;

        SELECT 'Hotel został pomyślnie usunięty.' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas usuwania hotelu: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura dodająca nowy hotel--
CREATE OR ALTER PROCEDURE up_AddHotel
    @HotelName VARCHAR(30),
    @CityName VARCHAR(50),
    @StreetAddress VARCHAR(100),
    @PhoneNumber VARCHAR(20),
    @ZipCode VARCHAR(6),
    @NumberOfTheBuilding varchar(6)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO hotel.tbl_hotels (HotelName, City, Street, LandlinePhoneNumber, ZipCode, NumberOfTheBuilding)
        VALUES (@HotelName, @CityName, @StreetAddress, @PhoneNumber, @ZipCode, @NumberOfTheBuilding);

        SELECT 'Hotel added successfully.' AS Result;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH;
END;

--Procedura zmieniajaca status pokoju--
CREATE OR ALTER PROCEDURE up_ChangeRoomStatus
    @RoomNumber INT,
    @NewStatus INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [hotel].[tbl_rooms]
        SET IdRoomStatus = @NewStatus
        WHERE RoomNumber = @RoomNumber
          AND EXISTS (
            SELECT 1
            FROM [room].[tbl_status]
            WHERE IdRoomStatus = @NewStatus
          );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas zmiany statusu pokoju: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura wyłączająca triggery dla wybranej tabeli słownikowej--
CREATE OR ALTER PROCEDURE up_SetTriggerOFF
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @TableName IN ('employee.tbl_employee_position', 'tbl_employee_position', '[employee].[tbl_employee_position]')
        BEGIN
            DISABLE TRIGGER trg_EmployeePositionEditBlock ON tbl_employee_position;
            PRINT 'Triger dla tabeli ' + @TableName + ' został wyłączony.';
        END
        ELSE IF @TableName IN ('tbl_status', '[room.tbl_status', '[room].[tbl_status]')
        BEGIN
            DISABLE TRIGGER trg_RoomStatusEditBlock ON tbl_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' został wyłączony.';
        END
        ELSE IF @TableName IN ('tbl_reservation_status', 'reservation.tbl_reservation_status', '[reservation].[tbl_reservation_status]')
        BEGIN
            DISABLE TRIGGER trg_ReservationStatusEditBlock ON tbl_reservation_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' został wyłączony.';
        END
        ELSE IF @TableName IN ('tbl_room_type', 'room.tbl_room_type', '[room].[tbl_room_type]')
        BEGIN
            DISABLE TRIGGER trg_RoomTypeEditBlock ON [room].[tbl_room_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' został wyłączony.';
        END
        ELSE IF @TableName IN ('tbl_payment_type', 'payment.tbl_payment_type', '[payment].[tbl_payment_type]')
        BEGIN
            DISABLE TRIGGER trg_PaymentTypeEditBlock ON [payment].[tbl_payment_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' został wyłączony.';
        END
        ELSE
        BEGIN
            RAISERROR('Nieprawidłowa nazwa tabeli.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas wyłączania trigerów: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Procedura włączająca triggery dla wybranej tabeli słownikowej--
CREATE OR ALTER PROCEDURE up_SetTriggerON
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @TableName IN ('employee.tbl_employee_position', 'tbl_employee_position', '[employee].[tbl_employee_position]')
        BEGIN
            ENABLE TRIGGER trg_EmployeePositionEditBlock ON tbl_employee_position;
            PRINT 'Triger dla tabeli ' + @TableName + ' został włączony.';
        END
        ELSE IF @TableName IN ('tbl_status', '[room.tbl_status', '[room].[tbl_status]')
        BEGIN
            ENABLE TRIGGER trg_RoomStatusEditBlock ON tbl_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' został włączony.';
        END
        ELSE IF @TableName IN ('tbl_reservation_status', 'reservation.tbl_reservation_status', '[reservation].[tbl_reservation_status]')
        BEGIN
            ENABLE TRIGGER trg_ReservationStatusEditBlock ON tbl_reservation_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' został włączony.';
        END
        ELSE IF @TableName IN ('tbl_room_type', 'room.tbl_room_type', '[room].[tbl_room_type]')
        BEGIN
            ENABLE TRIGGER trg_RoomTypeEditBlock ON [room].[tbl_room_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' został włączony.';
        END
        ELSE IF @TableName IN ('tbl_payment_type', 'payment.tbl_payment_type', '[payment].[tbl_payment_type]')
        BEGIN
            ENABLE TRIGGER trg_PaymentTypeEditBlock ON [payment].[tbl_payment_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' został włączony.';
        END
        ELSE
        BEGIN
            RAISERROR('Nieprawidłowa nazwa tabeli.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas włączania trigerów: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--dodawanie rezerwacji
USE HotelDatabase;
GO
CREATE OR ALTER PROCEDURE up_addReservation
(
    @IdRoom INT,
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @NumberOfGuests VARCHAR(3),
    @IdReservationStatus INT,
    @IdHotel INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Sprawdź czy pokój jest dostępny w wybranym okresie
        IF EXISTS (
            SELECT 1
            FROM hotel.tbl_reservations
            WHERE IdRoom = @IdRoom
            AND (
                (CheckInDate >= @CheckInDate AND CheckInDate < @CheckOutDate)
                OR (CheckOutDate > @CheckInDate AND CheckOutDate <= @CheckOutDate)
                OR (CheckInDate < @CheckInDate AND CheckOutDate > @CheckOutDate)
            )
        )
        BEGIN
            RAISERROR('Ten pokój jest zarezerwowany.', 16, 1);
            RETURN;
        END;

        -- Dodaj nową rezerwację i zwróć pełne informacje o wstawionym wierszu
        insert INTO hotel.tbl_reservations (IdRoom, CheckInDate, CheckOutDate, NumberOfGuests, IdReservationStatus, IdHotel)
        VALUES (@IdRoom, @CheckInDate, @CheckOutDate, @NumberOfGuests, @IdReservationStatus, @IdHotel);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas dodawania rezerwacji: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

--dodawanie transakcji z płatnością
CREATE OR ALTER PROCEDURE up_AddTransactionWithPayment
(
    @ReservationId INT,
    @EmployeeId INT,
    @GuestId INT,
    @HotelId INT,
    @TransactionDate DATE,
    @PaymentTypeId INT,
    @PaymentDate DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @PaymentId INT;

        -- Dodaj nową płatność
        INSERT INTO hotel.tbl_payments (IdPaymentType, PaymentDate)
        VALUES (@PaymentTypeId, @PaymentDate);

        -- Pobierz identyfikator dodanej płatności
        SET @PaymentId = SCOPE_IDENTITY();

        -- Dodaj nową transakcję z powiązaną płatnością
        INSERT INTO hotel.tbl_transactions (IdReservation, IdPayment, IdEmployee, IdGuest, IdHotel, TransactionDate)
        VALUES (@ReservationId, @PaymentId, @EmployeeId, @GuestId, @HotelId, @TransactionDate);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas dodawania transakcji: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;


--edytowanie rezerwacji
CREATE PROCEDURE up_UpdateReservation
    @IdReservation INT,
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @NumberOfGuests VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE hotel.tbl_reservations
        SET CheckInDate = @CheckInDate,
            CheckOutDate = @CheckOutDate,
            NumberOfGuests = @NumberOfGuests
        WHERE IdReservation = @IdReservation;
        
        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Rezerwacja została zaktualizowana.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono rezerwacji o podanym identyfikatorze.';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas aktualizowania rezerwacji: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--dodawanie faktury
CREATE PROCEDURE up_AddBilling
(
	@TransactionId INT,
    @GuestId INT,
    @CompanyName VARCHAR(30),
    @NIPNumber VARCHAR(10),
    @SumOfBilling MONEY
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO hotel.tbl_billing (IdTransaction, IdGuest, CompanyName, NIPNumber, SumOfBilling)
        VALUES (@TransactionId, @GuestId, @CompanyName, @NIPNumber, @SumOfBilling);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT  @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas dodawania faktury: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
--Triggery--

USE HotelDatabase;
GO
CREATE OR ALTER TRIGGER trgtbl_ReservationDateBlock
ON hotel.tbl_reservations
INSTEAD OF UPDATE, INSERT
AS
BEGIN
declare @IdReservation int;
declare @IdRoom int;
declare @CheckInDate Date;
declare @CheckOutDate Date;
declare @NumberOfGuest int;
declare @IdReservationStatus int;
declare @IdHotel int;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.CheckInDate > i.CheckOutDate
    )
    BEGIN
        RAISERROR('Data zameldowania nie może być późniejsza niż data wymeldowania.', 16, 1);
		ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.CheckOutDate < GETDATE()
    )
    BEGIN
        RAISERROR('Data wymeldowania nie może być wcześniejsza niż obecna data.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.CheckInDate < CONVERT(DATE, GETDATE())
    )
    BEGIN
        RAISERROR('Data zameldowania nie może być wcześniejsza niż dzisiejsza data.', 16, 1);
        ROLLBACK TRANSACTION; 
        RETURN;
    END;

    IF EXISTS (SELECT * FROM deleted)
    BEGIN
		Select @IdReservation=IdReservation, @IdRoom=IdRoom,
		@CheckInDate=CheckInDate, @CheckOutDate=CheckOutDate, @NumberOfGuest=NumberOfGuests,
		@IdReservationStatus=IdReservationStatus, @IdHotel=IdHotel
		from inserted
		update hotel.tbl_reservations set IdRoom=@IdRoom, 
		CheckInDate=@CheckInDate, CheckOutDate=@CheckOutDate, 
		NumberOfGuests=@NumberOfGuest, IdReservationStatus=@IdReservationStatus, 
		IdHotel=@IdHotel where IdReservation=@IdReservation 
    END;
	ElSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		Select @IdRoom=IdRoom,@CheckInDate=CheckInDate,
		@CheckOutDate=CheckOutDate, @NumberOfGuest=NumberOfGuests,
		@IdReservationStatus=IdReservationStatus, @IdHotel=IdHotel
		from inserted
		Insert into hotel.tbl_reservations(IdRoom, CheckInDate,CheckOutDate, NumberOfGuests, IdReservationStatus, IdHotel)
		values(@IdRoom, @CheckInDate, @CheckOutDate, @NumberOfGuest, @IdReservationStatus, @IdHotel)
    END;
END;
GO


USE HotelDatabase;
GO
CREATE OR ALTER TRIGGER trgtbl_ChangeRoomStatus
ON hotel.tbl_reservations
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @IdReservationStatus int;
	DECLARE @ReservationStatus varchar(20);
    DECLARE @IdRoom int;

    SELECT TOP 1 @IdReservationStatus = i.IdReservationStatus,
                 @IdRoom = i.IdRoom
    FROM inserted i;

	Select @ReservationStatus=[StatusName]
	from [reservation].[tbl_reservation_status]
	where [IdReservationStatus]=@IdReservationStatus

    IF @ReservationStatus = 'Checked In'
    BEGIN
        UPDATE r
        SET r.IdRoomStatus = (select [IdRoomStatus]
		from [room].[tbl_status] 
		where [RoomStatusName]='occupied')
        FROM hotel.tbl_rooms r
        WHERE r.IdRoom = @IdRoom;
    END
    ELSE IF @ReservationStatus = 'Checked Out'
    BEGIN
        UPDATE r
        SET r.IdRoomStatus = (select [IdRoomStatus]
		from [room].[tbl_status] 
		where [RoomStatusName]='clean')
        FROM hotel.tbl_rooms r
        WHERE r.IdRoom = @IdRoom;
    END;
END;
GO

use HotelDatabase
go
CREATE TRIGGER trgtbl_EmployeePositionEditBlock ON employee.tbl_employee_position
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trgtbl_RoomStatusEditBlock ON room.tbl_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trgtbl_PaymentTypeEditBlock ON payment.tbl_payment_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trgtbl_RoomTypeEditBlock ON room.tbl_room_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trgtbl_ReservationStatusEditBlock ON reservation.tbl_reservation_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

