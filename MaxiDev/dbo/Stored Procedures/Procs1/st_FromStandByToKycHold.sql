 /*=============================================
 Author:		Francisco Lara
 Create date: 2016-02-10
 Description:	This stored change status from stand by to KYC Hold, screen Transfer detail

<ChangeLog>
<log Date="17/10/2019" Author="bortega">Validación Deposit Hold :: Ref: M00120 - CDM</log>
<log Date="31/12/2019" Author="jsierra">Se agregan mensajes para la KYCAction 8 </log>
</ChangeLog>
 =============================================*/
CREATE PROCEDURE [dbo].[st_FromStandByToKycHold]
	-- Add the parameters for the stored procedure here
	@TransferIds XML,
	@KycActionIds XML,
	@UserId INT,
	@IsSpanishLanguage BIT = 0,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	CREATE TABLE #Transactions (
		[RowId] INT IDENTITY
		, [TransferId] INT
		, [ClaimCode] NVARCHAR(MAX)
		, [Folio] INT
		, [AmountInDollars] MONEY
		, [IdStatus] INT
		, [HasError] BIT
	)

	DECLARE @KycActions AS TABLE ( KycAction INT )

--	IF @KycActionId <= 0 SET @KycActionId = NULL

	DECLARE @Doc INT
	EXEC sp_xml_preparedocument @Doc OUTPUT, @TransferIds;

	INSERT INTO #Transactions
		SELECT
			D.[TransferId]
			, T.[ClaimCode]
			, T.[Folio]
			, T.[AmountInDollars]
			, T.[IdStatus] 
			, 0 [HasError]
		FROM OPENXML (@Doc, '/Ids/Id', 2) WITH ([TransferId] INT) D
		JOIN [dbo].[Transfer] T WITH (NOLOCK) ON D.[TransferId] = T.[IdTransfer]
		

	EXEC sp_xml_removedocument @Doc

	EXEC sp_xml_preparedocument @Doc OUTPUT, @KycActionIds;

	INSERT INTO @KycActions
		SELECT
			D.[TransferId]
		FROM OPENXML (@Doc, '/Ids/Id', 2) WITH ([TransferId] INT) D
		

	EXEC sp_xml_removedocument @Doc


	DECLARE @TransferId INT, @Amount MONEY, @ActualStatus INT, @Counter INT = 0, @TotalRows INT = (SELECT COUNT(1) FROM #Transactions)
			, @Folios NVARCHAR(MAX), @BrokenRuleName NVARCHAR(MAX), @StatusHistoryNote NVARCHAR(MAX)
			, @RequestIdEnglishMessage NVARCHAR(MAX) = 'Please send a copy of the Customer''s ID. Write down all the information of the ID.'
			, @RequestIdSpanishMessage NVARCHAR(MAX) = 'Favor de enviar copia del ID, escribiendo toda la información del ID.'
			, @ShowMessageEnglishMessage NVARCHAR(MAX) = 'Please send a copy of Customer''s Proof of Income.'
			, @ShowMessageSpanishMessage NVARCHAR(MAX) = 'Favor de enviar copia de Comprobante de Ingresos del Cliente.'

	DECLARE @SuspicusTranferEnglishMessage NVARCHAR(MAX) = 'Please validate the transfer data, it could be a fraud',
			@SuspicusTranferSpanishMessage NVARCHAR(MAX) = 'Por favor validar los datos de la transacción, podria tratarse de un fraude'

	SELECT @Folios = COALESCE(@Folios + ', ', '') + (CONVERT(NVARCHAR(MAX),[Folio])) FROM #Transactions
	
	SELECT @Amount = SUM(ISNULL([AmountInDollars],0)) FROM #Transactions 

	WHILE @Counter < @TotalRows
	BEGIN TRY
		SET @Counter = @Counter + 1
		SELECT @TransferId = ISNULL([TransferId],0), @ActualStatus = ISNULL([IdStatus],0) FROM #Transactions WHERE [RowId] = @Counter

		IF (@ActualStatus <> 20) /*Stand By*/ and (@ActualStatus <> 41) -- M00120 - CDM
		BEGIN
			UPDATE #Transactions SET [HasError] = 1 WHERE [TransferId] = @TransferId
			CONTINUE
		END


		If not exists (Select 1 from [dbo].[TransferHolds] where IdTransfer = @TransferId and IdStatus = 9  ) -- M00120 - CDM
		BEGIN
			INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
					 VALUES (@TransferId, 9, GETDATE(), GETDATE(), @UserId)		
		END
		
		UPDATE [dbo].[Transfer] SET [IdStatus]=41, [DateStatusChange]=GETDATE(), [FromStandByToKYC]=1 WHERE [IdTransfer]=@TransferId
		
		-- Set Broken rules
		SET @BrokenRuleName = 'KYC Related Transactions (Folio ' + ISNULL(@Folios,'') + '   $ ' + CONVERT(NVARCHAR(MAX), @Amount) + ')'

		INSERT INTO [dbo].[BrokenRulesByTransfer]
		SELECT @TransferId, K.KycAction, 0, 
		CASE K.KycAction 
			WHEN 1 THEN @RequestIdEnglishMessage 
			WHEN 4 THEN @ShowMessageEnglishMessage
			WHEN 8 THEN @SuspicusTranferEnglishMessage
		END, 
		CASE K.KycAction 
			WHEN 1 THEN @RequestIdSpanishMessage 
			WHEN 4 THEN @ShowMessageSpanishMessage 
			WHEN 8 THEN @SuspicusTranferSpanishMessage
		END, 
		NULL, @BrokenRuleName + LTRIM(RTRIM('. ' + ISNULL(@Message,''))), NULL, NULL, NULL
		FROM @KycActions K


		SET @StatusHistoryNote = 'Compliance Daily Monitoring (' + @BrokenRuleName + ')'

		EXEC [dbo].[st_SaveChangesToTransferLog] @TransferId, 9, @StatusHistoryNote, @UserId -- Log , se ha detenido en KYC Hold hold

	END TRY
	BEGIN CATCH
		UPDATE #Transactions SET [HasError] = 1 WHERE [TransferId] = @TransferId
	END CATCH
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM #Transactions WHERE [HasError] = 1)
	BEGIN
		SELECT @Message = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLanguage,44)
		SET @HasError = 0
	END
	ELSE
	BEGIN
		DECLARE @ClaimsCode NVARCHAR(MAX), @ErrorMsg NVARCHAR(MAX)
		DECLARE @TransfersWithErrors INT = (SELECT COUNT(1) FROM #Transactions WHERE [HasError] = 1)
		
		SELECT @ClaimsCode = COALESCE(@ClaimsCode + ', ', '') + [ClaimCode] FROM #Transactions WHERE [HasError] = 1

		IF @TransfersWithErrors > 1
			SET @ErrorMsg = 'Unable Update transactions '
		ELSE
			SET @ErrorMsg = 'Unable Update transaction '
			
		SET @Message = @ErrorMsg + ISNULL(@ClaimsCode,'')
		SET @HasError = 1
	END
	
END TRY
BEGIN CATCH
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_FromStandByToKycHold', GETDATE(), ERROR_MESSAGE())
	SET @HasError = 1
	SELECT @Message = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLanguage,45)
END CATCH
