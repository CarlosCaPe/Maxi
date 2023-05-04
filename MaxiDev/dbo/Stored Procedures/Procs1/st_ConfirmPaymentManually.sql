CREATE PROCEDURE st_ConfirmPaymentManually
(
	@IdTransfer             INT,
	@AuthorizationNo        NVARCHAR(20),
	@BatchNo                NVARCHAR(200),
	@ReferenceNo            NVARCHAR(200),
	@TerminalId             NVARCHAR(200),
	@MerchantId             NVARCHAR(200),
	@AccountNo              NVARCHAR(200),

	@PosStatusCode          NVARCHAR(200),
	@CardEntryModeCode      NVARCHAR(200),
	@CardTypeCode           NVARCHAR(200),
	@IdUser					INT,

	@HasError				BIT OUT,
    @Message				VARCHAR(MAX) OUT
)
AS
BEGIN
	DECLARE @PosActionTypeCode NVARCHAR(200) = 'sale'

	DECLARE @IdDocumentType_DCConfirm INT
	SET @IdDocumentType_DCConfirm = CAST(dbo.GetGlobalAttributeByName('IdDocumentTypes_DCPaymentConfirmation') AS INT)

	IF NOT EXISTS (SELECT 1 FROM UploadFiles uf WHERE uf.IdReference = @IdTransfer AND uf.IdDocumentType = @IdDocumentType_DCConfirm)
	BEGIN
		SELECT
			@Message =  CONCAT('Before confirming the payment, it is necessary to upload a document of (', dt.Name ,')')
		FROM DocumentTypes dt WITH(NOLOCK) 
		WHERE dt.IdDocumentType = @IdDocumentType_DCConfirm

		SET @HasError = 1
	END
	ELSE IF EXISTS(SELECT 1 FROM PosTransfer pt WHERE pt.AuthorizationNo = @AuthorizationNo)
	BEGIN
		SET @Message = CONCAT('Cannot be confirmed payment, the authorization number (', @AuthorizationNo,') has already exists')
		SET @HasError = 1
	END

	EXEC st_ConfirmPayment
		@IdTransfer,
		@AuthorizationNo,
		@BatchNo,
		@ReferenceNo,
		@TerminalId,
		@MerchantId,
		@AccountNo,
		@PosStatusCode,
		@CardEntryModeCode,
		@CardTypeCode,
		@PosActionTypeCode,
		@IdUser,
		@HasError OUT,
		@Message OUT

	DECLARE @TransferNote	VARCHAR(500),
			@IdStatus		INT

	SET @TransferNote = IIF(@HasError = 0, 'Payment was confirmed manually', 'An error occurred when confirming the payment manually')

	SELECT
		@IdStatus = t.IdStatus
	FROM Transfer t WITH(NOLOCK)
	WHERE t.IdTransfer = @IdTransfer

	EXEC st_SaveChangesToTransferLog @IdTransfer, @IdStatus, @TransferNote, @IdUser
END