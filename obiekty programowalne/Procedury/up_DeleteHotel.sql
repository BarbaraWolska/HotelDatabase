----Procedura up_DeleteHotel została utworzona lub zmodyfikowana w celu usunięcia hotelu z bazy danych na podstawie nazwy hotelu (@HotelName). 
--parametry wejściowe:
--@HotelName (VARCHAR(100)): Przechowuje nazwę hotelu, który ma zostać usunięty.
CREATE OR ALTER PROCEDURE up_DeleteHotel
    @HotelName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM hotel.tbl_hotels
            WHERE HotelName = @HotelName
        )
        BEGIN
            RAISERROR('Nie znaleziono hotelu o podanej nazwie.', 16, 1);
            RETURN;
        END;
        DELETE FROM hotel.tbl_hotels
        WHERE HotelName = @HotelName;

        SELECT 'Hotel został pomyślnie usunięty.' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wystąpił błąd podczas usuwania hotelu: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia
EXEC up_DeleteHotel
    @HotelName = 'Hotel ABC';