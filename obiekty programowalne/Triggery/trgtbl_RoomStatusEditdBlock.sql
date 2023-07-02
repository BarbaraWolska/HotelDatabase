--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_RoomStatusEditdBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s³ownikowej: [room].[tbl_status]
--wywo³ywany podczas próby wstawiania, edycji lub usuwania rekordów z tabeli
--
--parametry wyjœciowe/zwracane wartoœci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM [room].[tbl_status]
GO
--
--Wynik dzia³ania
--Dane nie zostan¹ usuniête z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trgtbl_RoomStatusEditdBlock ON room.tbl_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RAISERROR('Edycja tabeli "tbl_status" jest niedozwolona.', 16, 1);
RETURN;
GO