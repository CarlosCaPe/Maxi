--select * from FeedetailByOtherProducts

create procedure st_SaveFeedetailByOtherProducts
(
    @IdFeeDetailByOtherProductsr int,
    @IdFeeByOtherProducts int,
    @FromAmount	money,
    @ToAmount	money,
    @Fee money,
    @IsFeePercentage bit,
    @EnterByIdUser	int,    
    @IdLenguage int,
    @IdFeeDetailByOtherProductsrOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOP0')

if(@IdFeeDetailByOtherProductsr=0)
begin
    insert into FeedetailByOtherProducts (IdFeeByOtherProducts,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage) values (@IdFeeByOtherProducts,@FromAmount,@ToAmount,@Fee,getdate(),@EnterByIdUser,@IsFeePercentage)
    set @IdFeeDetailByOtherProductsrOut = scope_identity()
end
else
begin
    update 
        FeedetailByOtherProducts 
    set  
        IdFeeByOtherProducts=@IdFeeByOtherProducts,
        FromAmount=@FromAmount,
        ToAmount=@ToAmount,
        Fee=@Fee,
        DateOfLastChange= getdate(),
        EnterByIdUser=@EnterByIdUser,
        IsFeePercentage=@IsFeePercentage
    where 
        IdFeeDetailByOtherProductsr=@IdFeeDetailByOtherProductsr

    set @IdFeeDetailByOtherProductsrOut=@IdFeeDetailByOtherProductsr
end

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOP1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveFeedetailByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch