CREATE OR ALTER TRIGGER trgtbl_SetSumOfBilling
ON hotel.tbl_billing
AFTER INSERT, UPDATE
AS
BEGIN
  UPDATE hotel.tbl_billing
  SET SumOfBilling = dbo.uf_SumOfBilling(i.IdTransaction)
  FROM (SELECT IdBilling, IdTransaction FROM inserted UNION SELECT IdBilling, IdTransaction FROM updated) i
  WHERE hotel.tbl_billing.IdBilling = i.IdBilling;
END
