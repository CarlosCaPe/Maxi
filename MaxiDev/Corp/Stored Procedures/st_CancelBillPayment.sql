CREATE PROCEDURE [Corp].[st_CancelBillPayment]
(
	@IdBillPayment INT,
    @Status INT,
	@LastUserChange NVARCHAR(MAX),
	@LastIpChange NVARCHAR(MAX),
	@LastNoteChange NVARCHAR(MAX),
	@CancelUser INT,
    @HasError INT OUT,
    @Message NVARCHAR(MAX)OUT
)
AS 
SET NOCOUNT ON;
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''
	
		UPDATE [dbo].[BillPaymentTransactions]
		SET [Status] = @Status, 
			[LastChange_LastUserChange] = @LastUserChange, 
			[LastChange_LastDateChange] = GETDATE(),
			[LastChange_LastIpChange] = @LastIpChange, 
			[LastChange_LastNoteChange] = @LastNoteChange, 
			[CancelUser] = @CancelUser, 
			[CancelDate] = GETDATE()
		WHERE IdBillPayment = @IdBillPayment
END TRY
BEGIN CATCH 
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
END CATCH
