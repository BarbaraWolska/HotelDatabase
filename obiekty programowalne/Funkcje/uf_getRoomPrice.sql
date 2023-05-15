exec sp_helptext uf_getRoomPrice
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_getRoomPrice(@id_room int)
--------------------------------------------------------------------------------------
--wyszukuje cen� pokoju na podstawie jego numeru
--
--parametry wej�ciowe:
--@id_room - numer pokoju
--
--parametry wyj�ciowe/zwracane warto�ci:
--money @price - cena wybranegp pokoju za jednodniowy pobyt
--
/*
Select [dbo].[uf_getRoomPrice](1);
--
--Wynik dzia�ania
--Cena pokoju pierwszego wynosi 100.00, poniewa� jest to pok�j typu 'Single Room'
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_getRoomPrice(@id_room int)
RETURNS money
BEGIN
DECLARE @price money
	SET @price =  (SELECT [RoomPrice] FROM [room].[tbl_room_type] as rt
	INNER JOIN [hotel].[tbl_rooms] as r
	ON rt.[IdRoomType] = r.[IdRoomType]
	WHERE r.[IdRoom] = @id_room)
RETURN @price
END
GO
