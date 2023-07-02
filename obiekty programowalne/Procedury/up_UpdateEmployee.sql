----Procedura up_UpdateEmployee została utworzona lub zmodyfikowana w celu aktualizacji informacji o pracowniku na podstawie identyfikatora pracownika (@EmployeeId).
--parametry wejściowe:
--@EmployeeId (int): Przechowuje identyfikator pracownika, dla którego mają zostać zaktualizowane informacje.
--@FirstName (varchar(15)): Przechowuje nowe imię pracownika.
--@LastName (varchar(30)): Przechowuje nowe nazwisko pracownika.
--@EmployeePositionId (int): Przechowuje nowy identyfikator stanowiska pracownika.
--@DateOfEmployment (date): Przechowuje nową datę zatrudnienia pracownika.
--@HotelId (int): Przechowuje nowy identyfikator hotelu, w którym pracownik jest zatrudniony.
--@PeselNumber (varchar(11)): Przechowuje nowy numer PESEL pracownika.
CREATE OR ALTER PROCEDURE up_UpdateEmployee
(
    @EmployeeId INT,
    @FirstName VARCHAR(15),
    @LastName VARCHAR(30),
    @EmployeePositionId INT,
    @DateOfEmployment DATE,
    @HotelId INT,
    @PeselNumber VARCHAR(11)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE hotel.tbl_employees
        SET
            [Name] = @FirstName,
            LastName = @LastName,
            IdEmployeePosition = @EmployeePositionId,
            DateOfEmployment = @DateOfEmployment,
            IdHotel = @HotelId,
            PeselNumber = @PeselNumber
        WHERE
            IdEmployee = @EmployeeId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas aktualizowania pracownika: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia
EXEC up_UpdateEmployee
    @EmployeeId = 1,
    @FirstName = 'John',
    @LastName = 'Doe',
    @EmployeePositionId = 2,
    @DateOfEmployment = '2022-01-01',
    @HotelId = 3,
    @PeselNumber = '12345678901';
