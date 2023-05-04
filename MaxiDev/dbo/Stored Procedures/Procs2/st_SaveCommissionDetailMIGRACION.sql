/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="10/12/2018" Author="jresendiz"> Creado </log>
<log Date="12/05/2019" Author="esalazar"> @BillerSpecific Added</log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [dbo].[st_SaveCommissionDetailMIGRACION]
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
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCommissionDetailMIGRACION',Getdate(),CONCAT( '@IdCommissionDetailByProvider', @IdCommissionDetailByProvider , '@BillerSpecific', @BillerSpecific, '@ExtraAmount', @ExtraAmount))    
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
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCommissionDetailMIGRACION',Getdate(),@Message)    
END CATCH

