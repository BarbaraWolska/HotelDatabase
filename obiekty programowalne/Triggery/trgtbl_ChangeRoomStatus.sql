--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_ChangeRoomStatus
--------------------------------------------------------------------------------------
--zmiana statusu pokoju
--wywo�ywany podczas dodawania lub edycji rekordu danych w tabeli tbl_reservations
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana statusu pokoju na wolny/zaj�ty
--
/*
INSERT INTO [hotel].[tbl_reservations]
           ([IdRoom]
           ,[CheckInDate]
           ,[CheckOutDate]
           ,[NumberOfGuests]
           ,[IdReservationStatus]
           ,[IdHotel])
     VALUES (1,'14.06.2023','17.06.2023', 2, 2, 1)
--
--Wynik dzia�ania
--Dane zostan� dodane do tabeli tbl_reservations, status pokoju o Id=1 zmieni si� na zaj�ty
--------------------------------------------------------------------------------------
*/
USE HotelDatabase;
GO

CREATE OR ALTER TRIGGER trgtbl_ChangeRoomStatus
ON hotel.tbl_reservations
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdReservationStatus int;
    DECLARE @ReservationStatus varchar(20);
    DECLARE @IdRoom int;

    SELECT TOP 1 @IdReservationStatus = i.IdReservationStatus,
                 @IdRoom = i.IdRoom
    FROM inserted i;

    SELECT @ReservationStatus = s.StatusName
    FROM reservation.tbl_reservation_status s
    WHERE s.IdReservationStatus = @IdReservationStatus;

    BEGIN TRY
        IF @ReservationStatus = 'Checked In'
        BEGIN
            UPDATE r
            SET r.IdRoomStatus = s.IdRoomStatus
            FROM hotel.tbl_rooms r
            JOIN room.tbl_status s ON r.IdRoomStatus = s.IdRoomStatus
            WHERE r.IdRoom = @IdRoom AND s.RoomStatusName = 'occupied';
        END
        ELSE IF @ReservationStatus = 'Checked Out'
        BEGIN
            UPDATE r
            SET r.IdRoomStatus = s.IdRoomStatus
            FROM hotel.tbl_rooms r
            JOIN room.tbl_status s ON r.IdRoomStatus = s.IdRoomStatus
            WHERE r.IdRoom = @IdRoom AND s.RoomStatusName = 'clean';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO
