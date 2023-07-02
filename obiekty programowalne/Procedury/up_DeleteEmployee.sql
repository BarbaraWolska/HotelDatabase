----Procedura up_DeleteEmployee została utworzona w celu usunięcia pracownika z bazy danych na podstawie identyfikatora pracownika (@EmployeeId).
--parametry wejściowe:
--@EmployeeId (int): Przechowuje identyfikator pracownika, który ma zostać usunięty.

CREATE OR ALTER PROCEDURE up_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Usunięcie powiązanych rekordów w tabeli tbl_transactions
        DELETE FROM hotel.tbl_transactions
        WHERE IdEmployee = @EmployeeId;

        -- Usunięcie powiązanych rekordów w tabeli tbl_guests
        DELETE FROM hotel.tbl_guests
        WHERE IdPersonData = (SELECT IdPersonData FROM hotel.tbl_employees WHERE hotel.tbl_employees.IdEmployee = @EmployeeId);

        -- Usunięcie pracownika z tabeli tbl_employees
        DELETE FROM hotel.tbl_employees
        WHERE hotel.tbl_employees.IdEmployee = @EmployeeId;

        -- Usunięcie danych osobowych pracownika z tabeli tbl_people_data
        DELETE FROM hotel.tbl_people_data
        WHERE IdPersonData = (SELECT IdPersonData FROM hotel.tbl_employees WHERE hotel.tbl_employees.IdEmployee = @EmployeeId);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas usuwania pracownika: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia
EXEC up_DeleteEmployee
    @EmployeeId = 123;