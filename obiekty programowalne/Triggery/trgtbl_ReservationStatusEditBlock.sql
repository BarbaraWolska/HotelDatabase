--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trg_ReservationStatusEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s�ownikowej: reservation.tbl_reservation_status
--wywo�ywany podczas pr�by wstawiania, edycji lub usuwania rekord�w z tabeli
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM reservation.tbl_reservation_status
GO
--
--Wynik dzia�ania
--Dane nie zostan� usuni�te z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trg_ReservationStatusEditBlock ON reservation.tbl_reservation_status
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO