-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-05-16
-- Description:	TransferTo Mobile return code processor
-- =============================================
CREATE PROCEDURE [dbo].[st_ResponseReturnCodeTransferToMobile]
	-- Add the parameters for the stored procedure here
	@IdGateway  INT,
    @Claimcode  NVARCHAR(MAX),
    @ReturnCode NVARCHAR(MAX),
    @ReturnCodeType INT,
    @XmlValue XML,
    @IsCorrect BIT OUTPUT
AS

/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla a las consultas y se comenta funcionalidad de moneyalert" #1</log>
</ChangeLog>
*********************************************************************/

BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	DECLARE @ResultCode NVARCHAR(MAX)
			, @DetailCode NVARCHAR(MAX)
			, @DetailMessage NVARCHAR(MAX)
			, @ProcessingDateBegin DATETIME
			, @ProcessingDateEnd DATETIME
			, @UniqueReferenceNumber NVARCHAR(MAX)
			, @TransactionCode NVARCHAR(MAX)
			, @CalculationMode NVARCHAR(MAX)
			, @ExchangeRate MONEY
			, @AmountToReceive MONEY
			, @AmountToReceiveCurrency NVARCHAR(MAX)
			, @AmountToSend MONEY
			, @AmountToSendCurrency NVARCHAR(MAX)
			, @CommissionAmount MONEY
			, @TotalAmount MONEY
			
			, @IdStatusAction INT
			, @Description NVARCHAR(MAX)
			, @IdTransfer INT
			, @ActualIdStatus INT
			, @ReturnAllComission BIT


		SELECT
			@ResultCode = ISNULL(T.[xmlString].value('(/SendResponse//resultCode/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @DetailCode = ISNULL(T.[xmlString].value('(/SendResponse//detailCode/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @DetailMessage = ISNULL(T.[xmlString].value('(/SendResponse//detailMessage/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @ProcessingDateBegin = T.[xmlString].value('(/SendResponse//processingDateBegin/node())[1]', 'DATETIME')
			, @ProcessingDateEnd = T.[xmlString].value('(/SendResponse//processingDateEnd/node())[1]', 'DATETIME')
			, @UniqueReferenceNumber = ISNULL(T.[xmlString].value('(/SendResponse//uniqueReferenceNumber/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @TransactionCode = ISNULL(T.[xmlString].value('(/SendResponse//transactionCode/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @CalculationMode = ISNULL(T.[xmlString].value('(/SendResponse//calculationModeUsed/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @ExchangeRate = T.[xmlString].value('(/SendResponse//exchangeRate/node())[1]', 'MONEY')
			, @AmountToReceive = T.[xmlString].value('(/SendResponse//amountToReceive/node())[1]', 'MONEY')
			, @AmountToReceiveCurrency = ISNULL(T.[xmlString].value('(/SendResponse//amountToReceiveCurrencyCodeISO/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @AmountToSend = T.[xmlString].value('(/SendResponse//amountToSend/node())[1]', 'MONEY')
			, @AmountToSendCurrency = ISNULL(T.[xmlString].value('(/SendResponse//amountToSendCurrencyCodeISO/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			, @CommissionAmount = T.[xmlString].value('(/SendResponse//commissionAmount/node())[1]', 'MONEY')
			, @TotalAmount = T.[xmlString].value('(/SendResponse//totalAmount/node())[1]', 'MONEY')
		FROM (SELECT @XmlValue AS [xmlString]) T


	IF @ReturnCodeType=3 AND @ReturnCode='ST'
	BEGIN
		SELECT			
			@UniqueReferenceNumber = ISNULL(T.[xmlString].value('(/Movement//uniqueReferenceNumber/node())[1]', 'NVARCHAR(MAX)'),'NULL')			
		FROM (SELECT @XmlValue AS [xmlString]) T
	END

	IF @ReturnCode = '9999'
		SET @ReturnCode = @ReturnCode + '-' + @DetailCode

	SELECT
		@IdStatusAction = A.[IdStatusAction]
		,@Description = B.[ReturnCodeType] + ' Code '+ @ReturnCodeCast + ',' + [Description]
		--,@Description = B.[ReturnCodeType] + ' Code '+ @ReturnCode + ',' + [Description]
	FROM [dbo].[GatewayReturnCode] A with(NOLOCK)
	JOIN [dbo].[GatewayReturnCodeType] B with(NOLOCK) ON A.[IdGatewayReturnCodeType]=B.[IdGatewayReturnCodeType]
	WHERE
		A.[IdGateway] = @IdGateway
		AND A.[IdGatewayReturnCodeType] = @ReturnCodeType
		AND A.[ReturnCode] = @ReturnCodeCast
		--AND A.[ReturnCode] = @ReturnCode

	INSERT INTO [MAXILOG].[dbo].[TToMobileResponseLog] VALUES (GETDATE(), @Claimcode, @ReturnCode, @ReturnCodeType, @IdStatusAction, @Description, @XmlValue)

	DECLARE @CveIdentification NVARCHAR(MAX)
			,@IdentificationNumber NVARCHAR(MAX)
			,@PaymentDate NVARCHAR(MAX)
			,@Status NVARCHAR(MAX)

	SET @Description = @Description +  ' ResultCode=' + @ResultCode + '; DetailCode=' + @DetailCode + '; DetailMessage=' + @DetailMessage + '; ProcessingDateBegin=' + ISNULL(CONVERT(NVARCHAR(MAX),@ProcessingDateBegin),'NULL')
					+ '; ProcessingDateEnd=' + ISNULL(CONVERT(NVARCHAR(MAX),@ProcessingDateEnd),'NULL') + '; UniqueReferenceNumber=' + @UniqueReferenceNumber + '; TransactionCode' + @TransactionCode
					+ '; CalculationMode=' + @CalculationMode + '; ExchangeRate=' + ISNULL(CONVERT(NVARCHAR(MAX),@ExchangeRate),'NULL') + '; AmountToReceive=' + ISNULL(CONVERT(NVARCHAR(MAX),@AmountToReceive),'NULL')
					+ '; AmountToReceiveCurrency=' + @AmountToReceiveCurrency + '; AmountToSend=' + ISNULL(CONVERT(NVARCHAR(MAX),@AmountToSend),'NULL') + '; AmountToSendCurrency=' + @AmountToSendCurrency
					+ '; CommissionAmount=' + ISNULL(CONVERT(NVARCHAR(MAX),@CommissionAmount),'NULL') + '; TotalAmount=' + ISNULL(CONVERT(NVARCHAR(MAX),@TotalAmount),'NULL')
					
	SELECT
		@IdTransfer = T.[IdTransfer]
		,@ActualIdStatus = T.[IdStatus]
		,@ReturnAllComission = R.[ReturnAllComission] 
	FROM [dbo].[Transfer] T with(NOLOCK)
	LEFT JOIN
		[dbo].[ReasonForCancel] R with(NOLOCK) ON T.[IdReasonForCancel] =R.[IdReasonForCancel]
	WHERE T.[ClaimCode] = @ClaimcodeCast
	--WHERE T.[ClaimCode] = @Claimcode
    
	if @IdTransfer is null return;

    IF NOT EXISTS (SELECT 1 FROM [TToMobileOperation] with(nolock) WHERE TransferID = @IdTransfer)
    BEGIN
        INSERT INTO [dbo].[TToMobileOperation] VALUES (@IdTransfer, @UniqueReferenceNumber, @CommissionAmount, @TotalAmount)
    END
	ELSE
	BEGIN		
		if @ReturnCode='ST'
		begin		
			UPDATE [dbo].[TToMobileOperation] SET UniqueReferenceNumber=@UniqueReferenceNumber WHERE TransferId=@IdTransfer
		end
	END

	IF @IdStatusAction > 0
	BEGIN
		IF @ActualIdStatus IS NOT NULL AND @ActualIdStatus != @IdStatusAction
		BEGIN
			UPDATE [dbo].[Transfer] SET [IdStatus]=@IdStatusAction, [DateStatusChange]=GETDATE() WHERE [IdTransfer] = @IdTransfer
			EXEC st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0
			IF @IdStatusAction = 31 --- Rejected balance
			BEGIN
				EXEC [dbo].[st_RejectedCreditToAgentBalance] @IdTransfer
			END
			IF @IdStatusAction=22  -- Cancel Balance
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM [dbo].[TransfersUnclaimed] with(NOLOCK) WHERE [IdTransfer]=@IdTransfer AND [IdStatus]=1)
				BEGIN
					IF (@ReturnAllComission=0)--validar si se regresa completa la comision
						EXEC [dbo].[st_CancelCreditToAgentBalance] @IdTransfer
					ELSE
						EXEC [dbo].[st_CancelCreditToAgentBalanceTotalAmount] @IdTransfer
				END
				ELSE
				BEGIN
					DECLARE @UnclaimedStatus INT
					SET @UnclaimedStatus=27
					UPDATE [dbo].[TransfersUnclaimed] SET [IdStatus]=2 WHERE [IdTransfer]=@IdTransfer
					UPDATE [dbo].[Transfer] SET [IdStatus]=@UnclaimedStatus,[DateStatusChange]=GETDATE() WHERE [IdTransfer]=@IdTransfer
					EXEC [dbo].[st_SaveChangesToTransferLog] @IdTransfer,@UnclaimedStatus,@Description,0
				END
			END
			IF @IdStatusAction=30  -- Paid
			BEGIN				
				EXEC [dbo].[st_SavePayInfoTransferToMobile] @IdGateway,@IdTransfer,@Claimcode,@XmlValue
			END
			IF (@IdStatusAction IN (22,30,31))
			BEGIN
				DECLARE	@HasErrorD BIT,	@MessageOutD NVARCHAR(MAX)

				EXEC [dbo].[st_DismissComplianceNotificationByIdTransfer]
	        		@IdTransfer,
					1,
					@HasErrorD OUTPUT,
					@MessageOutD OUTPUT
			END
			-- Se comenta debido que este servicio dejo de funcionar para MAXI
			--Begin Try 
			--insert into MoneyAlert.StatusChangePushMessage
			--values
			--(@Claimcode,getdate(),null,0)
			--End Try                                                                                            
			--Begin Catch
			-- Declare @ErrorMessage nvarchar(max)                                                                                             
			-- Select @ErrorMessage=ERROR_MESSAGE()                                             
			-- Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCode',Getdate(),@ErrorMessage)                                                                                            
			--End Catch  

		END
	END
	ELSE
	BEGIN
		SELECT @Description='Return code UNKNOWN:'+@ReturnCode
		EXEC st_SimpleAddNoteToTransfer  @IdTransfer, @Description
	END
	SET @IsCorrect=1

END TRY
BEGIN CATCH
	Declare @ErrorMessage nvarchar(max)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeTransferToMobile',Getdate(),@ErrorMessage)                                                                                            
END CATCH
