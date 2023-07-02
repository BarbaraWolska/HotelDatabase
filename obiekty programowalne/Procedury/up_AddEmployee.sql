--Procedura up_AddEmployee została utworzona lub zmodyfikowana w celu dodania pracownika do bazy danych.--
--parametry wejściowe:
--@FirstName (varchar(15)): Przechowuje imię pracownika.
--@LastName (varchar(30)): Przechowuje nazwisko pracownika.
--@EmployeePosition (varchar(18)): Przechowuje stanowisko pracownika.
--@DateOfEmployment (date): Przechowuje datę zatrudnienia pracownika.
--@HotelId (int): Przechowuje identyfikator hotelu, w którym pracownik jest zatrudniony.
--@ZipCode (varchar(6)): Przechowuje kod pocztowy miejsca zamieszkania pracownika.
--@ApartmentNumber (varchar(4)): Przechowuje numer mieszkania pracownika.
--@NumberOfTheBuilding (varchar(6)): Przechowuje numer budynku pracownika.
--@Street (varchar(30)): Przechowuje nazwę ulicy, na której mieszka pracownik.
--@City (varchar(30)): Przechowuje nazwę miasta, w którym mieszka pracownik.
--@Country (varchar(30)): Przechowuje nazwę kraju, w którym mieszka pracownik.
--@DateOfBirth (date): Przechowuje datę urodzenia pracownika.
--@MobilePhoneNumber (varchar(11)): Przechowuje numer telefonu komórkowego pracownika.
--@Email (varchar(30)): Przechowuje adres e-mail pracownika.
--@PeselNumber (varchar(11)): Przechowuje numer PESEL pracownika.--
--
CREATE OR ALTER PROCEDURE up_AddEmployee
    @FirstName varchar(15),
    @LastName varchar(30),
    @EmployeePosition varchar(18),
    @DateOfEmployment date,
    @HotelId int,
    @ZipCode varchar(6),
    @ApartmentNumber varchar(4),
    @NumberOfTheBuilding varchar(6),
    @Street varchar(30),
    @City varchar(30),
    @Country varchar(30),
    @DateOfBirth date,
    @MobilePhoneNumber varchar(11),
    @Email varchar(30),
    @PeselNumber varchar(11)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @PersonDataId int;
        INSERT INTO hotel.tbl_people_data (ZipCode, ApartmentNumber, NumberOfTheBuilding, Street, City, Country, DateOfBirth, MobilelinePhoneNumber, Email)
        VALUES (@ZipCode, @ApartmentNumber, @NumberOfTheBuilding, @Street, @City, @Country, @DateOfBirth, @MobilePhoneNumber, @Email);
        SET @PersonDataId = SCOPE_IDENTITY();
        DECLARE @EmployeePositionId int;
        SELECT @EmployeePositionId = IdEmployeePosition FROM employee.tbl_employee_position WHERE PositionName = @EmployeePosition;
        INSERT INTO hotel.tbl_employees (IdPersonData, [Name], LastName, IdEmployeePosition, DateOfEmployment, IdHotel, PeselNumber)
        VALUES (@PersonDataId, @FirstName, @LastName, @EmployeePositionId, @DateOfEmployment, @HotelId, @PeselNumber);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

--Przykład użycia
EXECUTE up_AddEmployee
    @FirstName = 'John',
    @LastName = 'Doe',
    @EmployeePosition = 'Receptionist',
    @DateOfEmployment = '1976-11-12',
    @HotelId = 1,
    @ZipCode = '12-345',
    @ApartmentNumber = '12',
    @NumberOfTheBuilding = '45',
    @Street = 'Black Street',
    @City = 'Lodz',
    @Country = 'Poland',
    @DateOfBirth = '1985-01-01',
    @MobilePhoneNumber = '48777777777',
    @Email = 'example@example.com',
    @PeselNumber = '76111283795';
