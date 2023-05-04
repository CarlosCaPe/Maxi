--select * from FeedetailByOtherProducts

create procedure st_DeleteFeedetailByOtherProducts
(
    @IdFeeDetailByOtherProductsr int,    
    @IdLenguage int,    
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOPD0')

delete from FeedetailByOtherProducts where IdFeeDetailByOtherProductsr=@IdFeeDetailByOtherProductsr

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'FEEOPD1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DeleteFeedetailByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch