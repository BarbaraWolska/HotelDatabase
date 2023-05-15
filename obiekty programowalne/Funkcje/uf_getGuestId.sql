exec sp_helptext uf_getGuestId
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_getGuestId (@id_billing int)
--------------------------------------------------------------------------------------
-- wyszukiwanie goœcia na podstawie numeru faktury
--
-- parametry wejœciowe:
-- @id_billing - numer faktury
--
--parametry wyjœciowe/zwracane wartoœci:
-- @id - numer goœcia
--
/*
use HotelDatabase
go
Select LastName from hotel.tbl_guests 
where IdGuest = uf_getGuestId (1) 
--
--Wynik dzia³ania
--Wynikiem dzia³ania jest 'Doe'
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_getGuestId(@id_billing int)
RETURNS int
BEGIN
DECLARE @id int
	SET @id = (SELECT [IdPersonData] 
	FROM [hotel].[tbl_billing] as b 
	INNER JOIN [hotel].[tbl_guests] as g 
	ON b.IdGuest = g.IdGuest 
	WHERE IdBilling=@id_billing) 
RETURN @id
END
GO
