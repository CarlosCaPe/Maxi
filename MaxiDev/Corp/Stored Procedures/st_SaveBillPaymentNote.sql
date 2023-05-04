CREATE PROCEDURE [Corp].[st_SaveBillPaymentNote]
(
    @IdBillPayment INT,
    @IdUser INT,
    @Note NVARCHAR(250),
    @LastChange_LastUserChange NVARCHAR(MAX),
    @LastChange_LastIpChange NVARCHAR(MAX),
    @LastChange_LastNoteChange NVARCHAR(MAX),
    @HasError INT OUT,
    @Message NVARCHAR(MAX) OUT
)
AS
SET NOCOUNT ON;
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''
		INSERT INTO [dbo].[BillPaymentNotes] ([IdBillPayment], [IdUser], [Note], [LastChange_LastUserChange], [LastChange_LastDateChange], [LastChange_LastIpChange], [LastChange_LastNoteChange])
		VALUES (@IdBillPayment, @IdUser, @Note, @LastChange_LastUserChange, GETDATE(), @LastChange_LastIpChange, @LastChange_LastNoteChange)
END TRY
BEGIN CATCH 
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
END CATCH

