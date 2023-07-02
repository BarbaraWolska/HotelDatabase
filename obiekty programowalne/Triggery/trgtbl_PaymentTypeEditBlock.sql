--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_PaymentTypeEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s³ownikowej: payment.tbl_payment_type
--wywo³ywany podczas próby wstawiania, edycji lub usuwania rekordów z tabeli
--
--parametry wyjœciowe/zwracane wartoœci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM payment.tbl_payment_type
GO
--
--Wynik dzia³ania
--Dane nie zostan¹ usuniête z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trgtbl_PaymentTypeEditBlock ON payment.tbl_payment_type
INSTEAD OF INSERT, UPDATE, DELETE
AS
RAISERROR ('Edycja tabeli payment.tbl_payment_type jest niedozwolona.', 16, 1);
RETURN;
GO