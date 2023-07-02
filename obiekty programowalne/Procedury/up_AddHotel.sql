----Procedura up_AddHotel została utworzona lub zmodyfikowana w celu dodania nowego hotelu do bazy danych.
--parametry wejściowe:
--@HotelName (VARCHAR(30)): Przechowuje nazwę hotelu.
--@CityName (VARCHAR(50)): Przechowuje nazwę miasta, w którym znajduje się hotel.
--@StreetAddress (VARCHAR(100)): Przechowuje adres ulicy hotelu.
--@PhoneNumber (VARCHAR(20)): Przechowuje numer telefonu hotelowego.
--@ZipCode (VARCHAR(6)): Przechowuje kod pocztowy hotelu.
--@NumberOfTheBuilding (VARCHAR(6)): Przechowuje numer budynku hotelowego.

CREATE OR ALTER PROCEDURE up_AddHotel
    @HotelName VARCHAR(30),
    @CityName VARCHAR(50),
    @StreetAddress VARCHAR(100),
    @PhoneNumber VARCHAR(20),
    @ZipCode VARCHAR(6),
    @NumberOfTheBuilding varchar(6)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO hotel.tbl_hotels (HotelName, City, Street, LandlinePhoneNumber, ZipCode, NumberOfTheBuilding)
        VALUES (@HotelName, @CityName, @StreetAddress, @PhoneNumber, @ZipCode, @NumberOfTheBuilding);

        SELECT 'Hotel added successfully.' AS Result;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH;
END;

--Przykład użycia
EXEC up_AddHotel
    @HotelName = 'Hotel ABC',
    @CityName = 'City XYZ',
    @StreetAddress = '123 Street',
    @PhoneNumber = '123-456-7890',
    @ZipCode = '12345',
	@NumberOfTheBuilding = 'A1';