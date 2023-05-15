
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

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_setRoomStatusReserved(@id_room int)
RETURNS bit
BEGIN
DECLARE @isRoomReserved bit, @CheckInDate date, @CheckOutDate date, @status varchar
	Select @CheckInDate = [CheckInDate], @CheckOutDate = [CheckOutDate] 
	from [hotel].[tbl_reservations]
	where [IdRoom]=@id_room

	select @status=[StatusName]
	from [reservation].[tbl_reservation_status] as s
	inner join [hotel].[tbl_reservations] as r
	on s.[IdReservationStatus]=r.[IdReservationStatus]
	where r.[IdRoom]=@id_room

	If @CheckInDate<GETDATE() and @CheckOutDate>GETDATE() and @status<>'Cancelled'
		set @isRoomReserved=1
	set @isRoomReserved=0

RETURN @isRoomReserved
END
GO
