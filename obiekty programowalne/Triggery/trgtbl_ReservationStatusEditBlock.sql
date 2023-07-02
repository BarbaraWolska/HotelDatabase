--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_ReservationStatusEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s³ownikowej: reservation.tbl_reservation_status
--wywo³ywany podczas próby wstawiania, edycji lub usuwania rekordów z tabeli
--
--parametry wyjœciowe/zwracane wartoœci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM reservation.tbl_reservation_status
GO
--
--Wynik dzia³ania
--Dane nie zostan¹ usuniête z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trgtbl_ReservationStatusEditBlock ON reservation.tbl_reservation_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RAISERROR('Edycja tabeli "tbl_reservation_status" jest niedozwolona.', 16, 1);
RETURN;
GO