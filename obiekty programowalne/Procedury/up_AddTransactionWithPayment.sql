----Procedura up_AddTransactionWithPayment zosta�a utworzona w celu dodania nowych transkacji

--parametry wej�ciowe:
--@ReservationId INT,
--@EmployeeId INT,
--@GuestId INT,
--@HotelId INT,
--@TransactionDate DATE,
--@PaymentTypeId INT,
--@PaymentDate DATE
CREATE OR ALTER PROCEDURE up_AddTransactionWithPayment
(
    @ReservationId INT,
    @EmployeeId INT,
    @GuestId INT,
    @HotelId INT,
    @TransactionDate DATE,
    @PaymentTypeId INT,
    @PaymentDate DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @PaymentId INT;

        -- Dodaj now� p�atno��
        INSERT INTO hotel.tbl_payments (IdPaymentType, PaymentDate)
        VALUES (@PaymentTypeId, @PaymentDate);

        -- Pobierz identyfikator dodanej p�atno�ci
        SET @PaymentId = SCOPE_IDENTITY();

        -- Dodaj now� transakcj� z powi�zan� p�atno�ci�
        INSERT INTO hotel.tbl_transactions (IdReservation, IdPayment, IdEmployee, IdGuest, IdHotel, TransactionDate)
        VALUES (@ReservationId, @PaymentId, @EmployeeId, @GuestId, @HotelId, @TransactionDate);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wyst�pi� b��d podczas dodawania transakcji: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

----Przyk�ad u�ycia
DECLARE @ReservationId INT;
DECLARE @EmployeeId INT;
DECLARE @GuestId INT;
DECLARE @HotelId INT;
DECLARE @TransactionDate DATE;
DECLARE @PaymentTypeId INT;
DECLARE @PaymentDate DATE;

-- Ustaw odpowiednie warto�ci dla parametr�w
SET @ReservationId = 13;
SET @EmployeeId = 1;
SET @GuestId = 1;
SET @HotelId = 1;
SET @TransactionDate = GETDATE();
SET @PaymentTypeId = 1; -- Identyfikator typu p�atno�ci
SET @PaymentDate = GETDATE();

-- Wywo�aj procedur�
EXEC up_AddTransactionWithPayment @ReservationId, @EmployeeId, @GuestId, @HotelId, @TransactionDate, @PaymentTypeId, @PaymentDate;

----Wynik 
Commands completed successfully.