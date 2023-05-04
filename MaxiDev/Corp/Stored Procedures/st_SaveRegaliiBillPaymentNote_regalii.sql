CREATE PROCEDURE [Corp].[st_SaveRegaliiBillPaymentNote_regalii]
	-- Add the parameters for the stored procedure here
	@ProductTransferId BIGINT
	, @UserId INT
	, @Note NVARCHAR(MAX)
	, @HasError BIT OUTPUT
	, @Message NVARCHAR(MAX) OUTPUT

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @TransferRId BIGINT
	SELECT @TransferRId = [IdTransferR] FROM [Regalii].[TransferR] WHERE [IdProductTransfer] = @ProductTransferId

	INSERT INTO [Regalii].[Notes] ([IdTransferR],[IdUser],[Note],[DateOfCreation])
	VALUES (@TransferRId, @UserId, @Note, GETDATE());

	SET @HasError = 0
	SET @Message = 'Note has been successfully saved'

END TRY
BEGIN CATCH
	SET @HasError = 1
	SET @Message = 'Error when trying to save note'
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('Corp.st_SaveRegaliiBillPaymentNote_regalii',GETDATE(),@ErrorMessage)
END CATCH
