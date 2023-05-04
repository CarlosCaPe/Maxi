
CREATE procedure st_SaveCommissionByOtherProducts
(
    @IdCommissionByOtherProducts int,
    @IdOtherProducts int,
    @CommissionName  nvarchar(max),
    @EnterByIdUser	int,
    @IdOtherProductCommissionType int = 0,
    @IdLenguage int,
    @IdCommissionByOtherProductsOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOP0')

if(@IdCommissionByOtherProducts=0)
begin
    insert into CommissionByOtherProducts (IdOtherProducts,CommissionName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionTypE) values (@IdOtherProducts,@CommissionName,getdate(),@EnterByIdUser,@IdOtherProductCommissionType)
    set @IdCommissionByOtherProductsOut = scope_identity()
end
else
begin
    update 
        CommissionByOtherProducts 
    set  
        IdOtherProducts	= @IdOtherProducts,
        CommissionName	= @CommissionName,
        DateOfLastChange	= getdate(),
        EnterByIdUser	= @EnterByIdUser,
        IdOtherProductCommissionType= @IdOtherProductCommissionType
    where 
        IdCommissionByOtherProducts=@IdCommissionByOtherProducts

    set @IdCommissionByOtherProductsOut=@IdCommissionByOtherProducts
end

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOP1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCommissionByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch