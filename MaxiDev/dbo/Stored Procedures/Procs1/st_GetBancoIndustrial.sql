create procedure [dbo].[st_GetBancoIndustrial]
(            
    @IdFile INT output            
)
As
Set  @IdFile=0 
--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'
--Set @MinutsToWait=0

---  Update transfer to Attempt -----------------
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=16 and  IdStatus=20
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)
--------- Tranfer log ---------------------------                              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp

-------- Generación de serial para MacroFinanciera ---------------        
--Insert into MacroFinancieraSerial (IdTransfer)
--Select IdTransfer from  #temp Where IdTransfer Not in (Select IdTransfer From MacroFinancieraSerial)

----------------  New consecutive number -------------------        
        
If Exists (      
Select   top 1 1            
From Transfer A                          
Where IdGateway=16 and IdStatus=21              
)        
Begin        
 if not exists (select top 1 1 from BancoIndustrialGeneradorIdFiles where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate()))
 begin
    insert into [BancoIndustrialGeneradorIdFiles]
    values
    (0,[dbo].[RemoveTimeFromDatetime](getdate()))
 end
 Update BancoIndustrialGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1 where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate())
 --Select @IdFile=IdFile from MacroFinancieraGeneradorIdFiles        
End   

------------------LogFileTXT---------------------------------------       
      
delete BancoIndustrialLogFileTXT where IdTransfer in       
(Select A.IdTransfer from Transfer A            

Where IdGateway=16 and IdStatus=21)

Insert into BancoIndustrialLogFileTXT             
(            
    IdTransfer,
    IdFileName,
    DateOfFileCreation,
    TypeOfTransfer
)            
Select IdTransfer,@IdFile,GETDATE(),'Transfer' from transfer Where IdGateway=16 and IdStatus=21

-----------------------------------------------------------------------

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
case idpaymenttype                                                          
    when 1 then '01'
    when 2 then '02'
end                                                                         FormaDePago,
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
--left Join MacroFinancieraSerial C on (A.IdTransfer=C.IdTransfer)    
--LEFT JOIN [OnWhoseBehalf] OWB ON (a.IdOnWhoseBehalf=owb.IdOnWhoseBehalf)
--Left Join CustomerIdentificationType B on (A.CustomerIdCustomerIdentificationType=B.IdCustomerIdentificationType)              
Where IdGateway=16 and IdStatus=21