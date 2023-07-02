----Procedura up_AddBilling zosta�a utworzona w celu dodania nowych rachunk�w

--parametry wej�ciowe:
--@TransactionId INT,
--@GuestId INT,
--@CompanyName VARCHAR(30),
--@NIPNumber VARCHAR(10),
--@SumOfBilling MONEY
CREATE PROCEDURE up_AddBilling
(
	@TransactionId INT,
    @GuestId INT,
    @CompanyName VARCHAR(30),
    @NIPNumber VARCHAR(10),
    @SumOfBilling MONEY
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO hotel.tbl_billing (IdTransaction, IdGuest, CompanyName, NIPNumber, SumOfBilling)
        VALUES (@TransactionId, @GuestId, @CompanyName, @NIPNumber, @SumOfBilling);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT  @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wyst�pi� b��d podczas dodawania faktury: %s', 16, 1, @ErrorMessage);
    END CATCH;
END

--Przyk�ad u�ycia
DECLARE @TransactionId INT;
DECLARE @GuestId INT;
DECLARE @CompanyName VARCHAR(30);
DECLARE @NIPNumber VARCHAR(10);
DECLARE @SumOfBilling MONEY;

-- Ustaw odpowiednie warto�ci dla parametr�w
SET @TransactionId = 1; -- Identyfikator transakcji powi�zanej z faktur�
SET @GuestId = 1; -- Identyfikator go�cia powi�zanego z faktur�
SET @CompanyName = 'Example Company'; -- Nazwa firmy na fakturze
SET @NIPNumber = '1234567890'; -- Numer NIP na fakturze
SET @SumOfBilling = 100.50; -- Suma faktury

-- Wywo�aj procedur�
EXEC up_AddBilling @TransactionId, @GuestId, @CompanyName, @NIPNumber, @SumOfBilling;
--wynki
Commands completed successfully.