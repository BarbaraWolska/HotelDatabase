--------------------------------------------------------------------------------------
--- TRIGGER DEFINITION
--- trg_EmployeePositionEditBlock
--------------------------------------------------------------------------------------
--blokowanie edycji tabeli s³ownikowej: Employee_Position
--wywo³ywany podczas próby wstawiania, edycji lub usuwania rekordów z tabeli
--
--parametry wyjœciowe/zwracane wartoœci:
--zmiana nie zostanie wprowadzona
--
/*
USE [HotelDatabase]
GO

DELETE FROM [employee].[tbl_employee_position]
GO
--
--Wynik dzia³ania
--Dane nie zostan¹ usuniête z tabeli
--------------------------------------------------------------------------------------
*/

use HotelDatabase
go
CREATE TRIGGER trg_EmployeePositionEditBlock ON employee.tbl_employee_position
INSTEAD OF INSERT, UPDATE, DELETE
AS
RETURN;
GO