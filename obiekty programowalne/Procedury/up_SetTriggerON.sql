exec sp_helptext up_SetTriggerON
--------------------------------------------------------------------------------------
--- PROCEDURE DEFINITION
--- up_SetTriggerON (@TableName varchar(50))
--------------------------------------------------------------------------------------
--w³¹cza wyzwalacz dla podanej tabeli s³ownikowej
--
--parametry wejœciowe:
--@TableName - nazwa tabeli s³ownikowej
--
/*
exec up_SetTriggerON @TableName='tbl_status'
--
--Wynik dzia³ania:
--Wyzwalacz trg_EmployeePositionEditBlock zostaje w³¹czony
--Komunikat:
--Triger dla tabeli tbl_status zosta³ w³¹czony
--------------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE up_SetTriggerON
    @TableName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @TableName IN ('employee.tbl_employee_position', 'tbl_employee_position', '[employee].[tbl_employee_position]')
        BEGIN
            ENABLE TRIGGER trg_EmployeePositionEditBlock ON tbl_employee_position;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta³ w³¹czony.';
        END
        ELSE IF @TableName IN ('tbl_status', '[room.tbl_status', '[room].[tbl_status]')
        BEGIN
            ENABLE TRIGGER trg_RoomStatusEditBlock ON tbl_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta³ w³¹czony.';
        END
        ELSE IF @TableName IN ('tbl_reservation_status', 'reservation.tbl_reservation_status', '[reservation].[tbl_reservation_status]')
        BEGIN
            ENABLE TRIGGER trg_ReservationStatusEditBlock ON tbl_reservation_status;
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta³ w³¹czony.';
        END
        ELSE IF @TableName IN ('tbl_room_type', 'room.tbl_room_type', '[room].[tbl_room_type]')
        BEGIN
            ENABLE TRIGGER trg_RoomTypeEditBlock ON [room].[tbl_room_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta³ w³¹czony.';
        END
        ELSE IF @TableName IN ('tbl_payment_type', 'payment.tbl_payment_type', '[payment].[tbl_payment_type]')
        BEGIN
            ENABLE TRIGGER trg_PaymentTypeEditBlock ON [payment].[tbl_payment_type];
            PRINT 'Triger dla tabeli ' + @TableName + ' zosta³ w³¹czony.';
        END
        ELSE
        BEGIN
            RAISERROR('Nieprawid³owa nazwa tabeli.', 16, 1);
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Wyst¹pi³ b³¹d podczas w³¹czania trigerów: %s', @ErrorState, 1, @ErrorMessage);
    END CATCH;
END;
