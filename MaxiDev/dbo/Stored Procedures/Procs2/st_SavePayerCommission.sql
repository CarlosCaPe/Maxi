--select * from [PayerCommission]
create procedure st_SavePayerCommission
(
    @idpayer int,
    @idpaymenttype int,
    @dateofpayercommission datetime,
    @enterbyiduser int,
    @commissionold money,
    @commissionnew money
)
as

begin try

--deshabilitar configuracion anterior
update PayerCommission set active = 0 where idpayer=@idpayer and idpaymenttype=@idpaymenttype and dateofpayercommission=@dateofpayercommission

--agregar configuracion actual

insert into PayerCommission
(Idpayer,idpaymenttype,dateofpayercommission,dateoflastchange,enterbyiduser,commissionold,commissionnew,active)
values
(@idpayer,@idpaymenttype,@dateofpayercommission,getdate(),@enterbyiduser,@commissionold,@commissionnew,1)

End Try
Begin Catch 
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayerCommission',Getdate(),ERROR_MESSAGE())    
End Catch