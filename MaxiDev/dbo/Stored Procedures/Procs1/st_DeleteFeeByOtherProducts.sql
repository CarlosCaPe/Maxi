
create procedure st_DeleteFeeByOtherProducts
(
    @IdFeeByOtherProducts int,    
    @IdLenguage int,    
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOPD0')

delete from FeeByOtherProducts where IdFeeByOtherProducts=@IdFeeByOtherProducts

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOPD1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DeleteFeeByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch