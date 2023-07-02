--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_PaymentTypeEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s�ownikowej: payment.tbl_payment_type
--wywo�ywany podczas pr�by wstawiania, edycji lub usuwania rekord�w z tabeli
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM payment.tbl_payment_type
GO
--
--Wynik dzia�ania
--Dane nie zostan� usuni�te z tabeli
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