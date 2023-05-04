CREATE procedure [dbo].[st_getBanruralPichincha]  
/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Obtiene las remesas de Banrural Pichincha que estan listas para ser enviadas al pagador</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="03/08/2017" Author="snevarez">Obtiene las remesas de Banrural Pichincha(BANRP) que estan listas para ser enviadas al pagador</log>
</ChangeLog>
*********************************************************************/                             
as                                
Set nocount on                                 

--13	BANRURAL	BANR
--36	BANRURAL Pichincha	BANRP
                                   
--- Get Minutes to wait to be send to service ---                                          
Declare @MinutsToWait Int                                          
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                   
--Set @MinutsToWait=0                                         
                                          
---  Update transfer to Attempt -----------------                                          
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=13 and  IdStatus=20 and idpayer=4023                                  
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                              
--------- Tranfer log ---------------------------                                      
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                       
Select 21,IdTransfer,GETDATE() from #temp                                        
                                
    
Select     
    A.ClaimCode as NoGiro,    
    Substring(A.CustomerName,1,40) as NombreRemitente,    
    Substring(A.CustomerFirstLastName+' '+A.CustomerSecondLastName,1,40) as ApellidoRemitente,    
    SUBSTRING(A.CustomerAddress,1,40) as DireccionRemitente,    
    A.CustomerPhoneNumber as TelefonoRemitente,    
    'USA' as PaisOrigen,    
    B.AgentState as EstadoOrigen,    
    B.AgentCity as CiudadOrigen,    
    B.AgentZipcode as CodigoPostalOrigen,    
    'USD' as MonedaOrigen,    
    Substring(A.BeneficiaryName,1,40) as NombreBeneficiario,    
    Substring(A.BeneficiaryFirstLastName+' '+A.BeneficiarySecondLastName,1,40) as ApellidoBeneficiario,    
    SUBSTRING(A.BeneficiaryAddress,1,40) as DireccionBeneficiario,    
    A.BeneficiaryPhoneNumber as TelefonoBeneficiario,     
    '' MensajeBeneficiario,     
    D.CountryCode as  PaisPago,    
    case when E.CurrencyCode='MXP' THEN 'MXN' ELSE E.CurrencyCode END as MonedaPago,     

    case when a.idpayer=941 then 'BRH'
    ----
	when a.idpayer=2630 then 'MXAP'
	when a.idpayer=3991 then 'MXAP'
	when a.idpayer=3992 then 'MXAP'
	when a.idpayer=3993 then 'MXAP'
	when a.idpayer=3994 then 'MXAP'
	when a.idpayer=3995 then 'MXAP'
	when a.idpayer=3996 then 'MXAP'
	when a.idpayer=3997 then 'MXAP'
 
	--when a.idpayer=2631 then 'BP01'
	when a.idpayer=2631 then 'PEMB'

	when a.idpayer=2632 then 'DOMU'
	when a.idpayer=2633 then 'COMC'
	when a.idpayer=2634 then 'HNMF'
	when a.idpayer=2635 then 'SVMF'
	when a.idpayer=2636 then 'ARMM'
	when a.idpayer=2637 then 'BOMM'
	when a.idpayer=2638 then 'CLMM'
	when a.idpayer=2639 then 'PYMM'
	when a.idpayer=2640 then 'DOMR'
	when a.idpayer=2641 then 'BRMM'

	--when a.idpayer=4023 then 'EPIC' /*20170120*/ 
	when a.idpayer=4023 then 'EPIC' /*S33*/ 
    ----
    else
    F.PayerCode 
    end
    as CodigoPagador,    

    --Cambios para respetar el tipo de cambio oficial de honduras
    case 
	   when isnull(UseRefExrate,0) = 0 then a.AmountInDollars 
	   else dbo.funGetConvertAmount(a.AmountInMN ,a.referenceexrate)
    end  ValorEnviadoEnMonedaOrigen,   
    --A.AmountInDollars as ValorEnviadoEnMonedaOrigen,    

    --Cambios para respetar el tipo de cambio oficial de honduras
    case 
	   when isnull(UseRefExrate,0) = 0 then a.ExRate 
	   else a.referenceexrate
    end as TasaDeCambio,    
    --A.ExRate as TasaDeCambio,    

    --Cambios para respetar el tipo de cambio oficial de honduras
    case 
	   when isnull(UseRefExrate,0) = 0 then a.AmountInMN 
	   else round(dbo.funGetConvertAmount(a.AmountInMN ,a.referenceexrate)*a.referenceexrate,4)
    end ValorAPagarEnMonedaPago,
    --A.AmountInMN as ValorAPagarEnMonedaPago,    
    Case A.IdPaymentType When 1 Then 'V'    
		When 2 Then 'D'    
		When 3 Then 'E'    
		When 4 Then 'V' End as FormaDePago,    
    A.DepositAccountNumber as NumeroDeCuenta,    
    '' as BancoDeposito,    
    Case Len(Convert(varchar,Datepart(year,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(year,Dateoftransfer)) Else Convert(varchar,Datepart(year,Dateoftransfer)) End +    
    Case Len(Convert(varchar,Datepart(month,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(month,Dateoftransfer)) Else Convert(varchar,Datepart(month,Dateoftransfer)) End+            
    Case Len(Convert(varchar,Datepart(day,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(day,Dateoftransfer)) Else Convert(varchar,Datepart(day,Dateoftransfer)) End as FechaTransaccion,    
    '' as SecuenciaOrigen,    
    '' as LlaveAlterna,    
    A.IdBeneficiary as CodigoBeneficiario,    
    A.IdCustomer as CodigoRemitente      
from Transfer A     
    Join Agent B on (A.IdAgent=B.IdAgent)    
    Join CountryCurrency C on (A.IdCountryCurrency=C.IdCountryCurrency)    
    Join Country D on (D.IdCountry=C.IdCountry)    
    Join Currency E on (E.IdCurrency=C.IdCurrency)    
    Join Payer F on (A.IdPayer=F.IdPayer)    
    left join CountryExrateConfig cex on c.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway=13 and IdStatus=21 and a.idpayer=4023  
