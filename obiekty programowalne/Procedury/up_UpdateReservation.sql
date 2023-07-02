----Procedura up_UpdateReservation zosta³a utworzona w celu dodania nowych transkacji

--parametry wejœciowe:
--@IdReservation INT,
--@CheckInDate DATE,
--@CheckOutDate DATE,
--@NumberOfGuests VARCHAR(3)
CREATE PROCEDURE up_UpdateReservation
    @IdReservation INT,
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @NumberOfGuests VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE hotel.tbl_reservations
        SET CheckInDate = @CheckInDate,
            CheckOutDate = @CheckOutDate,
            NumberOfGuests = @NumberOfGuests
        WHERE IdReservation = @IdReservation;
        
        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Rezerwacja zosta³a zaktualizowana.';
        END
        ELSE
        BEGIN
            PRINT 'Nie znaleziono rezerwacji o podanym identyfikatorze.';
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wyst¹pi³ b³¹d podczas aktualizowania rezerwacji: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;


----Przyk³ad u¿ycia
EXEC up_UpdateReservation
    @IdReservation = 1,
    @CheckInDate = '2023-06-20',
    @CheckOutDate = '2023-06-25',
    @NumberOfGuests = '2';

----Wynik 
Commands completed successfully.