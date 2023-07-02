exec sp_helptext uf_getCheckInDate
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_getCheckInDate (@id_reservation int)
--------------------------------------------------------------------------------------
-- wyszukiwanie daty zameldowania na podstawie numeru rezerwacji
--
-- parametry wejœciowe:
-- @id_reservation - numer rezerwacji
--
--parametry wyjœciowe/zwracane wartoœci:
-- @CheckInDate - data zameldowania
--
/*
use HotelDatabase
go
Select dbo.uf_getCheckInDate(1)
--
--Wynik dzia³ania
--Wynikiem dzia³ania jest data zameldowania przypisana do pierwszej rezerwacji '2023-04-01'
--------------------------------------------------------------------------------------
*/

USE HotelDatabase;
GO
CREATE FUNCTION uf_getCheckInDate(@id_reservation int)
RETURNS date
BEGIN
    DECLARE @CheckInDate date;
	IF EXISTS (SELECT 1 FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
	    BEGIN
			SET @CheckInDate = (SELECT CheckInDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation);
		END
	else BEGIN 
			SET @CheckInDate = NULL;
		END;

    RETURN @CheckInDate;
END;
GO



