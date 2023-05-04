CREATE PROCEDURE [Checks].[st_CheckApplyToAgentBalance]
(
    @IdCheck INT
)
AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update </log>
</ChangeLog>
********************************************************************/ 

SET NOCOUNT ON;

BEGIN TRY
    DECLARE @Balance MONEY = 0
    DECLARE @Total MONEY
    DECLARE @Amount MONEY
    DECLARE @Fee MONEY
    DECLARE @Name NVARCHAR(MAX)
    DECLARE @IdAgent INT
    DECLARE @DebitCredit NVARCHAR(MAX)= 'Credit'
    DECLARE @TypeOfMovement NVARCHAR(MAX)= 'CH'
    DECLARE @IdAgentBalance INT
	DECLARE @DateOfMovement DATETIME
			, @EnterByIdUser INT
			, @Time DATETIME = GETDATE()

	SELECT 
		@Amount = [Amount],
		@Fee = [Fee],
		@Name = [Name] + ' ' + [FirstLastName] + ' '+ REPLACE([SecondLastName], '.' ,''),
		@IdAgent = [IdAgent],
		@DateOfMovement = [DateOfMovement],
		@EnterByIdUser = [EnteredByIdUser]
	FROM [dbo].[Checks] WITH (NOLOCK)
	WHERE [IdCheck] = @IdCheck
  
	SET @Total=(@Amount-@Fee)*(-1)

	IF @IdAgent IS NULL
		RETURN

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[AgentCurrentBalance] WITH(NOLOCK) WHERE [IdAgent]=@IdAgent)
		INSERT INTO [dbo].[AgentCurrentBalance] ([IdAgent], [Balance]) VALUES (@IdAgent, @Balance);

	UPDATE [dbo].[AgentCurrentBalance] SET [Balance]=[Balance]+@Total, @Balance=[Balance]+@Total WHERE [IdAgent]=@IdAgent;
	   
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
				[IdTransfer],
				[IsMonthly])
			VALUES(
				@IdAgent,
				@TypeOfMovement,
				@Time,
				ABS(@Total),
				@IdCheck,
				ISNULL(@Name,''),
				'',
				0,
				0,
				@DebitCredit,
				@Balance,
				@IdCheck,
				NULL);

	SET @IdAgentBalance = SCOPE_IDENTITY()

	INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount,ABS(@Total),@Fee,0, 0);

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
				'Bank Check ' + CONVERT(NVARCHAR(MAX), @IdCheck),
				ABS(@Total),
				@DateOfMovement, -- Check Date of creation
				@Name,
				@Time,
				@EnterByIdUser,
				9, -- Check
				NULL);


    --Validar CurrentBalance
    EXEC [dbo].[st_AgentVerifyCreditLimit] @IdAgent;

	--ajuste maxicollection
	DECLARE @maxicollectiondate DATETIME
	SET @maxicollectiondate = dbo.RemoveTimeFromDatetime(GETDATE() /*+ 5*/)
	declare @TotalForCollection money = ABS(@Total)
	EXEC [dbo].[st_ApplyDepositMaxicollectionForWeekend] @idagent, @maxicollectiondate, @TotalForCollection;

	-- Validacion de Cambio de Estatus Agencia
	EXEC st_AgentStatusException @Time,@IdAgent,@Amount,@EnterByIdUser;
	
    --Mandar correo balance negativo
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
    WHERE [IdAgent]=@IdAgent

  --  IF(ROUND(ISNULL(@Balance,0),2)<0)
  --  BEGIN

		--DECLARE @Environment NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('Enviroment')
		--IF @Environment = 'Production'
		--	SET @recipients = 'cob@maxi-ms.com'
		--ELSE SET @recipients = ''

  --      SELECT @body = 'Agent '+ ISNULL(@AgentCode,'')+', Balance: - $'+ CONVERT(VARCHAR,ROUND((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'
  --      SELECT @subject = 'Agent '+ ISNULL(@AgentCode,'')+', Balance: - $'+ CONVERT(VARCHAR,ROUND((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'
	
  --      SET @EmailProfile = [dbo].[GetGlobalAttributeByName]('EmailProfiler')
	 --   INSERT INTO [dbo].[EmailCellularLog] VALUES (@recipients,@body,@subject,@Time)
	 --   EXEC msdb.dbo.sp_send_dbmail
		--    @profile_name=@EmailProfile,
		--    @recipients = @recipients,
		--    @body = @body,
		--    @subject = @subject
  --  END

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_OtherProductToAgentBalance', GETDATE(), @ErrorMessage)
END CATCH

