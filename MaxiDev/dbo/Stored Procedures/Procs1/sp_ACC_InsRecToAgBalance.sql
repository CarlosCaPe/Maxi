-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_ACC_InsRecToAgBalance
	@TypeOfMovement VARCHAR(10),
	@IdTransfer INT,
	@IdUser INT
AS

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
	
BEGIN TRY
	DECLARE @IdAgentBalance INT
	DECLARE @IdAgent INT
	DECLARE @EnterByIdUser INT
	DECLARE @DateOfMovement DATETIME

	DECLARE @DebitOrCredit NVARCHAR(MAX) = ''
	DECLARE @Reference NVARCHAR(MAX) = ''
	DECLARE @Country NVARCHAR(MAX) = ''
	DECLARE @Description NVARCHAR(MAX) = ''

	DECLARE @Amount MONEY = 0
	DECLARE @Balance MONEY = 0
	DECLARE @Total MONEY = 0
	DECLARE @Fee MONEY = 0
	DECLARE @Commission MONEY  = 0
	DECLARE @FxFee MONEY  = 0
	

	DECLARE @Today DATETIME = GETDATE()
	DECLARE @Time DATETIME = @Today
	DECLARE @IdCheck INT = 0


	----------------------------------------
	-- Cheque
	IF @TypeOfMovement='CH'
	BEGIN
		SET @IdCheck = @IdTransfer

		SELECT 
			@Amount = [Amount],
			@Fee  = [Fee],
			@Description = [Name] + ' ' + [FirstLastName] + ' '+ REPLACE([SecondLastName], '.' ,''),
			@IdAgent = [IdAgent],
			@DateOfMovement = [DateOfMovement],
			@EnterByIdUser = [EnteredByIdUser]
		FROM [dbo].[Checks] WITH (NOLOCK)
		WHERE [IdCheck] = @IdTransfer

		SET @DebitOrCredit = 'Credit'
		SET @Total = (@Amount - @Fee) * (-1)
		SET @Reference = @IdTransfer
    END

	----------------------------------------
	-- Check Verification
	IF @TypeOfMovement='CHVF'
	BEGIN
		SELECT
			@Amount  = V.VerificationFee,
			@IdAgent = V.IdAgent,
			@DateOfMovement = V.DateCreated,
			@EnterByIdUser  = V.IdUser,
			@Description = CONCAT( 'ACCT:',RIGHT(V.Account,4),' ABA:',V.Routing,' CH:',V.CheckNum )
		FROM dbo.CC_AccVerifByAg(NOLOCK) V
		LEFT JOIN dbo.Checks(NOLOCK) C ON C.IdCheck = V.IdCheck
		WHERE IdAccVerifByAg = @IdTransfer;

		SET @DebitOrCredit = 'Debit'
		SET @Total = @Amount
		SET @Time  = @DateOfMovement
		SET @Reference = @IdTransfer
    END

	IF ISNULL(@IdTransfer,0) <= 0
		RETURN

	IF ISNULL(@IdAgent,0) <= 0
		RETURN

	IF @DebitOrCredit NOT IN ('Credit','Debit')
		RETURN

	
	--Calc balance
	-------------------
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[AgentCurrentBalance] WITH(NOLOCK) WHERE [IdAgent]=@IdAgent)
		INSERT INTO [dbo].[AgentCurrentBalance] ([IdAgent], [Balance]) VALUES (@IdAgent, @Balance);

	--Resta o Suma dependiendo del signo de @Total
	UPDATE [dbo].[AgentCurrentBalance] SET [Balance] = [Balance] + @Total,  @Balance = [Balance] + @Total  WHERE [IdAgent] = @IdAgent

	------------------

    
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
				@Reference,
				ISNULL(@Description,''),
				@Country,
				@Commission,
				@FxFee,
				@DebitOrCredit,
				@Balance,
				@IdTransfer,
				NULL);

	SET @IdAgentBalance = SCOPE_IDENTITY()

	INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance, @Amount, ABS(@Total), @Fee, 0, 0);

	IF @TypeOfMovement='CH'
	BEGIN
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
			@Description,
			@Time,
			@EnterByIdUser,
			9, -- Check
			NULL);
	END


	--Validar CurrentBalance
    EXEC [dbo].[st_AgentVerifyCreditLimit] @IdAgent;

	--Revisar si aplica para CHVF u otros
	--ajuste maxicollection
	DECLARE @maxicollectiondate DATETIME
	SET @maxicollectiondate = dbo.RemoveTimeFromDatetime(GETDATE() /*+ 5*/)
	declare @TotalForCollection money = ABS(@Total)
	EXEC [dbo].[st_ApplyDepositMaxicollectionForWeekend] @IdAgent, @maxicollectiondate, @TotalForCollection;

	-- Validacion de Cambio de Estatus Agencia
	EXEC st_AgentStatusException @Today, @IdAgent, @Amount ,@EnterByIdUser;
    

	-- Validacion de Cambio de Estatus Agencia
	EXEC st_AgentStatusException @Today, @IdAgent, @Amount, @EnterByIdUser;
	
	/*
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
  */

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('sp_ACC_InsRecToAgBalance', GETDATE(), @ErrorMessage)
END CATCH

