
CREATE PROCEDURE [dbo].[st_ResponseReturnCodeGirosMex]
	-- Add the parameters for the stored procedure here
	@IdGateway  int,
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
    @IsCorrect bit Output
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="11/09/2018" Author="jmolina">Add with(nolock), Cast @Claimcode and @ReturnCode And Begin TRY #1</log>
<log Date="12/12/2018" Author="jmolina">Se comenta funcionalidad de moneyalert #1</log>
</ChangeLog>
********************************************************************/
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	
	DECLARE @IdStatusAction int
	DECLARE @Description nvarchar(max)
	DECLARE @IdTransfer int
	DECLARE @ActualIdStatus int
	DECLARE @str varchar(max)
	DECLARE @ReturnAllComission int
	DECLARE @ReturnCodeS nvarchar(32) --#1
	DECLARE @ClaimcodeS nvarchar(50) --#1
	SET @str=''
	SET @ReturnCodeS = CONVERT(nvarchar(32), @ReturnCode) --#1
	SET @ClaimcodeS = CONVERT(nvarchar(50), @Claimcode) --#1
	SELECT
		@IdStatusAction = A.[IdStatusAction]
		,@Description = B.[ReturnCodeType] + ' code '+ @ReturnCode + ',' + [Description]
	from [dbo].[GatewayReturnCode] A WITH(NOLOCK)
	INNER JOIN [dbo].[GatewayReturnCodeType] B WITH(NOLOCK) ON A.[IdGatewayReturnCodeType]=B.[IdGatewayReturnCodeType]
	WHERE
		A.[IdGateway] = @IdGateway
		AND A.[IdGatewayReturnCodeType] = @ReturnCodeType
		AND A.[ReturnCode] = @ReturnCodeS --#1
		--AND A.[ReturnCode] = @ReturnCode --#1

	INSERT INTO [dbo].[GirosMexResponseLog] VALUES (GETDATE(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

	DECLARE @CveIdentification NVARCHAR(MAX)
			,@IdentificationNumber NVARCHAR(MAX)
			,@PaymentDate NVARCHAR(MAX)
			,@Status NVARCHAR(MAX)

	IF @ReturnCodeType = 3 -- Payment/Cancelation Confirmation method && Transaction Status  method
	BEGIN
		SELECT
			@CveIdentification = 'CVE_IDENTIFICACION=' + ISNULL(T.[xmlString].value('(/NOTIFICACION_O//CVE_IDENTIFICACION/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			,@IdentificationNumber = 'IdentificationNumber=' + ISNULL(T.[xmlString].value('(/NOTIFICACION_O//IdentificationNumber/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			,@PaymentDate = 'FECHA_PAGO=' +ISNULL(T.[xmlString].value('(/NOTIFICACION_O//FECHA_PAGO/node())[1]', 'NVARCHAR(MAX)'),'NULL')
			,@Status = 'ESTATUS=' +ISNULL(T.[xmlString].value('(/NOTIFICACION_O//ESTATUS/node())[1]', 'NVARCHAR(MAX)'),'NULL')
		FROM (SELECT @XmlValue AS [xmlString]) T
		SET @Description=@Description+  ' ' + @CveIdentification + ';' + @IdentificationNumber + ';' + @PaymentDate + ';' + @Status
	END

	SELECT 
		@IdTransfer = T.[IdTransfer]
		,@ActualIdStatus = T.[IdStatus]
		,@ReturnAllComission = R.[ReturnAllComission] 
	FROM [dbo].[Transfer] T WITH(NOLOCK)
	LEFT JOIN
		[dbo].[ReasonForCancel] R WITH(NOLOCK) ON T.[IdReasonForCancel] =R.[IdReasonForCancel]
		WHERE T.ClaimCode = @ClaimcodeS --#1
		--WHERE T.[ClaimCode] = @Claimcode --#1

	IF @IdStatusAction > 0
	BEGIN
		if @IdTransfer is not null  and @ActualIdStatus<>@IdStatusAction                                      
		begin                                             

				UPDATE [dbo].[Transfer] SET [IdStatus]=@IdStatusAction, [DateStatusChange]=GETDATE() WHERE [IdTransfer] = @IdTransfer
				EXEC st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0
				IF @IdStatusAction = 31 --- Rejected balance
				BEGIN
					EXEC [dbo].[st_RejectedCreditToAgentBalance] @IdTransfer
				END
				IF @IdStatusAction=22  -- Cancel Balance
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM [dbo].[TransfersUnclaimed] WITH(NOLOCK) WHERE [IdTransfer]=@IdTransfer AND [IdStatus]=1)
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
					EXEC [dbo].[st_SavePayInfoGirosMex] @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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
		--	insert into MoneyAlert.StatusChangePushMessage
		--	values
		--	(@Claimcode,getdate(),null,0)
		--End Try                                                                                            
		--Begin Catch
		-- Declare @ErrorMessage nvarchar(max)                                                                                             
		-- Select @ErrorMessage=ERROR_MESSAGE()                                             
		-- Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeGirosMex',Getdate(),@ErrorMessage)                                                                                            
		--End Catch
	end  

	END
	ELSE
	BEGIN
		SELECT @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
		EXEC st_SimpleAddNoteToTransfer  @IdTransfer,@Description
	END
	SET @IsCorrect=1
END TRY
BEGIN CATCH --#1
		 Declare @ErrorMessage2 nvarchar(max)                                                                                             
		 Select @ErrorMessage2=ERROR_MESSAGE()                                             
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeGirosMex',Getdate(),@ErrorMessage2)
END CATCH