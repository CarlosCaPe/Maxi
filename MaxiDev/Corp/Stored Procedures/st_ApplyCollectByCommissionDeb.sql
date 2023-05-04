CREATE PROCEDURE [Corp].[st_ApplyCollectByCommissionDeb]
(
    @DataXml XML,
    @IdUser INT,
    @ApplyDate DATETIME,
    @IsSpanishLanguage BIT,
    @HasError BIT OUTPUT,
    @Message VARCHAR(MAX) OUTPUT
)
AS 
	--nuevo
	DECLARE @IdBank INT
	DECLARE @BankName NVARCHAR(MAX)
	DECLARE @Enviroment NVARCHAR(MAX)

	SELECT @IdBank = CONVERT(INT,[dbo].[GetGlobalAttributeByName]('DefaultBankCommission'))
	SELECT @BankName = [Bankname] FROM [dbo].[AgentBankDeposit] WITH(NOLOCK) WHERE [Idagentbankdeposit] = @IdBank
	SET @BankName = ISNULL(@BankName,'Barter')

	SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')

	--Declaracion de variables
	--DECLARE @IdAgent INT
	DECLARE @AmountToPay MONEY
	DECLARE @SpecialCommToApply MONEY
	DECLARE @DocHandle INT 
	DECLARE @IdAgent INT
	DECLARE @note NVARCHAR(MAX)

	CREATE TABLE #InputData(
		[IdAgent] INT,
		[AmountToPay] MONEY,
		[SpecialCommissionToApply] MONEY,
		[Note] NVARCHAR(MAX)
	)

	--solo qa
	IF @Enviroment <> 'Production'
		SET @ApplyDate=GETDATE()-1

	--Inicializacion de variables
	SET @HasError = 0
	SET @Message='Apply by Commission Sucessfull'

	SELECT  @ApplyDate = [dbo].[RemoveTimeFromDatetime](@ApplyDate)  

	SELECT [dbo].[GetGlobalAttributeByName]('DefaultBankCommission')

	BEGIN TRY
		DECLARE @HasErrorTmp BIT
		DECLARE @MessageTmp  VARCHAR(MAX)
  
		EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DataXml   

		INSERT INTO #InputData
		SELECT [Idagent], [AmountToPay], [SpecialCommissionToApply], [Note] FROM OPENXML (@DocHandle, '/CollectionByCommissionDebts/CollectionByCommissionDebt',2)
		WITH (
			[IdAgent] INT,
			[AmountToPay] MONEY,
			[SpecialCommissionToApply] MONEY,
			[Note] NVARCHAR(MAX)
		) X
    
		--declare @Today datetime = getdate()
		
		--Ciclo para aplicar los movimientos
		WHILE EXISTS(SELECT TOP 1 1 FROM #InputData)
		BEGIN
			SELECT TOP 1 @IdAgent=[IdAgent], @AmountToPay=[AmountToPay], @SpecialCommToApply=[SpecialCommissionToApply], @note=[note] FROM #InputData

			IF @AmountToPay <> 0
			BEGIN
				EXEC [Corp].[st_SaveDeposit]
				@IsSpanishLanguage,
				@IdAgent,
				@BankName,
				@AmountToPay,
				@ApplyDate,
				@note,
				@IdUser,
				5,
				@HasError OUTPUT,
				@Message OUTPUT,
				@BonusConcept = NULL

				--Insertar registro en pagos
				INSERT INTO [dbo].[AgentCommisionCollection] ([IdAgent], [Commission], [DateOfCollection], [EnterByIdUser], [Note], [IdCommisionCollectionConcept])
					VALUES (@IdAgent, @AmountToPay, @ApplyDate, @IdUser, @Note, 2)
			END

			IF @SpecialCommToApply <> 0
			BEGIN
				EXEC [Corp].[st_SaveDeposit]
					@IsSpanishLanguage,
					@IdAgent,
					@BankName,
					@SpecialCommToApply,
					@ApplyDate,
					@note,
					@IdUser,
					5,
					@HasError OUTPUT,
					@Message OUTPUT,
					@BonusConcept = 'Bonus'

				--Insertar registro en pagos
				INSERT INTO [dbo].[AgentSpecialCommCollection] ([IdAgent], [SpecialCommission], [DateOfCollection], [EnterByUserId], [Note], [ApplyDate], [SpecialCommissionConceptId])
					VALUES (@IdAgent, @SpecialCommToApply, @ApplyDate, @IdUser, @Note, GETDATE(), 1) -- 1 For Commissions Collection

			END

			DELETE #InputData WHERE [IdAgent] = @IdAgent

		END


	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SELECT @Message = ERROR_MESSAGE()
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ApplyCollectByCommission', GETDATE(), @ErrorMessage)
	END CATCH
