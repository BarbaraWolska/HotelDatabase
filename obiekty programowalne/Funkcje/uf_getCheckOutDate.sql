exec sp_helptext uf_getCheckOutDate
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_getCheckOutDate (@id_reservation int)
--------------------------------------------------------------------------------------
-- wyszukiwanie daty wymeldowania na podstawie numeru rezerwacji
--
-- parametry wejœciowe:
-- @id_reservation - numer rezerwacji
--
--parametry wyjœciowe/zwracane wartoœci:
-- @CheckOutDate - data wymeldowania
--
/*
use HotelDatabase
go
Select dbo.uf_getCheckOutDate(1)
--
--Wynik dzia³ania
--Wynikiem dzia³ania jest data wymeldowania przypisana do pierwszej rezerwacji: '2023-04-05'
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_getCheckOutDate(@id_reservation int)
RETURNS date
BEGIN
DECLARE @CheckOutDate date
	SET @CheckOutDate = (SELECT CheckOutDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
	RETURN @CheckOutDate
END
GO
