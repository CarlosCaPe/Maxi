CREATE PROCEDURE [Corp].[st_InsertSMSResendDomesticTransfer]
	@TransferId	INT,
	@HasError 	BIT OUTPUT,
	@Message 	NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY 

/********************************************************************
<Author>Cesar Garcia</Author>
<app>Corp</app>
<Description>Inserta mensaje sms para envios domesticos </Description>

<ChangeLog>
<log Date="2022/10/28" Author="cgarcia">MP-1269 CRONOS- Envíos Domésticos : SMS en español Permitir Reenvio desde Back office</log>
</ChangeLog>
********************************************************************/
	
	SET NOCOUNT ON;
	
	DECLARE @BeneficiaryName	NVARCHAR(MAX)
		,@SecretCode			NVARCHAR(4)
		,@Amount				NVARCHAR(30)
		,@Currency				NVARCHAR(30)
		,@CelullarNumber 		NVARCHAR(MAX)
		,@AgentId 				INT
		,@GatewayId 			INT
		,@InterCode 			NVARCHAR(MAX)
		,@IdPaymentType 		INT
			
	SET @InterCode = (SELECT C.Prefix
						FROM Transfer T INNER JOIN dbo.DialingCodePhoneNumber C ON C.IdDialingCodePhoneNumber = T.IdDialingCodePhoneNumber 
						WHERE T.IdTransfer = @TransferId)
						

	SELECT @IdPaymentType = T.IdPaymentType
		,@CelullarNumber =  T.CustomerCelullarNumber
		,@BeneficiaryName = T.BeneficiaryName
		,@SecretCode = substring(T.ClaimCode, len(T.ClaimCode) - 3, len(T.ClaimCode))
		,@Amount = convert(VARCHAR, T.AmountInDollars)
		,@Currency = C.CurrencyCode
		,@CelullarNumber =  T.CustomerCelullarNumber
		,@AgentId = T.IdAgent
		,@GatewayId = T.IdGateway
	FROM Transfer T WITH (NOLOCK) INNER JOIN 
		dbo.CountryCurrency CC WITH(NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency INNER JOIN 
		dbo.Currency C WITH(NOLOCK) ON C.IdCurrency = CC.IdCurrency
	WHERE IdTransfer = @TransferId
	
	IF (@IdPaymentType <> 6)
	BEGIN
		SET @HasError = 1
		SET @Message = 'SMS message could not be generated, Transfer is not domestic.'
	END
	
	

	DECLARE @TextMessage NVARCHAR(MAX)
	SELECT @TextMessage = [BodyMessage] FROM [dbo].[StatusToSendCellularMsg] WITH(NOLOCK) WHERE [IdStatus] = 23 AND [IdPaymentType] = 6
	
	
	
	SELECT @TextMessage = replace(@TextMessage, '{{tran_benef}}', @BeneficiaryName)
	SELECT @TextMessage = replace(@TextMessage, '{{tran_amount}}', @Amount)
	SELECT @TextMessage = replace(@TextMessage, '{{tran_currency}}', ltrim(rtrim(@Currency)))
	SELECT @TextMessage = replace(@TextMessage, '{{tran_secretcode}}', ltrim(rtrim(@SecretCode)))
	
	--SELECT @TextMessage
	
	
	EXEC [Infinite].[st_InsertTextMessage]
					@MessageType = 1, 
					@Priority = 3, 
					@CellularNumber = @CelullarNumber,
					@InterCode = @InterCode,
					@TextMessage = @TextMessage,
					@AgentId = @AgentId,
					@GatewayId = @GatewayId,
					@IsCustomer = 1,
					@IsDelayed = 0,
					@IdTransfer = @TransferId,
					@HasError = NULL,
					@Message = NULL
					
	SELECT @TextMessage
	
	SELECT @HasError = 0
	SELECT @Message = 'Operation was successful'
	

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Corp.st_InsertSMSResendDomesticTransfer', GETDATE(), @ErrorMessage)
END CATCH

