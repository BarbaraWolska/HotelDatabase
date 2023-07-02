--Procedura up_UpdateEmployeePositionByPesel została utworzona w celu aktualizacji stanowiska pracownika na podstawie numeru PESEL..
--parametry wejściowe:
--@PeselNumber (varchar(11)): Przechowuje numer PESEL pracownika, którego stanowisko ma zostać zaktualizowane.
--@NewPosition (varchar(100)): Przechowuje nazwę nowego stanowiska, na które ma zostać zaktualizowane.
CREATE PROCEDURE up_UpdateEmployeePositionByPesel
    @PeselNumber VARCHAR(11),
    @NewPosition VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE hotel.tbl_employees
        SET IdEmployeePosition = (
            SELECT IdEmployeePosition
            FROM HotelDatabase.employee.tbl_employee_position
            WHERE PositionName = @NewPosition
        )
        WHERE PeselNumber = @PeselNumber;

        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Stanowisko pracownika zostało zaktualizowane.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono pracownika o podanym numerze PESEL.';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas aktualizowania stanowiska pracownika: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia

EXEC up_UpdateEmployeePositionByPesel @PeselNumber = '58110187843', @NewPosition = 'Cook';
