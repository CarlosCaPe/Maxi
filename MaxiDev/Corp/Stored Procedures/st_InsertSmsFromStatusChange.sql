CREATE PROCEDURE [Corp].[st_InsertSmsFromStatusChange]
	-- Add the parameters for the stored procedure here
	@TransferId INT
	, @StatusId INT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[Corp].[st_InsertSmsFromStatusChange]', GETDATE(), 'CGG20210810')
	

    -- Insert statements for procedure here
	
	DECLARE @IdPaymentType INT
			, @ClaimCode NVARCHAR(MAX)
			, @AgentId INT
			, @GatewayId INT
			, @RemoveSubscriptionInverval INT
			, @InterCode NVARCHAR(MAX)
			, @CelullarNumber NVARCHAR(MAX)
			, @TotalMessage INT
			, @PayerName NVARCHAR(max)
			, @Folio NVARCHAR(max)
			, @CustomerName NVARCHAR(max)
			, @IsDelayed BIT = 0
			, @BeneficiaryName NVARCHAR(MAX)
			, @TransferDate NVARCHAR(MAX)

	SET @InterCode =  (SELECT Transfer.IdDialingCodePhoneNumber from Transfer
	WHERE Transfer.IdTransfer = @TransferId)

	SELECT
		@IdPaymentType = T.IdPaymentType
		,@ClaimCode = T.ClaimCode
		,@AgentId = T.IdAgent
		,@GatewayId = T.IdGateway
		,@CelullarNumber =  T.CustomerCelullarNumber
		,@Folio = convert(NVARCHAR(max), T.Folio)
		,@CustomerName = T.CustomerName
		,@PayerName = P.PayerName
		,@BeneficiaryName = T.BeneficiaryName
		,@TransferDate = FORMAT(T.DateOfTransfer, 'MM/dd/yyyy')
	FROM dbo.Transfer T WITH (NOLOCK) LEFT JOIN
		dbo.Payer P WITH(NOLOCK) ON P.IdPayer = T.IdPayer
	WHERE IdTransfer = @TransferId
	

	SET @RemoveSubscriptionInverval = CONVERT(INT,ISNULL([dbo].[GetGlobalAttributeByName]('SmsNotificationInterval'),'1'))

	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[StatusToSendCellularMsg] WITH (NOLOCK) WHERE [IdStatus]=@StatusId AND [IdPaymentType]=@IdPaymentType)
		AND EXISTS(SELECT TOP 1 1 FROM [Infinite].[CellularNumber] WITH (NOLOCK) WHERE [AllowSentMessages] = 1 AND [IsCustomer] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] = @CelullarNumber)
	BEGIN
		
		
		DECLARE @TextMessage NVARCHAR(MAX)
		--SELECT @TextMessage = [SubjectMessage] + ' ' + @ClaimCode + ' ' + [BodyMessage] FROM [dbo].[StatusToSendCellularMsg] WITH (NOLOCK) WHERE [IdStatus]=@StatusId AND [IdPaymentType]=@IdPaymentType
		SELECT @TextMessage = [BodyMessage] FROM [dbo].[StatusToSendCellularMsg] WITH (NOLOCK) WHERE [IdStatus]=@StatusId AND [IdPaymentType]=@IdPaymentType
		
		SELECT @TextMessage = replace(@TextMessage, '{{tran_sender}}', @CustomerName)
		SELECT @TextMessage = replace(@TextMessage, '{{tran_payer}}', @PayerName)
		SELECT @TextMessage = replace(@TextMessage, '{{tran_number}}', @ClaimCode)
		SELECT @TextMessage = replace(@TextMessage, '{{tran_folio}}', @Folio)
		SELECT @TextMessage = replace(@TextMessage, '{{tran_benef}}', @BeneficiaryName)
		SELECT @TextMessage = replace(@TextMessage, '{{tran_fecha}}', @TransferDate)

		DECLARE @MessageType INT = 1 -- PaymentReady
		
		IF @StatusId = 30
		BEGIN
			
			SET @MessageType = 7 -- Paid
			SET @GatewayId = NULL -- This status only use Agent Time Zone

			SELECT @TotalMessage = COUNT(1)
			FROM [Infinite].[TextMessageInfinite] TM WITH (NOLOCK)
			JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON TM.[IdCellularNumber] = CN.IdCellularNumber
			WHERE TM.[IdMessageType] = @MessageType -- Paid
				AND CN.[AllowSentMessages] = 1 AND CN.[IsCustomer] = 1 AND CN.[InterCode] = @InterCode AND CN.[NumberWithFormat] = @CelullarNumber

			SET @TotalMessage = ISNULL(@TotalMessage,0) + 1
			IF @TotalMessage % @RemoveSubscriptionInverval = 0 -- Insert unsubscription message
				SET @TextMessage = @TextMessage + ' ' + [dbo].[GetGlobalAttributeByName]('SmsUnsubscriptionMessage') + ' NO'-- + [dbo].[GetGlobalAttributeByName]('InfiniteUnsubscriptionWords')

		END
		
		IF @StatusId IN (9, 12, 15, 29)
		BEGIN
		
			IF EXISTS (SELECT TOP 1 1 FROM infinite.TextMessageInfinite WITH(NOLOCK) WHERE IdMessageType = 11 AND IdTextMessageStatus IN (1,2) AND IdTransfer = @TransferId)
			BEGIN
				RETURN;
			END
			SET @MessageType = 11 -- Hold
			SET @IsDelayed = 1
		
		END

		EXEC [Infinite].[st_InsertTextMessage]
					@MessageType = @MessageType, -- StatusChange ( PaymentReady or Paid )
					@Priority = 3, -- High
					@CellularNumber = @CelullarNumber,
					@InterCode = @InterCode,
					@TextMessage = @TextMessage,
					@AgentId = @AgentId,
					@GatewayId = @GatewayId,
					@IsCustomer = 1,
					@IsDelayed = @IsDelayed,
					@IdTransfer = @TransferId,
					@HasError = NULL,
					@Message = NULL

	END

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[Corp].[st_InsertSmsFromStatusChange]', GETDATE(), @ErrorMessage)
END CATCH



