--Procedura up_DeleteGuestByPassport została utworzona w celu usunięcia gościa z bazy danych na podstawie numeru paszportowego.
--parametry wejściowe:
--@PassportNumber (varchar(20)): Przechowuje numer paszportu gościa, który ma zostać usunięty.--/*
CREATE PROCEDURE up_DeleteGuestByPassport
    @PassportNumber VARCHAR(20)
AS
CREATE OR ALTER PROCEDURE up_DeleteGuest
    @PassportNumber VARCHAR(9)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Sprawdź, czy gość istnieje na podstawie numeru paszportowego
        DECLARE @GuestId INT;

        SELECT @GuestId = IdGuest
        FROM hotel.tbl_guests
        WHERE PassportNumber = @PassportNumber;
        IF @GuestId IS NOT NULL
        BEGIN
            -- Usuń powiązane wpisy z tabeli hotel.tbl_billing
            DELETE FROM hotel.tbl_billing
            WHERE IdGuest = @GuestId;
            -- Usuń gościa z tabeli hotel.tbl_guests
            DELETE FROM hotel.tbl_guests
            WHERE IdGuest = @GuestId;

            SELECT 'Gość został pomyślnie usunięty.' AS Result;
        END
        ELSE
        BEGIN
            RAISERROR('Nie znaleziono gościa o podanym numerze paszportowym.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas usuwania gościa: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia
EXEC up_DeleteGuestByPassport @PassportNumber = 'AB1234567';