
exec sp_helptext uf_NumberOfGuestReservations
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_NumberOfGuestReservations (@NameOrLastName varchar(50))
--------------------------------------------------------------------------------------
-- wyszukiwanie liczby rezerwacji na podstawie fragmentu imienia lub nazwiska goœcia
--
-- parametry wejœciowe:
-- @NameOrLastName varchar(50) - fragment imienia lub nazwiska
--
--parametry wyjœciowe/zwracane wartoœci:
-- Zwraca tabelê wyników
--
/*
use HotelDatabase
go
Select uf_NumberOfGuestReservations('Doe')
--
--Wynik dzia³ania
--Wynikiem dzia³ania s¹ 2 wiersze, poniewa¿ w bazie znajduj¹ siê 2 osoby o nazwisku 'Doe'
--------------------------------------------------------------------------------------
*/ 

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_NumberOfGuestReservations
(@NameOrLastName varchar(50))
RETURNS TABLE
AS
RETURN(
SELECT p.Name, p.LastName, p.IdGuest, COUNT(r.IdReservation) AS NumberOfReservation 
FROM (SELECT g.Name, g.LastName, g.IdGuest, t.IdReservation
FROM [hotel].[tbl_guests] as g, [hotel].[tbl_transactions] as t
WHERE g.IdGuest = t.IdGuest) as p, [hotel].[tbl_reservations] as r
Where r.[IdReservation]=p.[IdReservation]
and LOWER(p.Name) + ' '+LOWER(p.LastName) LIKE LOWER('%'+@NameOrLastName+'%')
GROUP BY p.IdGuest, p.Name, p.LastName)
GO
