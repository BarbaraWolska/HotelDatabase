
exec sp_helptext uf_IsRoomFree
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_IsRoomFree (@id_room int)
--------------------------------------------------------------------------------------
-- weryfikacja statusu pokoju o podanym numerze 
--
-- parametry wej�ciowe:
-- @id_room - numer pokoju
--
--parametry wyj�ciowe/zwracane warto�ci:
-- @Is_free
-- 1 - pok�j jest wolny/dost�pny do rezerwacji
-- 0 - pok�j zaj�ty/niedost�pny
--
/*
use HotelDatabase
go
Select uf_IsRoomFree (1)
--
--Wynik dzia�ania
--Wynikiem dzia�ania jest 
--------------------------------------------------------------------------------------
*/   

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