--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_RoomTypeEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s³ownikowej: room.tbl_room_type
--wywo³ywany podczas próby wstawiania, edycji lub usuwania rekordów z tabeli
--
--parametry wyjœciowe/zwracane wartoœci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM room.tbl_room_type
GO
--
--Wynik dzia³ania
--Dane nie zostan¹ usuniête z tabeli
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