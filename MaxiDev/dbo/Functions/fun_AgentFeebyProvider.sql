
CREATE function [dbo].[fun_AgentFeebyProvider] (@IdAgent int,@Amount money)
Returns Money
AS
Begin
	Declare @AgentFee Money,@IdFeeByProvider int,@IdCommissionByProvider int
	Declare @Fee Money,@AgentCommissionInPercentage Money,@ExtraAmount Money,@IsFeePercentage bit
	Select @IdFeeByProvider=IdFeeByProvider,@IdCommissionByProvider=IdCommissionByProvider from AgentProductByProvider where IdAgent=@IdAgent 
	
	Select @Fee=Fee,@IsFeePercentage=IsFeePercentage from FeeDetailByProvider where IdFeeByProvider=@IdFeeByProvider and FromAmount<@Amount and ToAmount>=@Amount
	Select @AgentCommissionInPercentage=AgentCommissionInPercentage,@ExtraAmount=ExtraAmount from CommissionDetailByProvider 
	where IdCommissionByProvider=@IdCommissionByProvider and FromAmount<@Fee and ToAmount>@Fee

	if @IsFeePercentage=1 
	Begin
		Set @AgentFee=@Amount*(@Fee/100)*(@AgentCommissionInPercentage/100)+@ExtraAmount
	End
	Else
	Begin	
		Set @AgentFee=@Fee*(@AgentCommissionInPercentage/100)+@ExtraAmount
	End
Return(@AgentFee)
End


