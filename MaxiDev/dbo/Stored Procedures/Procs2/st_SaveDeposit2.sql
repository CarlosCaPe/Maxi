CREATE PROCEDURE [dbo].[st_SaveDeposit2]
	@IsSpanishLanguage BIT,
	@IdAgent INT,
	@BankName NVARCHAR(MAX),
	@Amount MONEY,
	@DepositDate DATETIME,
	@Notes NVARCHAR(MAX),          
	@EnterByIdUser INT,
	@IdAgentCollectType INT,
	@HasError BIT OUTPUT,
	@Message VARCHAR(MAX) OUTPUT,
	@ReferenceNumber NVARCHAR(MAX) = NULL,
	@BonusConcept NVARCHAR(MAX) = NULL
AS

	IF @Amount = 0
	BEGIN
		SET @HasError = 0
		SELECT @Message = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLanguage,14)
		RETURN
	END
        
	BEGIN TRY
		DECLARE @Balance MONEY
		DECLARE @PositiveAmount MONEY
		DECLARE @TypeOfCharge NVARCHAR(10)
		DECLARE @IdAgentBalance INT
		DECLARE @Enviroment NVARCHAR(MAX)

		SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')

		SET @Balance = 0

		SET @Notes = ISNULL(@Notes,'')

		--------------------- Modify Agent current balance -------------------------------           
         
		IF NOT EXISTS(SELECT 1 FROM [dbo].[AgentCurrentBalance] WITH(NOLOCK) WHERE [IdAgent] = @IdAgent)
		BEGIN
			INSERT INTO [dbo].[AgentCurrentBalance] ([IdAgent], [Balance]) VALUES (@IdAgent,@Balance)
		END
          
		UPDATE [dbo].[AgentCurrentBalance] SET [Balance]=[Balance]-@Amount, @Balance=[Balance]-@Amount WHERE [IdAgent]=@IdAgent
   
		--------------------- Debit or Credit ----------------------------------------------          
		IF @Amount > 0
		BEGIN
			SET @TypeOfCharge='Credit'
			SET @PositiveAmount=@Amount
		END        
		ELSE
		BEGIN
			SET @TypeOfCharge='Debit'
			SET @PositiveAmount=@Amount*-1
		END

		---------------------- Check for special commission apply concept  ------------------------------------

		DECLARE @DescriptionText NVARCHAR(MAX)

		IF LTRIM(ISNULL(@BonusConcept,'')) <> ''
			SET @DescriptionText = @BonusConcept
		ELSE
			SET @DescriptionText = @BankName

		/*S52 - Cambio de estado(status) de agencia - 20161214*/
		DECLARE @CollectDate DateTime = GETDATE();

		---------------------- Insert into Agent balance ------------------------------------        

		INSERT INTO [dbo].[AgentBalance](
			[IdAgent],
			[TypeOfMovement],
			[DateOfMovement],
			[Amount],
			[Reference],
			[Description],
			[Country],
			[Commission],
			[FxFee],
			[DebitOrCredit],
			[Balance],
			[IdTransfer])
		VALUES(
			@IdAgent,          
			'DEP',          
			GETDATE(),          
			@PositiveAmount,          
			'',          
			@DescriptionText,          
			'',          
			0,
			0,          
			@TypeOfCharge,          
			@Balance,          
			0)          
        
		SELECT @IdAgentBalance=SCOPE_IDENTITY()

		-------------------------------- Insert in to Other Charges ---------------------------        
        
		INSERT INTO [dbo].[AgentDeposit](
			[IdAgent],
			[IdAgentBalance],
			[BankName],
			[Amount],
			[DepositDate],
			[Notes],
			[DateOfLastChange],
			[EnterByIdUser],
			[IdAgentCollectType],
			[ReferenceNumber])
		VALUES(        
			@IdAgent,
			@IdAgentBalance,
			@BankName,
			@Amount,
			@DepositDate,
			@Notes,
			@CollectDate, --GETDATE(), /* Fgonzalez se manda la misma fecha que al validador de agentes */
			@EnterByIdUser,
			@IdAgentCollectType,
			@ReferenceNumber)
         
		SET @HasError = 0
		SELECT @Message = [dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,14)

		--Validar CurrentBalance
		EXEC [dbo].[st_AgentVerifyCreditLimit] @IdAgent

		--ajuste maxicollection
		DECLARE @maxicollectiondate DATETIME
		SET @maxicollectiondate = GETDATE()
		EXEC [dbo].[st_ApplyDepositMaxicollectionForWeekend] @idagent, @maxicollectiondate, @Amount

		--Notificacion de pago
		DECLARE @HasErrorNotification BIT
		DECLARE @MessageErrorNotification NVARCHAR(MAX)

		EXEC [msg].[st_AgentNotificationPaymentThanks]
			@Idagent,
			@HasErrorNotification OUTPUT,
			@MessageErrorNotification OUTPUT

		--Call history message
		DECLARE @TodayDate DATETIME
		DECLARE @TotalAmount MONEY
		DECLARE @TotalDeposit MONEY
		DECLARE @HError BIT
		DECLARE @HMessage NVARCHAR(MAX)
		DECLARE @UserSystem INT

		SET @UserSystem = CONVERT(INT,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

		SET @TodayDate = [dbo].[RemoveTimeFromDatetime](GETDATE())

		SELECT @TotalAmount = SUM([Amount]) FROM [dbo].[MaxiCollection] WITH (NOLOCK) WHERE [IdAgent] = @idagent AND [DateOfCollection] = @TodayDate GROUP BY [IdAgent]

		SELECT @TotalDeposit = SUM([Amount]) FROM [dbo].[AgentDeposit] WITH (NOLOCK) WHERE [IdAgent] = @idagent AND [dbo].[RemoveTimeFromDatetime]([DateOfLastChange]) = @TodayDate GROUP BY [IdAgent]

		IF ROUND(@TotalDeposit,2) >= ROUND(@TotalAmount,2)
		BEGIN
			EXEC [dbo].[st_AddNoteToCallHistory]
				@idagent,
				@UserSystem,
				3,  --closed
				'Closed by System',
				@IsSpanishLanguage,
				@HError,
				@HMessage,
				0
		END

		/*S52 - Cambio de estado(status) de agencia*/
		--DECLARE @CollectDate DateTime = GETDATE();
		EXEC st_AgentStatusException @CollectDate,@IdAgent,@Amount,@EnterByIdUser;
		/*-----------------------------------------*/
		
		--mandar correo
		DECLARE @recipients NVARCHAR(MAX)
		DECLARE @EmailProfile NVARCHAR(MAX)
		DECLARE @body NVARCHAR(MAX)
		DECLARE @Subject NVARCHAR(MAX)
		DECLARE @AgentCode NVARCHAR(MAX)=' '
		DECLARE @IdAgentStatus INT
		DECLARE @AgentStatusName NVARCHAR(MAX)=' '
		DECLARE @AgentName NVARCHAR(MAX)=' '

		SELECT @AgentCode=[AgentCode], @IdAgentStatus=A.[IdAgentStatus], @AgentStatusName=UPPER([AgentStatus]), @AgentName=[AgentName]
		FROM [dbo].[Agent] A WITH (NOLOCK)
		JOIN [dbo].[AgentStatus] S WITH (NOLOCK) ON A.[IdAgentStatus]=S.[IdAgentStatus]
		WHERE [IdAgent] = @IdAgent

		--FGONZALEZ 20161117
		DECLARE @ProcID VARCHAR(200)
		SET @ProcID =OBJECT_NAME(@@PROCID)

		IF (@IdAgentStatus=3 OR @IdAgentStatus=4 OR @IdAgentStatus=7)
		BEGIN
			IF @Enviroment = 'Production'
				SELECT @recipients = 'cob@maxi-ms.com'
			ELSE
				SELECT @recipients = 'soportemaxi@boz.mx'

			SELECT @body = 'A payment of $ ' + CONVERT(VARCHAR,@Amount) + ' was received for Agent '+ ISNULL(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
			SELECT @Subject = 'Agent ' + ISNULL(@AgentCode,'') + ', ' + @AgentStatusName + ', Deposited $ '+ CONVERT(VARCHAR,@Amount)
	
			SELECT @EmailProfile=Value FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler'
			INSERT INTO [dbo].[EmailCellularLog] VALUES (@recipients,@body,@subject,GETDATE())
			
			--FGONZALEZ 20161117
			EXEC sp_MailQueue 
			@Source   =  @ProcID,
			@To 	  =  @recipients,      
			@Subject  =  @subject,
			@Body  	  =  @body

			/*
			EXEC [msdb].[dbo].sp_send_dbmail
				@profile_name = @EmailProfile,
				@recipients = @recipients,
				@body = @body,
				@subject = @subject
			*/
		END

		--Mandar correo balance negativo
		--IF (ROUND(ISNULL(@Balance,0),2)<0)
		--BEGIN
		--	IF @Enviroment = 'Production'
		--	BEGIN
		--		SELECT @recipients = 'cob@maxi-ms.com'
		--		SELECT @body = 'Agent '+ ISNULL(@AgentCode,'') + ', Balance: - $' + CONVERT(VARCHAR,ROUND((-1)*@Balance,2),1) + ' - Please review because it''s balance is N E G A T I V E !!'
		--		SELECT @subject = 'Agent '+ ISNULL(@AgentCode,'') + ', Balance: - $' + CONVERT(VARCHAR,ROUND((-1)*@Balance,2),1) + ' - Please review because it''s balance is N E G A T I V E !!'
		--	END
		--	ELSE
		--	BEGIN
		--		SELECT @recipients = 'jpadilla@boz.mx; jvelarde@boz.mx;dencina@boz.mx'
		--		select @body = 'The current balance is $ ' + convert(varchar,@Balance) + ' for the Agent '+ isnull(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
		--		select @Subject = 'QA Agent ' + isnull(@AgentCode,'') + ', ' + @AgentStatusName + ', Current Balance $ '+convert(varchar,@Balance)
		--	END
				
		--	IF @Enviroment <> 'Dev'
		--	BEGIN
		--		SELECT @recipients = 'Lsanelias@maxi-ms.com;'
		--		SELECT @EmailProfile = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler'
		--		INSERT INTO [dbo].[EmailCellularLog] VALUES (@recipients,@body,@subject,GETDATE())
				
		--		--FGONZALEZ 20161117
		--		EXEC sp_MailQueue 
		--		@Source   =  @ProcID,
		--		@To 	  =  @recipients,      
		--		@Subject  =  @subject,
		--		@Body  	  =  @body

		--		/*
		--		EXEC [msdb].[dbo].sp_send_dbmail
		--			@profile_name = @EmailProfile,
		--			@recipients = @recipients,
		--			@body = @body,
		--			@subject = @subject
		--		*/
		--	END
		--END

	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SELECT @Message = [dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,15)
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_SaveDeposit', GETDATE(), @ErrorMessage)
	END CATCH



