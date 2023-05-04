
CREATE procedure [dbo].[st_GetCiti]                                
as                                
Set nocount on                                 
                                          
--- Get Minutes to wait to be send to service ---                                          
Declare @MinutsToWait Int                                          
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                   
--Set @MinutsToWait=0                                         
                                          
---  Update transfer to Attempt -----------------                                          
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=11 and  IdStatus=20                                        
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                              
--------- Tranfer log ---------------------------                                      
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                       
Select 21,IdTransfer,GETDATE() from #temp                                        
                                
                               
Select             
Case Len(Convert(varchar,Datepart(month,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(month,Dateoftransfer)) Else Convert(varchar,Datepart(month,Dateoftransfer)) End+'/'+            
Case Len(Convert(varchar,Datepart(day,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(day,Dateoftransfer)) Else Convert(varchar,Datepart(day,Dateoftransfer)) End+'/'+            
Case Len(Convert(varchar,Datepart(year,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(year,Dateoftransfer)) Else Convert(varchar,Datepart(year,Dateoftransfer)) End   as Fecha,            
'01' as NumSecuencia,              
'USD' AS Moneda,            

case 
    when isnull(UseRefExrate,0) = 0 then A.AmountInDollars 
    else dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)
end
as Monto,            

Case B.IdCurrency When 1 Then 'D' Else 'NAT' End as MonedaPago,            

case 
    when isnull(UseRefExrate,0) = 0 then A.AmountInMN 
    else dbo.funGetConvertAmount(A.AmountInMN ,A.referenceexrate)*A.referenceexrate
end 
as Total,            

case 
    when isnull(UseRefExrate,0) = 0 then A.ExRate 
    else A.referenceexrate
end
as TasaCambio,            

Case IdPaymentType When 1 Then 'OFI'            
       When 2 Then 'BAN'            
       When 3 Then 'HOM' End as ModoPago,            
Substring(A.BeneficiaryName+' '+A.BeneficiaryFirstLastName+' '+A.BeneficiarySecondLastName,1,40) as NombreBeneficiario,            
A.BeneficiaryAddress as DireccionBeneficiario,            
A.BeneficiaryCity as CiudadBeneficiario,            
A.BeneficiaryPhoneNumber as TelBeneficiario,            
'' as TelBeneficiarioAlternativo,            
Case IdPaymentType When 2 Then C.PayerName Else '' End as Banco,             
Case IdPaymentType When 2 Then A.DepositAccountNumber Else '' End as Cuenta,            
A.CustomerName+' '+A.CustomerFirstLastName+' '+A.CustomerSecondLastName as  NombreRemitente,            
A.CustomerAddress as DireccionRemitente,            
A.CustomerPhoneNumber as TelefonoRemitente,            
' ' as Mensaje,            
A.CustomerCity as CiudadRemitente,            
Case Len(Convert(varchar,Datepart(month,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(month,Dateoftransfer)) Else Convert(varchar,Datepart(month,Dateoftransfer)) End+'/'+            
Case Len(Convert(varchar,Datepart(day,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(day,Dateoftransfer)) Else Convert(varchar,Datepart(day,Dateoftransfer)) End+'/'+            
Case Len(Convert(varchar,Datepart(year,Dateoftransfer))) when 1 Then '0'+ Convert(varchar,Datepart(year,Dateoftransfer)) Else Convert(varchar,Datepart(year,Dateoftransfer)) End   as FechaTransmision,            
Replace (convert(char(10),a.DateofTransfer,108),'-',':') as HoraTransmision,                                  
'MXT' as CodigoCompania,            
D.CountryName as NombrePaisDestino,            
C.PayerCode as Pagador,            
A.ClaimCode as Folio            
From Transfer A            
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)            
Join Payer C on (A.IdPayer=C.IdPayer)             
Join Country D on (D.IdCountry=B.IdCountry)   
left join CountryExrateConfig cex on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway                             
Where a.IdGateway=11 and IdStatus=21 and claimcode!='7410100256723'
