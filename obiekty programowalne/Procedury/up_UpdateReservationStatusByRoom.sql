--Procedura up_UpdateReservationStatusByRoom została utworzona w celu aktualizacji statusu rezerwacji dla pokoju na podstawie numeru pokoju...
--parametry wejściowe:
--@RoomNumber (int): Przechowuje numer pokoju, dla którego ma zostać zaktualizowany status rezerwacji.
--@NewStatusName (varchar(100)): Przechowuje nazwę nowego statusu rezerwacji, na który ma zostać zaktualizowany.
--Zwrócono wartość: Commands completed successfully.

CREATE PROCEDURE up_UpdateReservationStatusByRoom
    @RoomNumber INT,
    @NewStatusName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [HotelDatabase].[hotel].[tbl_reservations]
        SET IdReservationStatus = (SELECT IdReservationStatus FROM [HotelDatabase].[reservation].[tbl_reservation_status] WHERE StatusName = @NewStatusName)
        WHERE IdRoom IN (SELECT IdRoom FROM [HotelDatabase].[hotel].[tbl_rooms] WHERE RoomNumber = @RoomNumber);

        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Status rezerwacji został zaktualizowany dla pokoju o numerze ' + CAST(@RoomNumber AS VARCHAR(10)) + '.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono rezerwacji dla pokoju o numerze ' + CAST(@RoomNumber AS VARCHAR(10)) + '.';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();
        RAISERROR('Wystąpił błąd podczas aktualizowania statusu rezerwacji: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia

EXEC up_UpdateReservationStatusByRoom @RoomNumber = 101, @NewStatusName = 'Confirmed';
