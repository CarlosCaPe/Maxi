--select * from FeeByOtherProducts

create procedure st_SaveFeeByOtherProducts
(
    @IdFeeByOtherProducts int,
    @IdOtherProducts int,
    @FeeName  nvarchar(max),
    @EnterByIdUser	int,
    @IdOtherProductCommissionType int = 0,
    @IdLenguage int,
    @IdFeeByOtherProductsOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOP0')

if(@IdFeeByOtherProducts=0)
begin
    insert into FeeByOtherProducts (IdOtherProducts,FeeName,DateOfLastChange,EnterByIdUser,IdOtherProductCommissionType) values (@IdOtherProducts,@FeeName,getdate(),@EnterByIdUser,@IdOtherProductCommissionType)
    set @IdFeeByOtherProductsOut = scope_identity()
end
else
begin
    update 
        FeeByOtherProducts 
    set  
        IdOtherProducts	= @IdOtherProducts,
        FeeName	= @FeeName,
        DateOfLastChange	= getdate(),
        EnterByIdUser	= @EnterByIdUser,
        IdOtherProductCommissionType= @IdOtherProductCommissionType
    where 
        IdFeeByOtherProducts=@IdFeeByOtherProducts

    set @IdFeeByOtherProductsOut=@IdFeeByOtherProducts
end

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOP1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveFeeByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch