--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_RoomTypeEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s�ownikowej: room.tbl_room_type
--wywo�ywany podczas pr�by wstawiania, edycji lub usuwania rekord�w z tabeli
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM room.tbl_room_type
GO
--
--Wynik dzia�ania
--Dane nie zostan� usuni�te z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trgtbl_RoomTypeEditBlock ON room.tbl_room_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RAISERROR('Edycja tabeli "tbl_room_type" jest niedozwolona.', 16, 1);
RETURN;
GO