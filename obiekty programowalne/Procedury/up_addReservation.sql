----Procedura up_addReservation zosta�a utworzona w celu dodania nowych rezerwacji

--parametry wej�ciowe:
--@IdRoom INT,
--@CheckInDate DATE,
--@CheckOutDate DATE,
--@NumberOfGuests VARCHAR(3),
--@IdReservationStatus INT,
--@IdHotel INT
USE HotelDatabase;
GO
CREATE OR ALTER PROCEDURE up_addReservation
(
    @IdRoom INT,
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @NumberOfGuests VARCHAR(3),
    @IdReservationStatus INT,
    @IdHotel INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Sprawd� czy pok�j jest dost�pny w wybranym okresie
        IF EXISTS (
            SELECT 1
            FROM hotel.tbl_reservations
            WHERE IdRoom = @IdRoom
            AND (
                (CheckInDate >= @CheckInDate AND CheckInDate < @CheckOutDate)
                OR (CheckOutDate > @CheckInDate AND CheckOutDate <= @CheckOutDate)
                OR (CheckInDate < @CheckInDate AND CheckOutDate > @CheckOutDate)
            )
        )
        BEGIN
            RAISERROR('Ten pok�j jest zarezerwowany.', 16, 1);
            RETURN;
        END;

        -- Dodaj now� rezerwacj� i zwr�� pe�ne informacje o wstawionym wierszu
        INSERT INTO hotel.tbl_reservations (IdRoom, CheckInDate, CheckOutDate, NumberOfGuests, IdReservationStatus, IdHotel)
        OUTPUT inserted.*
        VALUES (@IdRoom, @CheckInDate, @CheckOutDate, @NumberOfGuests, @IdReservationStatus, @IdHotel);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wyst�pi� b��d podczas dodawania rezerwacji: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

-----Przyk�ad u�ycia
DECLARE @NewReservationId INT;

EXEC hotel.up_addReservation
    @IdRoom = 4,
    @CheckInDate = '2023-06-15',
    @CheckOutDate = '2023-06-20',
    @NumberOfGuests = '2',
    @IdReservationStatus = 1,
    @IdHotel = 1;

SELECT * FROM hotel.tbl_reservations WHERE IdReservation = @NewReservationId;
--Wynik
Wy�wietla dane dodane jako nowa rezerwacja