--select * from CommissiondetailByOtherProducts

create procedure st_SaveCommissiondetailByOtherProducts
(
    @IdCommissionDetailByProvider	int,
    @IdCommissionByOtherProducts	int,
    @FromAmount	money,
    @ToAmount	money,
    @AgentCommissionInPercentage	money,
    @CorporateCommissionInPercentage	money,    
    @EnterByIdUser	int,
    @ExtraAmount money,
    @IdLenguage int,
    @IdCommissionDetailByProviderOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOP0')

if(@IdCommissionDetailByProvider=0)
begin
    insert into CommissiondetailByOtherProducts (IdCommissionByOtherProducts,FromAmount,ToAmount,AgentCommissionInPercentage,CorporateCommissionInPercentage,DateOfLastChange,EnterByIdUser,ExtraAmount) values (@IdCommissionByOtherProducts,@FromAmount,@ToAmount,@AgentCommissionInPercentage,@CorporateCommissionInPercentage,getdate(),@EnterByIdUser,@ExtraAmount)
    set @IdCommissionDetailByProviderOut = scope_identity()
end
else
begin
    update 
        CommissiondetailByOtherProducts 
    set  
        IdCommissionByOtherProducts = @IdCommissionByOtherProducts,
        FromAmount = @FromAmount,
        ToAmount= @ToAmount,
        AgentCommissionInPercentage = @AgentCommissionInPercentage,
        CorporateCommissionInPercentage = @CorporateCommissionInPercentage,
        DateOfLastChange =  getdate(),
        EnterByIdUser = @EnterByIdUser,
        ExtraAmount = @ExtraAmount
    where 
        IdCommissionDetailByProvider=@IdCommissionDetailByProvider

    set @IdCommissionDetailByProviderOut=@IdCommissionDetailByProvider
end

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOP1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCommissiondetailByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch