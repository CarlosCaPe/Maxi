CREATE PROCEDURE [dbo].[st_GetAvailablePayers]
(
	@IdAgent			INT,
	@IdAgentSchema		INT,
	@IdPaymentType		INT,
	@IdCity				INT,
	@Amount				MONEY,
	@IsAmountDollars	BIT,
	@IdPayerConfig		INT = NULL
)
AS
BEGIN
	
	IF @IdPayerConfig IS NOT NULL
		EXEC st_PayerBySchemaByIdPayerConfig @IdAgent, @IdAgentSchema, @IdPaymentType, @Amount, @IsAmountDollars, @IdPayerConfig
	-- Deposit
	ELSE IF @IdPaymentType IN (2) 
		EXEC st_PayerToDepositBySchemaWithAmount @IdAgent, @IdAgentSchema, @Amount, @IsAmountDollars, @IdCity
	-- MobileWallet, ATM
	ELSE IF @IdPaymentType IN (5) 
		EXEC st_PayerToMobileWalletBySchemaWithAmount @IdAgent, @IdAgentSchema, @Amount, @IsAmountDollars, @IdCity
	-- Others
	ELSE
		EXEC st_PayerBySchemaWithAmount @IdAgent, @IdAgentSchema, @IdCity, @IdPaymentType, @Amount, @IsAmountDollars
END