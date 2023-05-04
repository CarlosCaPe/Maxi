--select * from CommissionByOtherProducts

create procedure st_DeleteCommissionByOtherProducts
(
    @IdCommissionByOtherProducts int,    
    @IdLenguage int,    
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOPD0')

delete from CommissionByOtherProducts where IdCommissionByOtherProducts=@IdCommissionByOtherProducts

End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'COMOPD1')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DeleteCommissionByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch