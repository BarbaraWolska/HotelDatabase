--Procedura up_AddGuest została utworzona lub zmodyfikowana w celu dodania gościa do bazy danych.
--parametry wejściowe:
--@Name (varchar(15)): Przechowuje imię gościa.
--@LastName (varchar(30)): Przechowuje nazwisko gościa.
--@IDNumber (varchar(9)): Przechowuje numer dowodu tożsamości gościa.
--@PassportNumber (varchar(9)): Przechowuje numer paszportu gościa.
--@ZipCode (varchar(6)): Przechowuje kod pocztowy miejsca zamieszkania gościa.
--@ApartmentNumber (varchar(4)): Przechowuje numer mieszkania gościa.
--@NumberOfTheBuilding (varchar(6)): Przechowuje numer budynku gościa.
--@Street (varchar(30)): Przechowuje nazwę ulicy, na której mieszka gość.
--@City (varchar(30)): Przechowuje nazwę miasta, w którym mieszka gość.
--@Country (varchar(30)): Przechowuje nazwę kraju, w którym mieszka gość.
--@DateOfBirth (date): Przechowuje datę urodzenia gościa.
--@MobilelinePhoneNumber (varchar(11)): Przechowuje numer telefonu komórkowego gościa.
--@Email (varchar(30)): Przechowuje adres e-mail gościa.--
USE HotelDatabase
GO
CREATE OR ALTER PROCEDURE up_AddGuest
(
    @Name varchar(15),
    @LastName varchar(30),
    @IDNumber varchar(9),
    @PassportNumber varchar(9),
    @ZipCode varchar(6),
    @ApartmentNumber varchar(4),
    @NumberOfTheBuilding varchar(6),
    @Street varchar(30),
    @City varchar(30),
    @Country varchar(30),
    @DateOfBirth date,
    @MobilelinePhoneNumber varchar(11),
    @Email varchar(30)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdPersonData int;
        INSERT INTO hotel.tbl_people_data (ZipCode, ApartmentNumber, NumberOfTheBuilding, Street, City, Country, DateOfBirth, MobilelinePhoneNumber, Email)
        VALUES (@ZipCode, @ApartmentNumber, @NumberOfTheBuilding, @Street, @City, @Country, @DateOfBirth, @MobilelinePhoneNumber, @Email);
        SET @IdPersonData = SCOPE_IDENTITY();
        INSERT INTO hotel.tbl_guests (IdPersonData, [Name], LastName, IDNumber, PassportNumber)
        VALUES (@IdPersonData, @Name, @LastName, @IDNumber, @PassportNumber);
        SELECT 'Guest added successfully.' AS Result;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END
GO

--Przykad użycia
EXEC up_AddGuest
    @Name = 'Jakub',
    @LastName = 'Kowalski',
    @IDNumber = 'CDE123456',
    @PassportNumber = 'EI8123484',
    @ZipCode = '00-123',
    @ApartmentNumber = '5A',
    @NumberOfTheBuilding = '10',
    @Street = 'Main Street',
    @City = 'Warsaw',
    @Country = 'Poland',
    @DateOfBirth = '1990-01-01',
    @MobilelinePhoneNumber = '48500123456',
    @Email = 'john.doe@example.com';

