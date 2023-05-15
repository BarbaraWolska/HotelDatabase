
--walidacja numeru pesel
use HotelDatabase
go
CREATE OR ALTER FUNCTION dbo.uf_IsPeselOK(
@pesel varchar(11)
)
RETURNS tinyint
AS
BEGIN
DECLARE @wagi AS TABLE(pozycja tinyint NOT NULL,
                       waga tinyint NOT NULL)
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

--walidacja numeru NIP
use HotelDatabase
go
CREATE OR ALTER FUNCTION dbo.uf_IsNIPNumberOK(
@NIPNumber varchar(10)
)
RETURNS tinyint
AS
BEGIN
DECLARE @wagi AS TABLE(pozycja tinyint NOT NULL,
                       waga tinyint NOT NULL)
IF ISNUMERIC(@NIPNumber) = 0 RETURN 0
INSERT INTO @wagi(pozycja,waga)
VALUES (1,6),(2,5),(3,7),(4,2),(5,3),
       (6,4),(7,5),(8,6),(9,7)
IF (SELECT SUM(CAST(SUBSTRING(@NIPNumber, pozycja, 1) AS tinyint) * waga) % 10
      FROM @wagi) <> SUBSTRING(@NIPNumber,10,1)
   RETURN 0
RETURN 1
END
GO 

--wyszukiwanie go�ci po imieniu lub nazwisku
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SearchGuestByNameOrLastName(@NameOrSurname varchar(60))
RETURNS TABLE
AS
RETURN(
SELECT g.IdGuest,g.IDNumber, g.LastName, g.Name, g.PassportNumber, pd.* 
FROM [hotel].[tbl_guests] as g inner join [hotel].[tbl_people_data] as pd
on g.IdPersonData=pd.IdPersonData
WHERE LOWER([Name])+' '+LOWER([LastName]) LIKE LOWER('%'+@NameOrSurname+'%'))
GO

--aktualny status podanego pokoju
use HotelDatabase
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

--liczba rezerwacji dla go�cia o danym imieniu/nazwisku
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_NumberOfGuestReservations
(@NameOrLastName varchar(50))
RETURNS TABLE
AS
RETURN(
SELECT p.Name, p.LastName, p.IdGuest, COUNT(r.IdReservation) AS NumberOfReservation 
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
CREATE OR ALTER FUNCTION uf_getRoomPrice(@id_room int)
RETURNS money
BEGIN
DECLARE @price money
	SET @price =  (SELECT [RoomPrice] FROM [room].[tbl_room_type] as rt
	INNER JOIN [hotel].[tbl_rooms] as r
	ON rt.[IdRoomType] = r.[IdRoomType]
	WHERE r.[IdRoom] = @id_room)
RETURN @price
END
GO

--numer go�cia na podstawie numeru faktury
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
GO

--data wymeldowania na podstawie numeru rezerwacji
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_getCheckOutDate(@id_reservation int)
RETURNS date
BEGIN
DECLARE @CheckOutDate date
	SET @CheckOutDate = (SELECT CheckOutDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
	RETURN @CheckOutDate
END
GO


--data zameldowania na podstawie numeru rezerwacji
use HotelDatabase
go
CREATE FUNCTION uf_getCheckInDate(@id_reservation int)
RETURNS date
BEGIN
DECLARE @CheckInDate date
	SET @CheckInDate = (SELECT CheckInDate FROM [hotel].[tbl_reservations] WHERE [IdReservation] = @id_reservation)
	RETURN @CheckInDate
END
GO

--obliczanie d�ugo�ci pobytu w dniach
use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_LengthOfTheVisit(@id_Reservation int)
Returns int
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
BEGIN
DECLARE @isRoomReserved bit, @CheckInDate date, @CheckOutDate date, @status varchar
	Select @CheckInDate = [CheckInDate], @CheckOutDate = [CheckOutDate] 
	from [hotel].[tbl_reservations]
	where [IdRoom]=@id_room

	select @status=[StatusName]
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

--obliczanie ��cznej kwoty faktury
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
