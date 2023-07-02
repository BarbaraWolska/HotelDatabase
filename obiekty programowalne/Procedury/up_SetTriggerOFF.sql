exec sp_helptext up_SetTriggerOFF
--------------------------------------------------------------------------------------
--- PROCEDURE DEFINITION
--- up_SetTriggerOFF (@TableName varchar(50))
--------------------------------------------------------------------------------------
--wy��cza wyzwalacz dla podanej tabeli s�ownikowej
--
--parametry wej�ciowe:
--@TableName - nazwa tabeli s�ownikowej
--
/*
exec up_SetTriggerOFF @TableName='tbl_status'
--
--Wynik dzia�ania:
--Wyzwalacz trg_EmployeePositionEditBlock zostaje wy��czony
--Komunikat:
--Triger dla tabeli tbl_status zosta� wy��czony
--------------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE up_SetTriggerOFF
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @TableName IN ('employee.tbl_employee_position', 'tbl_employee_position', '[employee].[tbl_employee_position]')
        BEGIN
            DISABLE TRIGGER trg_EmployeePositionEditBlock ON tbl_employee_position;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta� wy��czony.';
        END
        ELSE IF @TableName IN ('tbl_status', '[room.tbl_status', '[room].[tbl_status]')
        BEGIN
            DISABLE TRIGGER trg_RoomStatusEditBlock ON tbl_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta� wy��czony.';
        END
        ELSE IF @TableName IN ('tbl_reservation_status', 'reservation.tbl_reservation_status', '[reservation].[tbl_reservation_status]')
        BEGIN
            DISABLE TRIGGER trg_ReservationStatusEditBlock ON tbl_reservation_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta� wy��czony.';
        END
        ELSE IF @TableName IN ('tbl_room_type', 'room.tbl_room_type', '[room].[tbl_room_type]')
        BEGIN
            DISABLE TRIGGER trg_RoomTypeEditBlock ON [room].[tbl_room_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta� wy��czony.';
        END
        ELSE IF @TableName IN ('tbl_payment_type', 'payment.tbl_payment_type', '[payment].[tbl_payment_type]')
        BEGIN
            DISABLE TRIGGER trg_PaymentTypeEditBlock ON [payment].[tbl_payment_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta� wy��czony.';
        END
        ELSE
        BEGIN
            RAISERROR('Nieprawid�owa nazwa tabeli.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wyst�pi� b��d podczas wy��czania triger�w: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;
