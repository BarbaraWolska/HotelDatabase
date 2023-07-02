--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_RoomStatusEditdBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s�ownikowej: [room].[tbl_status]
--wywo�ywany podczas pr�by wstawiania, edycji lub usuwania rekord�w z tabeli
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM [room].[tbl_status]
GO
--
--Wynik dzia�ania
--Dane nie zostan� usuni�te z tabeli
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