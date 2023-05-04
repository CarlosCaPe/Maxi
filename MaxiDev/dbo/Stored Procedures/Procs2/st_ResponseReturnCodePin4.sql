
CREATE PROCEDURE [dbo].[st_ResponseReturnCodePin4]
(                                
    @IdGateway			INT,
    @Claimcode			NVARCHAR(50),
    @ReturnCode			NVARCHAR(16),
    @ReturnCodeType		INT,
    @XmlValue			XML,
    @IsCorrect			BIT OUTPUT
)
AS
BEGIN
	DECLARE	@IdTransfer			INT,
			@NextIdStatus		INT,
			@CurrentIdStatus	INT,
			@ReturnAllComission	BIT,
			@LogDescription		VARCHAR(MAX),
			@IdPaymentType		INT,
			@ExistsCode			BIT = 0

	SELECT
		@IdTransfer = t.IdTransfer,
		@CurrentIdStatus = t.IdStatus,
		@ReturnAllComission = ISNULL(rc.ReturnAllComission, 0),
		@IdPaymentType = t.IdPaymentType
	FROM Transfer t WITH(NOLOCK)
		LEFT JOIN ReasonForCancel rc WITH(NOLOCK) ON rc.IdReasonForCancel = t.IdReasonForCancel
	WHERE t.ClaimCode = @Claimcode

	SELECT
		@ExistsCode = CASE WHEN grc.IdGatewayReturnCode IS NULL THEN 0 ELSE 1 END,
		@NextIdStatus = grc.IdStatusAction,
		@LogDescription = CONCAT(
			gt.ReturnCodeType, 
			' Code ',
			@ReturnCode,
			', ',
			grc.Description
		)
	FROM GatewayReturnCode grc WITH(NOLOCK)
		JOIN GatewayReturnCodeType gt WITH(NOLOCK) ON gt.IdGatewayReturnCodeType = grc.IdGatewayReturnCodeType
	WHERE grc.IdGateway = @IdGateway
		AND grc.IdGatewayReturnCodeType = @ReturnCodeType
		AND grc.ReturnCode = @ReturnCode

	IF @LogDescription IS NULL
		SET @LogDescription = CONCAT('The Code: ', @ReturnCode, ' does not exist')

	INSERT INTO [MAXILOG].[dbo].[GatewayResponseLog]
	VALUES (GETDATE(), @IdTransfer, @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @NextIdStatus, @LogDescription, @XmlValue)

	IF ISNULL(@NextIdStatus, 0) = 0
	BEGIN
		IF @ExistsCode = 0
			SET @LogDescription = CONCAT('Return Code UNKNOWN, ', @LogDescription)
			
		EXEC st_SimpleAddNoteToTransfer @IdTransfer, @LogDescription
		RETURN
	END

	IF NOT (@IdTransfer IS NOT NULL AND @NextIdStatus <> @CurrentIdStatus)
		RETURN

	-- Actualizar Transfer

	UPDATE Transfer SET
		IdStatus = @NextIdStatus,
		DateStatusChange = GETDATE()
	WHERE IdTransfer = @IdTransfer

	EXEC st_SaveChangesToTransferLog @IdTransfer, @NextIdStatus, @LogDescription, 0

	
	IF @ReturnCodeType = 1 AND @ReturnCode = '0000'
	BEGIN 
		DECLARE @IssuerTicket VARCHAR(200),
				@TransferDetails VARCHAR(200)
		SELECT
			@IssuerTicket = t.c.value('IssuerTicket[1]', 'varchar(200)'),
			@TransferDetails = CONCAT('Authorization Details= ', CHAR(13),
				'IssuerTicket: ',  t.c.value('IssuerTicket[1]', 'varchar(200)'), CHAR(13),
				'HelenaId: ',  t.c.value('HelenaId[1]', 'varchar(200)'), CHAR(13),
				'AuthorizationDate: ', t.c.value('AuthorizationDate[1]', 'varchar(200)'), CHAR(13),
				'TransactionExpiryDate: ', t.c.value('TransactionExpiryDate[1]', 'varchar(200)')
			)
		FROM @XmlValue.nodes('AuthorizationResponseType') t(c)

		UPDATE Transfer SET
			ConfirmationCode = @IssuerTicket
		WHERE IdTransfer = @IdTransfer

		EXEC st_SaveChangesToTransferLog @IdTransfer, @NextIdStatus, @TransferDetails, 0
	END

	IF @NextIdStatus = 31 --- Rejected balance
		EXEC st_RejectedCreditToAgentBalance @IdTransfer
	ELSE IF @NextIdStatus = 22  -- Cancel Balance
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM TransfersUnclaimed WITH(NOLOCK) WHERE IdTransfer=@IdTransfer AND IdStatus=1)	                                                     
		BEGIN
			IF (@ReturnAllComission=0)--validar si se regresa completa la comision
				EXEC st_CancelCreditToAgentBalance @IdTransfer 
			ELSE
				EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer
		END
		ELSE
		BEGIN
			DECLARE @UnclaimedStatus INT
			SET @UnclaimedStatus = 27

			UPDATE TransfersUnclaimed SET 
				IdStatus=2 
			WHERE IdTransfer=@IdTransfer
			
			UPDATE [Transfer] SET 
				IdStatus = @UnclaimedStatus,
				DateStatusChange = GETDATE() 
			WHERE IdTransfer=@IdTransfer  

			EXEC st_SaveChangesToTransferLog @IdTransfer, @UnclaimedStatus, @LogDescription, 0
		END
	END 
	ELSE IF @NextIdStatus = 30  -- Paid
		INSERT INTO TransferPayInfo(IdTransfer, ClaimCode, IdGateway, DateOfPayment)
		VALUES(@IdTransfer, @Claimcode, @IdGateway, GETDATE())
	ELSE IF @NextIdStatus in (22,30,31)
	BEGIN
		DECLARE	@HasErrorD BIT,	@MessageOutD VARCHAR(max)

		EXEC [dbo].[st_DismissComplianceNotificationByIdTransfer] @IdTransfer, 1, @HasErrorD OUTPUT, @MessageOutD OUTPUT
	END

	SET @IsCorrect = 1
END
