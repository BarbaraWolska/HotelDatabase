
--blokowanie wprowadzenia daty wymeldowania przed dat¹ zameldowania oraz wprowadzenia rezerwacji z dat¹ wczeœniejsz¹ ni¿ data dzisiejsza
use HotelDatabase
go
CREATE or ALTER TRIGGER trg_ReservationDateBlock ON hotel.tbl_reservations
INSTEAD OF UPDATE, INSERT
AS
IF (select CheckInDate from hotel.tbl_reservations)>(select CheckOutDate from hotel.tbl_reservations)
RETURN;
IF (select CheckInDate from hotel.tbl_reservations)<GETDATE()
IF (select CheckOutDate from hotel.tbl_reservations)<GETDATE()
RETURN;
GO

--blokowanie dodawania, edycji i usuwania wierszy w tabelach s³ownikowych
use HotelDatabase
go
CREATE TRIGGER trg_EmployeePositionEditBlock ON employee.tbl_employee_position
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trg_RoomStatusEditBlock ON room.tbl_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trg_PaymentTypeEditBlock ON payment.tbl_payment_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trg_RoomTypeEditBlock ON room.tbl_room_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

use HotelDatabase
go
CREATE TRIGGER trg_ReservationStatusEditBlock ON reservation.tbl_reservation_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO

