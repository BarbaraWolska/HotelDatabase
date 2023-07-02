
exec sp_helptext uf_NumberOfGuestReservations
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_NumberOfGuestReservations (@NameOrLastName varchar(50))
--------------------------------------------------------------------------------------
-- wyszukiwanie liczby rezerwacji na podstawie fragmentu imienia lub nazwiska go�cia
--
-- parametry wej�ciowe:
-- @NameOrLastName varchar(50) - fragment imienia lub nazwiska
--
--parametry wyj�ciowe/zwracane warto�ci:
-- Zwraca tabel� wynik�w
--
/*
use HotelDatabase
go
Select uf_NumberOfGuestReservations('Doe')
--
--Wynik dzia�ania
--Wynikiem dzia�ania s� 2 wiersze, poniewa� w bazie znajduj� si� 2 osoby o nazwisku 'Doe'
--------------------------------------------------------------------------------------
*/ 

USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION uf_NumberOfGuestReservations(@NameOrLastName varchar(50))
RETURNS TABLE
AS
    RETURN (
            SELECT p.Name, p.LastName, p.IdGuest, COUNT(r.IdReservation) AS NumberOfReservation
            FROM (
                SELECT g.Name, g.LastName, g.IdGuest, t.IdReservation
                FROM [hotel].[tbl_guests] AS g
                INNER JOIN [hotel].[tbl_transactions] AS t ON g.IdGuest = t.IdGuest
            ) AS p
            INNER JOIN [hotel].[tbl_reservations] AS r ON r.[IdReservation] = p.[IdReservation]
            WHERE LOWER(p.Name) + ' ' + LOWER(p.LastName) LIKE LOWER('%' + @NameOrLastName + '%')
            GROUP BY p.IdGuest, p.Name, p.LastName
    )
GO
