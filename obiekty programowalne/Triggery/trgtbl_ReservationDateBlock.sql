--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trg_ReservationDateBlock
--------------------------------------------------------------------------------------
--blokowanie wprowadzenia daty wymeldowania przed dat¹ zameldowania oraz wprowadzenia rezerwacji z dat¹ wczeœniejsz¹ ni¿ data dzisiejsza
--wywo³ywany w trakcie wprowadzania/edycji daty zameldowania i daty wymeldowania
--
--parametry wyjœciowe/zwracane wartoœci:
--podczas edycji dat na wczeœniejsze ni¿ obecna lub próby edycji daty wymeldowania na wczeœniejsz¹ ni¿ zameldowania zmiany zostaj¹ zablokowane
--
/*
USE [HotelDatabase]
GO

INSERT INTO [hotel].[tbl_reservations]
           ([IdRoom]
           ,[CheckInDate]
           ,[CheckOutDate]
           ,[NumberOfGuests]
           ,[IdReservationStatus]
           ,[IdHotel])
     VALUES (1,'01.03.2012','01.04.2023', 2, 1, 1)
GO
--
--Wynik dzia³ania
--Rekord nie zostaje dodany do tabeli. 
--Komunikat:
--Msg 15009, Level 16, State 1, Procedure sp_helptext, Line 54 [Batch Start Line 0]
The object 'trg_ReservationUpdateBlock' does not exist in database 'HotelDatabase' or is invalid for this operation.
--------------------------------------------------------------------------------------
*/

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