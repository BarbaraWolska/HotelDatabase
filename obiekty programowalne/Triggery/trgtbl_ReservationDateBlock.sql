--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_ReservationDateBlock
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
--Msg 50000, Level 16, State 1, Procedure trgtbl_ReservationDateBlock, Line 33 [Batch Start Line 1340]
  Data wymeldowania nie mo¿e byæ wczeœniejsza ni¿ obecna data.
  Msg 3609, Level 16, State 1, Line 1341
  The transaction ended in the trigger. The batch has been aborted.
--------------------------------------------------------------------------------------
*/

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
        RAISERROR('Data zameldowania nie mo¿e byæ póŸniejsza ni¿ data wymeldowania.', 16, 1);
		ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.CheckOutDate < GETDATE()
    )
    BEGIN
        RAISERROR('Data wymeldowania nie mo¿e byæ wczeœniejsza ni¿ obecna data.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.CheckInDate < CONVERT(DATE, GETDATE())
    )
    BEGIN
        RAISERROR('Data zameldowania nie mo¿e byæ wczeœniejsza ni¿ dzisiejsza data.', 16, 1);
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