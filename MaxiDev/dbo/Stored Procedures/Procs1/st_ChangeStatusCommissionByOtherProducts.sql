
--select * from CommissionByOtherProducts

CREATE PROCEDURE [dbo].[st_ChangeStatusCommissionByOtherProducts]
(
    @IdCommissionByOtherProducts int,    
    @IdLenguage int,    
    @HasError int out,
    @Message nvarchar(max) out
)
as
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen billers transaction</Description>

<ChangeLog>
<log Date="10/08/2018" Author="snevarez">Creacion del Store</log>
</ChangeLog>
*********************************************************************/
begin try
declare @status bit = 0

set @HasError = 0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'OKSTATUSCOMM')

set @status = (Select IsEnable from CommissionByOtherProducts where IdCommissionByOtherProducts=@IdCommissionByOtherProducts)

if (@status = 1)
	update CommissionByOtherProducts set IsEnable = 0 where IdCommissionByOtherProducts=@IdCommissionByOtherProducts
else
	update CommissionByOtherProducts set IsEnable = 1 where IdCommissionByOtherProducts=@IdCommissionByOtherProducts


--delete from CommissionByOtherProducts where IdCommissionByOtherProducts=@IdCommissionByOtherProducts


End Try
Begin Catch 
 set @HasError = 1
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'ERRSTATUSCOMM')
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ChangeStatusCommissionByOtherProducts',Getdate(),ERROR_MESSAGE())    
End Catch
