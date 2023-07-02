--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trgtbl_EmployeePositionEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s�ownikowej: Employee_Position
--wywo�ywany podczas pr�by wstawiania, edycji lub usuwania rekord�w z tabeli
--
--parametry wyj�ciowe/zwracane warto�ci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM [employee].[tbl_employee_position]
GO
--
--Wynik dzia�ania
--Dane nie zostan� usuni�te z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trgtbl_EmployeePositionEditBlock ON employee.tbl_employee_position
INSTEAD OF INSERT, UPDATE, DELETE
AS
RAISERROR ('Edycja tabeli employee.tbl_employee_position jest niedozwolona.', 16, 1);
RETURN;
GO