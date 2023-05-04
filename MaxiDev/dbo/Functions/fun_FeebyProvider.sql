create function [dbo].[fun_FeebyProvider] (@IdAgent int,@Amount money)
Returns Money
AS
Begin
	Declare @AgentFee Money,@IdFeeByProvider int,@IdCommissionByProvider int
	Declare @Fee Money,@AgentCommissionInPercentage Money,@ExtraAmount Money,@IsFeePercentage bit
	Select @IdFeeByProvider=IdFeeByProvider,@IdCommissionByProvider=IdCommissionByProvider from AgentProductByProvider where IdAgent=@IdAgent 
	
	Select @Fee=Fee,@IsFeePercentage=IsFeePercentage from FeeDetailByProvider where IdFeeByProvider=@IdFeeByProvider and FromAmount<@Amount and ToAmount>=@Amount
Return(@Fee)
End

