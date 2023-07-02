----Procedura up_ChangeRoomStatus została utworzona lub zmodyfikowana w celu zmiany statusu pokoju na podstawie numeru pokoju (@RoomNumber) i nowego statusu (@NewStatus).
--parametry wejściowe:
---@RoomNumber (INT): Przechowuje numer pokoju, dla którego ma zostać zmieniony status.
---@NewStatus (INT): Przechowuje nowy identyfikator statusu pokoju.
---Zwrócono wartość: (1 row affected)

CREATE OR ALTER PROCEDURE up_ChangeRoomStatus
    @RoomNumber INT,
    @NewStatus INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [hotel].[tbl_rooms]
        SET IdRoomStatus = @NewStatus
        WHERE RoomNumber = @RoomNumber
          AND EXISTS (
            SELECT 1
            FROM [room].[tbl_status]
            WHERE IdRoomStatus = @NewStatus
          );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        RAISERROR('Wystąpił błąd podczas zmiany statusu pokoju: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;

--Przykład użycia
EXEC up_ChangeRoomStatus @RoomNumber = 101, @NewStatus = 2;