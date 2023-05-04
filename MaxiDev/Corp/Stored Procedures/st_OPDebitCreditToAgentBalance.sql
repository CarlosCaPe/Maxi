CREATE PROCEDURE [Corp].[st_OPDebitCreditToAgentBalance]
	-- Add the parameters for the stored procedure here
	@IdAgent INT,
	@Amount MONEY,
	@IdReference INT,
	@Reference INT,
	@Description NVARCHAR(MAX),
	@Commission MONEY, -- Agent commission
	@OperationType NVARCHAR(MAX),
	@DebitOrCredit NVARCHAR(MAX),
	@CGS MONEY,
	@Fee MONEY,
	@ProviderFee MONEY,
	@CorpCommission MONEY
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


    -- Insert statements for procedure here
	DECLARE @IsMonthly BIT,
			@DateOfMovement DATETIME,
			@Country NVARCHAR(MAX),
			@Balance MONEY,
			@FxFee MONEY,
			@IdAgentBalance INT,
			@TotalAmount MONEY
                  
                  
	SELECT
		@DateOfMovement=GETDATE(),
		@Country = '',
		@FxFee = 0,
		@Balance = 0,
		@TotalAmount = @Amount

	SELECT @IsMonthly = CASE WHEN [IdAgentPaymentSchema] = 1 THEN 1 ELSE 0 END FROM [dbo].[Agent] WITH(NOLOCK) WHERE [IdAgent] = @idAgent
                   
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[AgentCurrentBalance] WITH(NOLOCK) WHERE [IdAgent] = @IdAgent)
		INSERT INTO [dbo].[AgentCurrentBalance] (IdAgent,Balance) VALUES (@IdAgent,@Balance)
             
	IF @IsMonthly = 1
	BEGIN
		IF @DebitOrCredit = 'Debit'
		BEGIN
			UPDATE [dbo].[AgentCurrentBalance] SET [Balance] = [Balance] + @Amount, @Balance = [Balance] + @Amount WHERE [IdAgent] = @IdAgent
		END
                     
		IF @DebitOrCredit = 'Credit'
		BEGIN
			UPDATE [dbo].[AgentCurrentBalance] SET [Balance] = [Balance] - @Amount, @Balance = [Balance] - @Amount WHERE [IdAgent] = @IdAgent
			SET @Commission = @Commission * - 1 -- se convierte negativa la comission por se crédito
		END
	END
	ELSE
	BEGIN
		IF @DebitOrCredit = 'Debit'
		BEGIN
			UPDATE [dbo].[AgentCurrentBalance] SET [Balance] = [Balance] + ((@Amount - @Commission)), @Balance = [Balance] + ((@Amount - @Commission)) WHERE [IdAgent] = @IdAgent
			SET @Amount = @amount - @Commission
		END
		IF @DebitOrCredit = 'Credit'
		BEGIN
			UPDATE [dbo].[AgentCurrentBalance] SET [Balance] = [Balance] - ((@Amount - @Commission )), @Balance = [Balance] - ((@Amount - @Commission )) WHERE [IdAgent] = @IdAgent
			SET @Amount = @amount - @Commission
			SET @Commission= @Commission*-1 -- se convierte negativa la comission por se crédito
		END
	END
	
	                  
	/* Obtener el balance actualizado de la tabla para insertarse en el registro de agent balance */        
	--SELECT @Balance = [Balance] FROM [dbo].[AgentCurrentBalance] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent
           
	INSERT INTO [dbo].[AgentBalance](
		IdAgent,
		TypeOfMovement,
		DateOfMovement,
		Amount,
		Reference,
		Description,
		Country,
		Commission,
		FxFee,
		DebitOrCredit,
		Balance,
		IdTransfer,
		IsMonthly)
	VALUES(                  
		@IdAgent,
		@OperationType,
		@DateOfMovement,
		@Amount,
		@Reference,
		@Description,
		@Country,
		@Commission,
		@FxFee,
		@DebitOrCredit,
		@Balance,
		@IdReference,
		@IsMonthly)
    
	SELECT @IdAgentBalance = SCOPE_IDENTITY()
    
	IF @DebitOrCredit = 'Credit'
	BEGIN
		SELECT @TotalAmount=@TotalAmount*-1,
			@CGS=@CGS*-1,
			@Fee=@Fee*-1,
			@ProviderFee=@ProviderFee*-1,
			@CorpCommission=@CorpCommission*-1
	END
	    
	INSERT INTO [dbo].[AgentBalanceDetail](
		IdAgentBalance,
		TotalAmount,
		CGS,
		Fee,
		ProviderFee,
		CorpCommission)
	VALUES(
		@IdAgentBalance,
		@TotalAmount,
		@CGS,
		@Fee,
		@ProviderFee,
		@CorpCommission)
       
	--EXEC st_GetAgentCreditApproval @IdAgent

	--Validar CurrentBalance
	
	EXEC [Corp].[st_AgentVerifyCreditLimit] @IdAgent
	      
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_OPDebitCreditToAgentBalance', GETDATE(), @ErrorMessage)
END CATCH
