CREATE procedure [dbo].[st_GetBancoIndustrialCancels]          
(        
    @IdFile Int Output    
)
as  
Set @IdFile=0 

If Exists (
Select top 1 1 from transfer a
Where IdGateway=16 and IdStatus=25  and DateOfTransfer >='2020-07-01'
)    
Begin

 if not exists (select top 1 1 from BancoIndustrialGeneradorIdFiles where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate()))
 begin
    insert into [BancoIndustrialGeneradorIdFiles]
    values
    (0,[dbo].[RemoveTimeFromDatetime](getdate()))
 end
 Update BancoIndustrialGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1 where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate())   
--    Select  from PagosIntGeneradorIdFiles    
End    
  
Delete  BancoIndustrialLogFileTXT where IdTransfer in (Select IdTransfer from Transfer Where IdGateway=16 and IdStatus=25  )       
Insert into BancoIndustrialLogFileTXT         
(        
IdTransfer,        
IdFileName,        
DateOfFileCreation,        
TypeOfTransfer         
)        
Select IdTransfer,@IdFile,GETDATE(),'Cancel' from Transfer Where IdGateway=16 and IdStatus=25   and DateOfTransfer >='2020-07-01'


        
Set Nocount on         
Select                               
LEFT(a.claimcode+space(20), 20)                                             NumeroDeRemesa,
CONVERT(VARCHAR(10), dateoftransfer, 103)                                   FechaEnvioRemesa,
CONVERT(VARCHAR(8), dateoftransfer, 108)                                    HoraEnvioRemesa,

--RIGHT('000000000000000000' + convert(varchar,amountindollars), 18)          MontoEnDolares,
RIGHT('0000000000000000' + convert(varchar,convert(int,round(amountindollars,2) - (Round(amountindollars,2) % 1))), 16) + --decimal
LEFT(convert(varchar,convert(int, (amountindollars % 1) * 100))+ '00', 2)
                                                                            MontoEnDolares,

--RIGHT('000000000' + convert(varchar,exrate), 9)                             TasaDeCambio,
RIGHT('00' + convert(varchar,convert(int,round(exrate,2) - (Round(exrate,2) % 1))), 2) + --decimal
LEFT(convert(varchar,convert(int, (exrate % 1) * 100))+ '000000', 6)
                                                                             TasaDeCambio,
--RIGHT('000000000000000000' + convert(varchar,amountinMN), 18)               MontoEnQuetzales,
RIGHT('0000000000000000' + convert(varchar,convert(int,round(amountinMN,2) - (Round(amountinMN,2) % 1))), 16) + --decimal
LEFT(convert(varchar,convert(int, (amountinMN % 1) * 100))+ '00', 2)
                                                                            MontoEnQuetzales,
LEFT(a.customername+space(50), 50)                                          NombreRemitente,
LEFT(replace(a.customerfirstlastname,'.','')+space(50), 50)                                 PrimerApellidoRemitente,
LEFT(replace(a.customersecondlastname,'.','')+space(50), 50)                                SegundoApellidoRemitente,
LEFT(a.customerphonenumber+space(20), 20)                                   TelefonoRemitente,
LEFT(a.CustomerAddress+space(255), 255)                                     DireccionRemitente,
LEFT(a.customercity+space(50), 50)                                          CiudadRemitente,
LEFT(a.customerstate+space(20), 20)                                         EstadoRemitente,
LEFT(a.customerzipcode+space(20), 20)                                       CodigoPostalRemitente,
LEFT('USA'+space(50), 50)                                                   PaisRemitente,
LEFT(a.beneficiaryname+space(50), 50)                                       NombreBeneficiario,
LEFT(replace(a.beneficiaryfirstlastname,'.','')+space(50), 50)                              PrimerApellidoBeneficiario,
LEFT(replace(a.beneficiarysecondlastname,'.','')+space(50), 50)                             SegundoApellidoBeneficiario,
LEFT(a.beneficiaryphonenumber+space(20), 20)                                TelefonoBeneficiario,
LEFT(a.beneficiaryAddress+space(255), 255)                                  DireccionBeneficiario,
LEFT(a.beneficiarycity+space(50), 50)                                       CiudadBeneficiario,
LEFT(a.beneficiarystate+space(20), 20)                                      EstadoBeneficiario,
LEFT(a.beneficiaryzipcode+space(20), 20)                                    CodigoPostalBeneficiario,
LEFT(a.beneficiarycountry+space(50), 50)                                    PaisBeneficiario,
'04'                                                                        FormaDePago, --candelaciones 04
LEFT(ltrim(rtrim(isnull(depositaccountnumber,'')))+space(50), 50)           NumeroDeCuenta,
RIGHT('0001', 4)                                                            CodigoBanco,
LEFT('BANCO INDUSTRIAL'+space(50), 50)                                      NombreBanco,
case idpaymenttype                                                          
    when 1 then '00'
    when 2 then '01'
end                                                                         TipoDeCuenta,
'00'                                                                        StatusConfirmacion,
'                                                  '                        DescripcionMensaje,
c.currencycode                                                              CodigoMoneda

From Transfer A                              
--join agent AG on a.idagent=ag.idagent
Join Payer D on (A.IdPayer=D.IdPayer)
join branch b on a.idbranch=b.idbranch
left join countrycurrency cc on cc.idcountrycurrency=a.idcountrycurrency
left join currency c on c.idcurrency=cc.idcurrency
Where IdGateway=16 and IdStatus=25  and DateOfTransfer >='2020-07-01'