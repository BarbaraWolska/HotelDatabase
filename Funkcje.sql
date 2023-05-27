
use HotelDatabase
go
CREATE OR ALTER FUNCTION dbo.uf_IsPeselOK(

IF ISNUMERIC(@pesel) = 0 RETURN 0
INSERT INTO @wagi(pozycja,waga)
VALUES (1,1),(2,3),(3,7),(4,9),(5,1),
       (6,3),(7,7),(8,9),(9,1),(10,3),(11,1)
IF (SELECT SUM(CAST(SUBSTRING(@pesel, pozycja, 1) AS tinyint) * waga) % 10
      FROM @wagi) <> 0
   RETURN 0
RETURN 1
END
GO


VALUES (1,6),(2,5),(3,7),(4,2),(5,3),
       (6,4),(7,5),(8,6),(9,7)
IF (SELECT SUM(CAST(SUBSTRING(@NIPNumber, pozycja, 1) AS tinyint) * waga) % 10
      FROM @wagi) <> SUBSTRING(@NIPNumber,10,1)
   RETURN 0
RETURN 1
END
GO 

--wyszukiwanie goœci po imieniu lub nazwisku
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SearchGuestByNameOrLastName(@NameOrSurname varchar(60))
RETURNS TABLE
AS
RETURN(


go
CREATE OR ALTER FUNCTION uf_IsRoomFree(@id_room int)
RETURNS bit
BEGIN
	DECLARE @is_free bit, @CheckInDate date, @CheckOutDate date, @status varchar
	SELECT @CheckInDate=r.[CheckInDate], @CheckOutDate=r.CheckOutDate, @status=s.StatusName 
	FROM [hotel].[tbl_reservations] as r 
	INNER JOIN [reservation].[tbl_reservation_status] as s 
	ON r.[IdReservationStatus]=s.IdReservationStatus 
	WHERE r.[IdRoom]=@id_room
	
	IF (@status <> 'Cancelled' and @CheckOutDate<=GETDATE() and @CheckInDate>=GETDATE())
		SET @is_free = 0
	ELSE
		SET @is_free=1
RETURN @is_free
END

ation) AS NumberOfReservation 
FROM (SELECT g.Name, g.LastName, g.IdGuest, t.IdReservation
FROM [hotel].[tbl_guests] as g, [hotel].[tbl_transactions] as t
WHERE g.IdGuest = t.IdGuest) as p, [hotel].[tbl_reservations] as r
Where r.[IdReservation]=p.[IdReservation]
and LOWER(p.Name) + ' '+LOWER(p.LastName) LIKE LOWER('%'+@NameOrLastName+'%')
GROUP BY p.IdGuest, p.Name, p.LastName)
GO

--wydobywanie ceny danego pokoju
use HotelDatabase
go

GO

--numer goœcia na podstawie numeru faktury
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_getGuestId(@id_billing int)
RETURNS int
BEGIN
DECLARE @id int
	SET @id = (SELECT [IdPersonData] 
	FROM [hotel].[tbl_billing] as b 
	INNER JOIN [hotel].[tbl_guests] as g 
	ON b.IdGuest = g.IdGuest 
	WHERE IdBilling=@id_billing) 
RETURN @id
END
=
END
GO


--data zameldowania na podstawie numeru rezerwacji
use HotelDatabase
go
CREATE FUNCTION uf_getCheckInDate(@id_reservation int)
RETURNS date
BEGIN

BEGIN
DECLARE @days int, @CheckInDate date, @CheckOutDate date
	
SELECT @CheckInDate = r.CheckInDate, @CheckOutDate = r.CheckOutDate
FROM [hotel].[tbl_reservations] AS r
JOIN [hotel].[tbl_transactions] AS t ON r.IdReservation = t.IdReservation
WHERE r.IdReservation = @id_Reservation

SET @days = DATEDIFF(day,@CheckInDate,@CheckOutDate)
	
RETURN @days
END
GO

--zmiana statusu pokoju na zarezerwowany
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_setRoomStatusReserved(@id_room int)
RETURNS bit

	from [reservation].[tbl_reservation_status] as s
	inner join [hotel].[tbl_reservations] as r
	on s.[IdReservationStatus]=r.[IdReservationStatus]
	where r.[IdRoom]=@id_room

	If @CheckInDate<GETDATE() and @CheckOutDate>GETDATE() and @status<>'Cancelled'
		set @isRoomReserved=1
	set @isRoomReserved=0

RETURN @isRoomReserved
END
GO

--obliczanie ³¹cznej kwoty faktury
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SumOfBilling(@id_transaction int)
sit](r.IdReservation) * [dbo].[uf_getRoomPrice](r.IdRoom)
    FROM [hotel].[tbl_transactions] AS t
    JOIN [hotel].[tbl_reservations] AS r ON t.IdReservation = r.IdReservation
    WHERE t.IdTransaction = @id_transaction
    
    RETURN @SumOfBilling
END

