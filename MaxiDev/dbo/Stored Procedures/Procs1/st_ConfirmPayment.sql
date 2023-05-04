CREATE PROCEDURE st_ConfirmPayment
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
	@PosActionTypeCode      NVARCHAR(200),
	@IdUser					INT,

	@HasError				BIT OUT,
    @Message				VARCHAR(MAX) OUT
)
AS
BEGIN
	DECLARE @IdPosStatus		INT,
			@IdCardEntryMode	INT,
			@IdCardType			INT,
			@IdPosActionType	INT

	SELECT TOP 1 @IdPosStatus = IdPosStatus FROM PosStatus WITH(NOLOCK) WHERE Code = @PosStatusCode
	SELECT TOP 1 @IdCardEntryMode = IdCardEntryMode FROM CardEntryMode WITH(NOLOCK) WHERE Code = @CardEntryModeCode
	SELECT TOP 1 @IdCardType = IdCardType FROM CardType WITH(NOLOCK) WHERE Code = @CardTypeCode
	SELECT TOP 1 @IdPosActionType = IdPosActionType FROM PosActionType WITH(NOLOCK) WHERE Code = @PosActionTypeCode

	IF EXISTS(SELECT 1 FROM PosTransfer WITH(NOLOCK) WHERE (IdTransfer = @IdTransfer OR IdTransferClosed = @IdTransfer) AND IdPosActionType = @IdPosActionType)
		SET @Message = CONCAT('A ', @PosActionTypeCode,' transaction already exists for the transaction')
	ELSE IF @IdPosStatus IS NULL
		SET @Message = CONCAT('The status code ', @PosStatusCode,' is not valid')
	ELSE IF @IdCardEntryMode IS NULL
		SET @Message = CONCAT('The card entry mode ', @CardEntryModeCode,' is not valid')
	ELSE IF @IdCardType IS NULL
		SET @Message = CONCAT('The card type ', @CardTypeCode,' is not valid')
	ELSE IF @IdPosActionType IS NULL
		SET @Message = CONCAT('The pos action ', @PosActionTypeCode,' is not valid')
	
	IF ISNULL(@Message, '') <> ''
	BEGIN
		SET @HasError = 1
		RETURN
	END

	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO PosTransfer
		(
			IdTransfer, 
			AuthorizationNo, 
			BatchNo, 
			ReferenceNo,
			TerminalId, 
			MerchantId, 
			AccountNo, 
			IdPosStatus, 
			IdCardEntryMode, 
			IdCardType, 
			IdPosActionType,
			CreationDate,
			IdUser
		)
		VALUES
		(
			@IdTransfer,
			@AuthorizationNo,
			@BatchNo,
			@ReferenceNo, 
			@TerminalId,
			@MerchantId,
			@AccountNo, 
			@IdPosStatus,
			@IdCardEntryMode,
			@IdCardType,
			@IdPosActionType,
			GETDATE(),
			@IdUser
		)

		EXEC st_InitTransaction @IdTransfer

		SET @HasError = 0
		SET @Message = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = dbo.GetMessageFromMultiLenguajeResorces(1,'MESSAGE07')

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES('st_ConfirmPayment', GETDATE(), @MSG_ERROR);
	END CATCH

END