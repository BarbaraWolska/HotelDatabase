----Procedura up_AddTransactionWithPayment zosta³a utworzona w celu dodania nowych transkacji

--parametry wejœciowe:
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

        -- Dodaj now¹ p³atnoœæ
        INSERT INTO hotel.tbl_payments (IdPaymentType, PaymentDate)
        VALUES (@PaymentTypeId, @PaymentDate);

        -- Pobierz identyfikator dodanej p³atnoœci
        SET @PaymentId = SCOPE_IDENTITY();

        -- Dodaj now¹ transakcjê z powi¹zan¹ p³atnoœci¹
        INSERT INTO hotel.tbl_transactions (IdReservation, IdPayment, IdEmployee, IdGuest, IdHotel, TransactionDate)
        VALUES (@ReservationId, @PaymentId, @EmployeeId, @GuestId, @HotelId, @TransactionDate);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wyst¹pi³ b³¹d podczas dodawania transakcji: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

----Przyk³ad u¿ycia
DECLARE @ReservationId INT;
DECLARE @EmployeeId INT;
DECLARE @GuestId INT;
DECLARE @HotelId INT;
DECLARE @TransactionDate DATE;
DECLARE @PaymentTypeId INT;
DECLARE @PaymentDate DATE;

-- Ustaw odpowiednie wartoœci dla parametrów
SET @ReservationId = 13;
SET @EmployeeId = 1;
SET @GuestId = 1;
SET @HotelId = 1;
SET @TransactionDate = GETDATE();
SET @PaymentTypeId = 1; -- Identyfikator typu p³atnoœci
SET @PaymentDate = GETDATE();

-- Wywo³aj procedurê
EXEC up_AddTransactionWithPayment @ReservationId, @EmployeeId, @GuestId, @HotelId, @TransactionDate, @PaymentTypeId, @PaymentDate;

----Wynik 
Commands completed successfully.