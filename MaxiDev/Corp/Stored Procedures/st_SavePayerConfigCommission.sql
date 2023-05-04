CREATE PROCEDURE [Corp].[st_SavePayerConfigCommission]
(
    @idpayerconfig int,    
    @dateofpayerconfigcommission datetime,
    @enterbyiduser int,
    @commissionold money,
    @commissionnew money
)
as
set nocount on
begin try

--deshabilitar configuracion anterior
update PayerconfigCommission set active = 0 where idpayerconfig=@idpayerconfig and dateofpayerconfigcommission=@dateofpayerconfigcommission and active=1

--agregar configuracion actual

insert into PayerConfigCommission
(Idpayerconfig,dateofpayerconfigcommission,dateoflastchange,enterbyiduser,commissionold,commissionnew,active)
values
(@idpayerconfig,@dateofpayerconfigcommission,getdate(),@enterbyiduser,@commissionold,@commissionnew,1)

End Try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SavePayerConfigCommission]',Getdate(),ERROR_MESSAGE())    
End Catch

