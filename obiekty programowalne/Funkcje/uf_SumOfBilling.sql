exec sp_helptext uf_SumOfBilling
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_SumOfBilling (@id_transaction int)
--------------------------------------------------------------------------------------
-- obliczanie ��cznej kwoty faktury na podstawie numeru transakcji
-- wykorzystuje funkcje uf_LengthOfTheVisit i uf_getRoomPrice do wyznaczenia liczby dni rezerwacji i ceny pokoju 
--
-- parametry wej�ciowe:
-- @id_transaction - numer transakcji
--
--parametry wyj�ciowe/zwracane warto�ci:
-- @SumOfBilling - ��czna kwota faktury
--
/*
use HotelDatabase
go
Select uf_SumOfBilling (1)
--
--Wynik dzia�ania
--Wynikiem dzia�ania jest 400, poniewa� cena za dzie� w pokoju 1 wynosi 100, a rezerwacji dokonano na 4 dni
--------------------------------------------------------------------------------------
*/   

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SumOfBilling(@id_transaction int)
RETURNS money
BEGIN
    DECLARE @SumOfBilling money = 0
    
    SELECT @SumOfBilling +=[dbo].[uf_LengthOfTheVisit](r.IdReservation) * [dbo].[uf_getRoomPrice](r.IdRoom)
    FROM [hotel].[tbl_transactions] AS t
    JOIN [hotel].[tbl_reservations] AS r ON t.IdReservation = r.IdReservation
    WHERE t.IdTransaction = @id_transaction
    
    RETURN @SumOfBilling
END
