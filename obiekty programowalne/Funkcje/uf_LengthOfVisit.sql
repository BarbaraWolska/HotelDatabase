
exec sp_helptext uf_LengthOfVisit
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_LengthOfVisit (@id_Reservation int)
--------------------------------------------------------------------------------------
-- obliczanie d�ugo�ci pobytu na podstawie dat zameldowania i wymeldowania dla podanego numeru rezerwacji
--
-- parametry wej�ciowe:
-- @id_Reservation - numer rezerwacji
--
--parametry wyj�ciowe/zwracane warto�ci:
-- @days - liczba dni
--
/*
use HotelDatabase
go
Select uf_LengthOfVisit (1)
--
--Wynik dzia�ania
--Wynikiem dzia�ania jest 'Doe'
--------------------------------------------------------------------------------------
*/   

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_LengthOfTheVisit(@id_Reservation int)
Returns int
BEGIN
DECLARE @days int, @CheckInDate date, @CheckOutDate date
	
SELECT @CheckInDate = r.CheckInDate, @CheckOutDate = r.CheckOutDate
FROM [hotel].[tbl_reservations] AS r
JOIN [hotel].[tbl_transactions] AS t ON r.IdReservation = t.IdReservation
WHERE r.IdReservation = @id_Reservation

SET @days = DATEDIFF(day,@CheckInDate,@CheckOutDate)
	
RETURN @days
END
GO
