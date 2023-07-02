
exec sp_helptext uf_setRoomStatusReserved
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_setRoomStatusReserved (@id_room int)
--------------------------------------------------------------------------------------
-- ustawia status pokoju na 'Reserved' je¿eli data dzisiejsza mieœci siê w ramach dokonanej rezerwacji
-- funkcja nie uwzglêdnia rezerwacji anulowanych (status rezerwacji 'Cancelled')
--
-- parametry wejœciowe:
-- @id_room - numer pokoju
--
--parametry wyjœciowe/zwracane wartoœci:
-- @isRoomReserved 
-- 1 - pokój zarezerwowany
-- 0 - pokój niezarezerwowany
/*
use HotelDatabase
go
Select uf_setRoomStatusReserved (1)
--
--Wynik dzia³ania
--Wynikiem dzia³ania jest 0, poniewa¿ dzisiejsza data nie mieœci siê w przedziale dat na któr¹ zosta³a dokonana jedyna rezerwacja
--------------------------------------------------------------------------------------
*/   

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