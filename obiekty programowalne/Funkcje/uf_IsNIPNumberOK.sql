exec sp_helptext uf_IsNIPNumberOK
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_IsNIPNumberOK (@NIPNumber varchar(10))
--------------------------------------------------------------------------------------
--walidacja poprawnoœci numeru NIP
--wywo³ywana w trakcie dodawania nowej faktury
--
--parametry wejœciowe:
--@NIPNumber - numer NIP firmy
--
--parametry wyjœciowe/zwracane wartoœci:
--wartoœæ=1 - numer NIP jest poprawny
--wartoœæ 0 - numer NIP niepoprawny
--
/*
CREATE TABLE hotel.tbl_billing(
IdBilling int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdGuest int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_guests(IdGuest) ON UPDATE CASCADE,
CompanyName varchar(30) NOT NULL, 
NIPNumber varchar(10) NOT NULL CHECK (dbo.uf_IsNIPNumberOK(NIPNumber) = 1), 
);
GO
--
--Wynik dzia³ania
--Stworzona tabela pozwala tylko na wprowadzenie faktur z poprawnym numerem NIP
--------------------------------------------------------------------------------------
*/

USE HotelDatabase;
GO
CREATE OR ALTER FUNCTION dbo.uf_IsNIPNumberOK (@NIPNumber varchar(10))
RETURNS tinyint
AS
BEGIN
    DECLARE @wagi AS TABLE (
        pozycja tinyint NOT NULL,
        waga tinyint NOT NULL)
    IF ISNUMERIC(@NIPNumber) = 0
        RETURN 0
    INSERT INTO @wagi (pozycja, waga)
    VALUES (1, 6), (2, 5), (3, 7), (4, 2), (5, 3),
           (6, 4), (7, 5), (8, 6), (9, 7)
    IF (SELECT SUM(CAST(SUBSTRING(@NIPNumber, pozycja, 1) AS tinyint) * waga) % 10
        FROM @wagi) <> CAST(SUBSTRING(@NIPNumber, 10, 1) AS tinyint)
        RETURN 0

    RETURN 1
END;
GO
