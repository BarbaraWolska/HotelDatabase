exec sp_helptext uf_IsPeselOK
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- up_IsPeselOK (@pesel varchar(11))
--------------------------------------------------------------------------------------
--walidacja poprawnoœci numeru pesel
--wywo³ywana w trakcie dodawania nowego pracownika
--
--parametry wejœciowe:
--@pesel-numer pesel pracownika
--
--parametry wyjœciowe/zwracane wartoœci:
--wartoœæ=1 - pesel pracownika jest poprawny
--wartoœæ 0 - pesel pracownika niepoprawny
--
/*
--Przyk³ad u¿ycia
CREATE TABLE dbo.employees(
IdEmployee int NOT NULL IDENTITY(1,1) PRIMARY KEY,
IdPersonData int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_people_data(IdPersonData) ON UPDATE CASCADE,
[Name] varchar(15) NOT NULL, 
LastName varchar(30) NOT NULL, 
IdEmployeePosition int NOT NULL FOREIGN KEY REFERENCES employee.tbl_employee_position(IdEmployeePosition) ON UPDATE CASCADE,
DateOfEmployment date NOT NULL CHECK (DateOfEmployment <= GETDATE()), 
IdHotel int NOT NULL FOREIGN KEY REFERENCES hotel.tbl_hotels(IdHotel) ON UPDATE CASCADE,
Pesel varchar(11) NOT NULL CHECK (dbo.uf_IsPeselOK(Pesel) = 1)
)
GO
--
--Wynik dzia³ania
--Stworzona tabela pozwala tylko na wprowadzenie pracowników z poprawnym numerem pesel
--------------------------------------------------------------------------------------
*/

CREATE OR ALTER FUNCTION dbo.uf_IsPeselOK (@pesel varchar(11))
RETURNS tinyint
AS
BEGIN
    DECLARE @wagi AS TABLE (
        pozycja tinyint NOT NULL,
        waga tinyint NOT NULL)
    DECLARE @result tinyint = 0
    IF ISNUMERIC(@pesel) = 0
        RETURN @result
    INSERT INTO @wagi (pozycja, waga)
    VALUES (1, 1), (2, 3), (3, 7), (4, 9), (5, 1),
           (6, 3), (7, 7), (8, 9), (9, 1), (10, 3), (11, 1)

    IF (SELECT SUM(CAST(SUBSTRING(@pesel, pozycja, 1) AS tinyint) * waga) % 10
        FROM @wagi) = 0
    BEGIN
        SET @result = 1
    END
    RETURN @result
END
GO
