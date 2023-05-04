CREATE PROCEDURE [dbo].[st_OtherProductToAgentBalance]
(        
    @IdTransaction INT,
    @IdOtherProduct INT,
    @IdAgent INT,
    @IsDebit BIT,
    @Amount MONEY,
    @Description NVARCHAR(MAX),
    @Country NVARCHAR(MAX),
    @Commission MONEY,
    @AgentCommission MONEY,
    @CorpCommission MONEY,
    @FxFee MONEY,
    @Fee MONEY,
    @ProviderFee MONEY    
)        
AS        
SET NOCOUNT ON
BEGIN TRY
	DECLARE @DateOfMovement DATETIME,
			@Reference INT,
			@Balance MONEY,
			@DebitOrCredit NVARCHAR(MAX),
			@TypeOfMovement NVARCHAR(MAX),
			@IdAgentBalance INT,
			@IsMonthly BIT
        
	SET @Balance=0

	IF(@IsDebit=1)
	BEGIN
		SET @DebitOrCredit='Debit'
	END
	ELSE
	BEGIN
		SET @DebitOrCredit='Credit'
		SET @Amount=@Amount*(-1)
		SET @AgentCommission=@AgentCommission*(-1)    
		SET @CorpCommission=@CorpCommission*(-1)
		SET @Commission=@Commission*(-1)
		SET @Fee=@Fee*(-1)
		SET @FxFee=@FxFee*(-1)
		SET @ProviderFee=@ProviderFee*(-1)

	END
        
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[AgentCurrentBalance] WITH (NOLOCK) WHERE [IdAgent]=@IdAgent)
	BEGIN
	  INSERT INTO [dbo].[AgentCurrentBalance] ([IdAgent], [Balance]) VALUES (@IdAgent,@Balance)
	END

	SET @DateOfMovement = GETDATE()
	SET @Reference=@IdTransaction

	SET @TypeOfMovement=[dbo].[fn_GetOtherProductTypeOfMovement](@IdOtherProduct,@IsDebit)

	IF ISNULL(@TypeOfMovement,'')='' OR isnull(@DebitOrCredit,'')=''
		RETURN
		
	SELECT @IsMonthly= CASE WHEN [IDAgentPaymentSchema]=1 THEN 1 ELSE 0 END FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgent]=@IdAgent

	IF @IsDebit=0
	BEGIN
		SELECT TOP 1 @IsMonthly=[IsMonthly] FROM [dbo].[AgentBalance] WITH (NOLOCK) WHERE [IdAgent]=@IdAgent AND [IdTransfer]=@IdTransaction AND [TypeOfMovement]=@TypeOfMovement ORDER BY [IdAgentBalance] DESC
		SET @IsMonthly=isnull(@IsMonthly,1)
	END

	UPDATE [dbo].[AgentCurrentBalance] SET [Balance]=[Balance]+@Amount,@Balance=[Balance]+@Amount WHERE [IdAgent]=@IdAgent
        
	INSERT INTO [dbo].[AgentBalance]
	(        
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
		[IsMonthly]
	)
	VALUES
	(
		@IdAgent,
		@TypeOfMovement,
		@DateOfMovement,
		abs(@Amount),
		@Reference,
		isnull(@Description,''),
		isnull(@Country,''),
		@AgentCommission,
		@FxFee,
		@DebitOrCredit,
		@Balance,
		@IdTransaction,
		@IsMonthly
	)

	SET @IdAgentBalance = SCOPE_IDENTITY()

	IF @IsMonthly=1
	BEGIN
		INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount,@Amount-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)    
	END
	ELSE
	BEGIN
		IF @IdOtherProduct IN  (9,10,11,12,13,14,16)
		BEGIN
			 INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount+@AgentCommission,@Amount+@AgentCommission-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)
		END
		ELSE IF @IdOtherProduct = 17
			INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount,@Amount-@CorpCommission,@Fee,@ProviderFee, @CorpCommission)  
		ELSE
		BEGIN
			INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount,@Amount-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)  
		END
	END

	--EXEC st_GetAgentCreditApproval @IdAgent

	 --Validar CurrentBalance
	EXEC [dbo].[st_AgentVerifyCreditLimit] @IdAgent

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure],[ErrorDate],[ErrorMessage])VALUES('st_OtherProductToAgentBalance',GETDATE(),@ErrorMessage)
END CATCH

