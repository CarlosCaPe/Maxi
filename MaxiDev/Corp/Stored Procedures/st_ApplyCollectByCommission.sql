﻿CREATE PROCEDURE [Corp].[st_ApplyCollectByCommission]
(
    @DataXml XML,
    @IdUser INT,
    @ApplyDate DATETIME,
    @IsSpanishLanguage BIT,
    @HasError BIT OUTPUT,
    @Message VARCHAR(MAX) OUTPUT
)
AS 


/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/09/08" Author="amoreno"> S38:: Apply the special commission to the total amount</log>
<log Date="2019/11/28" Author="jgomez"> Fix:Ticket 611: Excluir Bonus de la seccion Deposits, Credits and Charges en el reporte AgentBlanceOld</log>
</ChangeLog>
********************************************************************/  

	--Declaracion de variables
	--DECLARE @IdAgent INT
	DECLARE @AmountToPay MONEY
	DECLARE @Fee MONEY
	DECLARE @AmountExpected MONEY
	DECLARE @IdCollectByCommission INT
	DECLARE @DocHandle INT 
	DECLARE @IdAgent INT
	DECLARE @IdAgentCollection INT
	DECLARE @LastAmountToPay MONEY 
	DECLARE @ActualAmountToPay MONEY
	declare @note VARCHAR(MAX)
		
 	declare  @SpecialCommissionToApply money 
 	declare @ActualAmountToPayTemp money
 	declare @BanNoDeposito bit
 	
	CREATE TABLE #InputData(
		[IdCollectByCommission] INT IDENTITY(1,1),
		[IdAgent] INT,
		[IdAgentCollection] INT ,
		[AmountToPay] MONEY,
		[Fee] MONEY,
		[AmountExpected] MONEY,
		[SpecialCommissionToApply] MONEY,
		[Note] NVARCHAR(MAX)
		)

	CREATE TABLE #CollectByCommission
	(
		[IdCollectByCommission] INT IDENTITY(1,1),
		[IdAgent] INT,
		[IdAgentCollection] INT ,
		[AmountToPay] MONEY,
		[Fee] MONEY,
		[AmountExpected] MONEY,
		[Note] NVARCHAR(MAX) 
	)

	CREATE TABLE #SpecialCommission
	(
		[IdSpecialCommission] INT IDENTITY(1,1),
		[IdAgent] INT,
		[SpecialCommissionToApply] MONEY,
		[Note] NVARCHAR(MAX)
	)

	-- Tabla para insertar Bonos
	CREATE TABLE #SpecialCommission2
	(
		[IdSpecialCommission] INT IDENTITY(1,1),
		[IdAgent] INT,
		[IdAgentCollection] INT ,
		[SpecialCommissionToApply] MONEY,
		[Note] NVARCHAR(MAX)
	)


	--Inicializacion de variables
	SET @HasError=0
	SET @Message='Apply by Commission Sucessfull'

	SELECT @ApplyDate=dbo.RemoveTimeFromDatetime(@ApplyDate)  

	BEGIN TRY

		DECLARE @HasErrorTmp BIT
		DECLARE @MessageTmp  VARCHAR(MAX)
  
		EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DataXml   

		INSERT INTO #InputData
			SELECT
				A.[IdAgent]
				, X.[IdAgentCollection]
				, X.[AmountToPay]-A.[Fee]
				, A.[Fee]
				, X.[AmountExpected]
				, X.[SpecialCommissionToApply]
				, X.[Note]
			FROM OPENXML (@DocHandle, '/CollectionByCommissions/CollectionByCommission', 2) 
			WITH (              
				[IdAgentCollection] INT,        
				[AmountExpected] MONEY,
				[AmountToPay] MONEY,
				[SpecialCommissionToApply] MONEY,
				[Note] NVARCHAR(MAX)
			) X
			JOIN [dbo].[AgentCollection] A ON X.[IdAgentCollection] = A.[IdAgentCollection]
		
		INSERT INTO #CollectByCommission
			SELECT 
				[IdAgent]
				, [IdAgentCollection]
				, [AmountToPay]
				, [Fee]
				, [AmountExpected]
				, [Note]
			FROM #InputData
			WHERE [AmountToPay] != 0

		-- Tabla para insertar Bonos
		DECLARE @SpecialCommToApply2 MONEY
		INSERT INTO #SpecialCommission2
			SELECT
				[IdAgent],
				[IdAgentCollection],
				[SpecialCommissionToApply],
				[Note]
			FROM #InputData
			WHERE [SpecialCommissionToApply] != 0

		SELECT TOP 1  @SpecialCommToApply2=[SpecialCommissionToApply], @note=[note] FROM #SpecialCommission2

		--Ciclo para aplicar los movimientos
		WHILE EXISTS (SELECT TOP 1 1 FROM #CollectByCommission)
		BEGIN
			
			SELECT TOP 1
				@IdAgent = [IdAgent]
				, @AmountExpected = [AmountExpected]
				, @AmountToPay = [AmountToPay]
				, @Fee = [Fee]
				, @IdAgentCollection = [IdAgentCollection]
				, @IdCollectByCommission = [IdCollectByCommission]
				, @note = [Note] FROM #CollectByCommission
    
			IF EXISTS (SELECT TOP 1 1 FROM [dbo].[AgentCommisionCollection] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent AND [dbo].[RemoveTimeFromDatetime]([DateOfCollection]) = [dbo].[RemoveTimeFromDatetime](@ApplyDate) AND [IdCommisionCollectionConcept] = 1)
			BEGIN
				DELETE #CollectByCommission WHERE [IdCollectByCommission] = @IdCollectByCommission
				CONTINUE;
			END
       
			--Agregar pago a detalle

			--Obtener ultimo adeudo
			SELECT TOP 1 @ActualAmountToPay = [ActualAmountToPay] FROM [dbo].[AgentCollectionDetail] WITH (NOLOCK) WHERE [IdAgentCollection] = @IdAgentCollection ORDER BY [IdAgentCollectiondetail] DESC
			SET @ActualAmountToPay = ISNULL(@ActualAmountToPay,0)
			SET @AmountExpected = ISNULL(@AmountExpected,0)
			
			--Calcular Montos
			SET @LastAmountToPay = @ActualAmountToPay
			SET @ActualAmountToPay = @ActualAmountToPay-@AmountToPay-@Fee 

    
    

		----******Test*-------
		

		select top 1 @SpecialCommissionToApply=SpecialCommissionToApply   from #InputData
		
		select @ActualAmountToPayTemp = @ActualAmountToPay - @SpecialCommissionToApply
			
  	if @ActualAmountToPayTemp>=0
  	begin 
  	 set  @ActualAmountToPay =@ActualAmountToPayTemp
   
  	 set @BanNoDeposito=1
  	end
			
			--********--
			if(@SpecialCommToApply2 != 0) --- Solo cuando se aplica el bonos ticket 611
			BEGIN
			set @ActualAmountToPay =@ActualAmountToPay+@SpecialCommToApply2
			END
    
    
    
			--set @Note = 'Commissions Applied to Deferred Balance' + case when isnull(@Note,'')='' then '' else ' - '+@Note end

			DECLARE @CommNote NVARCHAR(MAX)
			SET @CommNote = '4406-33 Deferred Plan Payment - Commission' + CASE WHEN ISNULL(@Note,'') = '' THEN '' ELSE ' - ' + @Note END

			INSERT INTO [dbo].[AgentCollectionDetail]
				([IdAgentCollection],
				[LastAmountToPay],
				[ActualAmountToPay],
				[AmountToPay],
				[Note],
				[IdAgentCollectionConcept],
				[CreationDate],
				[DateofLastChange],
				[EnterByIdUser],
				AmountExpected
				)
			VALUES
				(@IdAgentCollection,
				@LastAmountToPay,
				@ActualAmountToPay,
				@AmountToPay+@Fee,
				@CommNote,
				4, --@IdAgentCollectionConcept --Commission
				GETDATE(),
				GETDATE(),
				@IdUser,
				@AmountExpected
				)


			if (@BanNoDeposito=1)
			begin 
						--Actualizar adeudo del agente
						UPDATE [dbo].[AgentCollection]
							SET
								[DateofLastChange] = GETDATE(),
								[EnterByIdUser] = @IdUser,
								[AmountToPay] = [AmountToPay] - @SpecialCommissionToApply
								
			end








			--Obtener ultimo adeudo fee
			IF (ISNULL(@Fee,0)>0)
			BEGIN
				SELECT TOP 1 @ActualAmountToPay = [ActualAmountToPay] FROM [dbo].[AgentCollectionDetail] WITH (NOLOCK) WHERE [IdAgentCollection] = @IdAgentCollection ORDER BY [IdAgentCollectiondetail] DESC
				SET @ActualAmountToPay = ISNULL(@ActualAmountToPay,0)
				SET @AmountExpected = ISNULL(@AmountExpected,0)

				--Calcular Montos fee
				SET @LastAmountToPay = @ActualAmountToPay
				SET @ActualAmountToPay = @ActualAmountToPay+@Fee

				DECLARE @FeeNote NVARCHAR(MAX)
				SET @FeeNote = '4407-32 Deferred Plan Fee - Commission' + CASE WHEN ISNULL(@Note,'') = '' THEN '' ELSE ' - ' + @Note END

				INSERT INTO [dbo].[AgentCollectionDetail]
					([IdAgentCollection],
					[LastAmountToPay],
					[ActualAmountToPay],
					[AmountToPay],
					[Note],
					[IdAgentCollectionConcept],
					[CreationDate],
					[DateofLastChange],
					[EnterByIdUser],
					AmountExpected
					)
				VALUES
					(@IdAgentCollection,
					@LastAmountToPay,
					@ActualAmountToPay,
					-@Fee,
					@FeeNote, --'Deferred Balance Fee',
					4, --@IdAgentCollectionConcept --Commission
					GETDATE(),
					GETDATE(),
					@IdUser,
					-@Fee
					)
			END
        
			--Actualizar adeudo del agente
			UPDATE [dbo].[AgentCollection]
				SET
					[DateofLastChange] = GETDATE(),
					[EnterByIdUser] = @IdUser,
					[AmountToPay] = [AmountToPay] - @AmountToPay
					
				WHERE
					[IdAgentCollection] = @IdAgentCollection

			--Insertar registro en pagos
			SET @Note = 'Commissions Applied to Deferred Balance' + CASE WHEN ISNULL(@Note,'')='' THEN '' ELSE ' - '+@Note END
			INSERT INTO [dbo].[AgentCommisionCollection] ([IdAgent], [Commission], [DateOfCollection], [EnterByIdUser], [Note], [IdCommisionCollectionConcept])
				VALUES (@IdAgent,@AmountToPay+@Fee,@ApplyDate,@IdUser,@Note,1)
    
			DELETE #CollectByCommission WHERE [IdCollectByCommission] = @IdCollectByCommission

				--aplicar movimientos a balance
		  --      Declare @Date datetime
		  --      SELECT @date = GETDATE()

		  --      EXEC [dbo].[st_SaveDeb]
				--@IsSpanishLanguage,
				--@IdAgent,
				--@AmountToPay,
				--1,      --IsDebit=
				--@date,
				--N'Charge by Calendar Commission Collection',
				--'',--@IdCalendarCollect,
				--@IdUser,
				--@HasErrorTMP OUTPUT,
				--@MessageTMP OUTPUT

		  --      EXEC [dbo].[st_SaveOtherCharge]
				--@IsSpanishLanguage,
				--@IdAgent,
				--@Fee,
				--1,      --IsDebit=
				--@date,
				--N'Fee by Calendar Commission Collection',
				--'',--@IdCalendarCollect,
				--@IdUser,
				--@HasErrorTMP OUTPUT,
				--@MessageTMP OUTPUT

		  --      declare  @tot money = @AmountToPay+@Fee

		  --      exec [dbo].[st_SaveDeposit] 
		  --          @IsSpanishLanguage,
		  --          @IdAgent,
		  --          'Calendar Commission Collection',
		  --          @tot,
		  --          @ApplyDate,
		  --     @note,
		  --          @IdUser,
		  --          5,
		  --          @HasErrorTMP out,
		  --          @MessageTMP out

		END

		-- Aply special commissions

		INSERT INTO #SpecialCommission
			SELECT
				[IdAgent],
				[SpecialCommissionToApply],
				[Note]
			FROM #InputData
			WHERE [SpecialCommissionToApply] != 0
			
			
 	 if @BanNoDeposito=1
    begin 
   	 DELETE #SpecialCommission WHERE [IdAgent] = @IdAgent
   	end 
   	   			
		
		DECLARE @SpecialCommToApply MONEY
		DECLARE @IdBank INT
		DECLARE @BankName NVARCHAR(MAX)
		DECLARE @Enviroment NVARCHAR(MAX)

		SELECT @IdBank = CONVERT(INT,[dbo].[GetGlobalAttributeByName]('DefaultBankCommission'))
		SELECT @BankName = [Bankname] FROM [dbo].[AgentBankDeposit] WITH (NOLOCK) WHERE [Idagentbankdeposit] = @IdBank
		SET @BankName = ISNULL(@BankName,'Barter')
		SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')

		SELECT @IdAgent = NULL, @note = NULL

		--solo qa
		IF @Enviroment <> 'Production'
			SET @ApplyDate=GETDATE()-1

		WHILE EXISTS(SELECT TOP 1 1 FROM #SpecialCommission)
		BEGIN
			SELECT TOP 1 @IdAgent=[IdAgent], @SpecialCommToApply=[SpecialCommissionToApply], @note=[note] FROM #SpecialCommission

			--EXEC [dbo].[st_SaveDeposit] 
			--		@IsSpanishLanguage,
			--		@IdAgent,
			--		@BankName,
			--		@SpecialCommToApply,
			--		@ApplyDate,
			--		@note,
			--		@IdUser,
			--		5,
			--		@HasError OUTPUT,
			--		@Message OUTPUT,
			--		@BonusConcept = 'Bonus'

			--Insertar registro en pagos
			INSERT INTO [dbo].[AgentSpecialCommCollection] ([IdAgent], [SpecialCommission], [DateOfCollection], [EnterByUserId], [Note], [ApplyDate], [SpecialCommissionConceptId])
					VALUES (@IdAgent, @SpecialCommToApply, @ApplyDate, @IdUser, @Note, GETDATE(), 2) -- 2 For Collect Plan By Commission

			DELETE #SpecialCommission WHERE [IdAgent] = @IdAgent

		END

----- bonus ticket 611

		WHILE EXISTS(SELECT TOP 1 1 FROM #SpecialCommission2)
		BEGIN
	      -- SELECT TOP 1 @ActualAmountToPay = [ActualAmountToPay] FROM [dbo].[AgentCollectionDetail] WITH (NOLOCK) WHERE [IdAgentCollection] = @IdAgentCollection ORDER BY [IdAgentCollectiondetail] DESC
		--	SET @LastAmountToPay = @ActualAmountToPay
			SELECT @IdAgentCollection = NULL, @note = NULL
			SELECT TOP 1 @IdAgentCollection=[IdAgentCollection], @SpecialCommToApply2=[SpecialCommissionToApply], @note=[note] FROM #SpecialCommission2
		  --SELECT @ActualAmountToPay = @ActualAmountToPay - @SpecialCommToApply2
			
			SELECT TOP 1 @ActualAmountToPay = [ActualAmountToPay] FROM [dbo].[AgentCollectionDetail] WITH (NOLOCK) WHERE [IdAgentCollection] = @IdAgentCollection ORDER BY [IdAgentCollectiondetail] DESC
				SET @ActualAmountToPay = ISNULL(@ActualAmountToPay,0)
				SET @AmountExpected = ISNULL(@AmountExpected,0)

				--Calcular Montos fee
				SET @LastAmountToPay = @ActualAmountToPay
				SET @ActualAmountToPay = @ActualAmountToPay - @SpecialCommToApply2

			--SELECT TOP 1 @IdAgentCollection=esp.[IdAgentCollection] from #SpecialCommission2 esp inner join #CollectByCommission cm on esp.IdAgentCollection = cm.IdAgentCollection

			DECLARE @BonusNote NVARCHAR(MAX)
			SET @BonusNote = 'Deferred Plan Payment - Period' 
			
			INSERT INTO [dbo].[AgentCollectionDetail]
				([IdAgentCollection],
				[LastAmountToPay],
				[ActualAmountToPay],
				[AmountToPay],
				[Note],
				[IdAgentCollectionConcept],
				[CreationDate],
				[DateofLastChange],
				[EnterByIdUser],
				AmountExpected
				)
			VALUES
				(@IdAgentCollection,
				@LastAmountToPay,
				@ActualAmountToPay,
				@SpecialCommToApply2, --- @AmountToPay+@Fee,
				@BonusNote,
				4, --@IdAgentCollectionConcept --Commission
				GETDATE(),
				GETDATE(),
				@IdUser,
				@AmountExpected)

			DELETE #SpecialCommission2 WHERE [IdAgentCollection] = @IdAgentCollection
		
		END
		
--- end bonus ticket 611

	END TRY
	BEGIN CATCH
		SET @HasError=1                                                                                   
		SELECT @Message = ERROR_MESSAGE()                                                                                 
		DECLARE @ErrorMessage NVARCHAR(MAX)                                                                                             
		SELECT @ErrorMessage=ERROR_MESSAGE()                                             
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ApplyCollectByCommission', GETDATE(), @ErrorMessage)    
	END CATCH




