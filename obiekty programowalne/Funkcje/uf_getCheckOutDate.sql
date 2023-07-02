exec sp_helptext uf_getCheckOutDate
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_getCheckOutDate (@id_reservation int)
--------------------------------------------------------------------------------------
-- wyszukiwanie daty wymeldowania na podstawie numeru rezerwacji
--
-- parametry wej�ciowe:
-- @id_reservation - numer rezerwacji
--
--parametry wyj�ciowe/zwracane warto�ci:
-- @CheckOutDate - data wymeldowania
--
/*
use HotelDatabase
go
Select dbo.uf_getCheckOutDate(1)
--
--Wynik dzia�ania
--Wynikiem dzia�ania jest data wymeldowania przypisana do pierwszej rezerwacji: '2023-04-05'
--------------------------------------------------------------------------------------
*/

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