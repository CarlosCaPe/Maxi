CREATE PROCEDURE [Corp].[st_SaveCommissionDetail]
(
    @IdCommissionDetailByProvider INT,
    @IdCommissionByOtherProducts INT,
    @FromAmount	MONEY,
    @ToAmount	MONEY,
    @AgentCommissionInPercentage MONEY,
    @CorporateCommissionInPercentage MONEY,    
    @EnterByIdUser INT,
    @ExtraAmount MONEY,
	@BillerSpecific MONEY,
    @IdCommissionDetailByProviderOut INT OUT,
    @HasError INT OUT,
    @Message NVARCHAR(MAX) OUT
)
AS
SET NOCOUNT ON;
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''
	IF (@IdCommissionDetailByProvider=0)
	
		BEGIN
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveCommissionDetail',Getdate(),CONCAT( '@IdCommissionDetailByProvider', @IdCommissionDetailByProvider , '@BillerSpecific', @BillerSpecific, '@ExtraAmount', @ExtraAmount))    
			INSERT INTO CommissiondetailByOtherProducts (IdCommissionByOtherProducts, FromAmount, ToAmount, AgentCommissionInPercentage, CorporateCommissionInPercentage, DateOfLastChange,EnterByIdUser,BillerSpecific, ExtraAmount) 
			VALUES (@IdCommissionByOtherProducts, @FromAmount, @ToAmount, @AgentCommissionInPercentage, @CorporateCommissionInPercentage, GETDATE(), @EnterByIdUser,@BillerSpecific, @ExtraAmount)
			SET @IdCommissionDetailByProviderOut = SCOPE_IDENTITY()
		END
	ELSE
	BEGIN
	
		UPDATE CommissiondetailByOtherProducts 
		SET IdCommissionByOtherProducts = @IdCommissionByOtherProducts,
			FromAmount = @FromAmount,
			ToAmount= @ToAmount,
			AgentCommissionInPercentage = @AgentCommissionInPercentage,
			CorporateCommissionInPercentage = @CorporateCommissionInPercentage,
			DateOfLastChange = GETDATE(),
			EnterByIdUser = @EnterByIdUser,
			BillerSpecific= @BillerSpecific,
			ExtraAmount = @ExtraAmount
		WHERE IdCommissionDetailByProvider=@IdCommissionDetailByProvider

		SET @IdCommissionDetailByProviderOut=@IdCommissionDetailByProvider
	END
END TRY
BEGIN CATCH 
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveCommissionDetail',Getdate(),@Message)    
END CATCH


