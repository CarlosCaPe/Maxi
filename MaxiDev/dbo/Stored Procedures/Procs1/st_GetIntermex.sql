CREATE Procedure [dbo].[st_GetIntermex]                            
AS                            
Set nocount on                             
                        
--- Get Minutes to wait to be send to service ---                        
Declare @MinutsToWait Int                        
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                        
                        
---  Update transfer to Attempt -----------------                        
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=20 and  IdStatus=20                      
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                            
--------- Tranfer log ---------------------------                    
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp
                        
/*
Select 
Trans.ClaimCode															as vReferencia,
CONVERT(NVARCHAR(10),Trans.DateOfTransfer, 103)							as dtFechaEnvio,
Trans.IdTransfer														as iConsecutivoAgencia,
Trans.AmountInDollars													as mMonto,
Trans.ExRate															as fTipoCambio,
Trans.AmountInMN														as mMontoPago,
Case Curr.CurrencyCode
	When 'MXP' Then 1 
	When 'MXN' Then 1 
	When 'USD' Then 2 
	End																	as siIdDivisaPago,

Case Trans.IdPaymentType 
	When 1 Then 1 
	WHEN 4 Then 1
	When 2 Then 3 
	End																	as tiIdTipoPagoEnvio,

ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerName),'')					as vNomsRemitente, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerFirstLastName),'')+' '+
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerSecondLastName),'')			as vApedosRemitente, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerAddress),'')					as vDireccionRem, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerPhoneNumber),'')				as vTelefonoRem, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerCity),'')					as vCondadoRem,
ISNULL(dbo.fn_EspecialChrOFF(Trans.CustomerState),'')					as vEstadoRem,
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryName),'')					as vNomsBeneficiario, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryFirstLastName),'')+' '+
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiarySecondLastName),'')		as vApedosBeneficiario, 
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryAddress),'')				as vDireccionBen, 
CASE WHEN ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryPhoneNumber),'')  = ''
THEN '0000000000' ELSE  dbo.fn_EspecialChrOFF(Trans.BeneficiaryPhoneNumber)END as vTelefonoBen,
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryCity),'')					as vCiudadBenef,
ISNULL(dbo.fn_EspecialChrOFF(Trans.BeneficiaryState),'')				as vEstadoBenef,
--CASE 
--    WHEN Trans.IdPaymentType = 2 then
--        p.payercode
--    else
--        Trans.GatewayBranchCode													
--end                                                                     as iIdDestino, -- Id del destino de pago

case when Trans.idpayer>=902 and Trans.idpayer<=919 then replace(payercode,'INTMX','')
else
    Trans.GatewayBranchCode                                                 
end
as iIdDestino, -- Id del destino de pago

Trans.BeneficiaryNote													as vMensaje, 
''																		as vInstruccionPago, -- Obs la agencia
--vSucursal
CASE WHEN Trans.IdPaymentType = 2 
	THEN isnull(Trans.GatewayBranchCode,'1')                            --1 por default en caso de que no se cuente con la sucursal
	ELSE ''						
END																		as vSucursal,
--vCuenta
CASE 
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))<16	THEN Trans.DepositAccountNumber
	ELSE ''
END																		as vCuenta,
--vClabe
CASE 
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))=18	THEN Trans.DepositAccountNumber
	ELSE ''
END																		as vClabe,
--vNumeroTarjeta
CASE 
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))=16	THEN Trans.DepositAccountNumber
	ELSE ''
END																		as vNumeroTarjeta,
--siIdTipoDeposito 
CASE 
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))<16	THEN '1'    --Numero de cuenta
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))=18	THEN '2'    --Clabe
    WHEN Trans.IdPaymentType = 2 and len(ltrim(rtrim(Trans.DepositAccountNumber)))=16	THEN '3'    --Numero de tarjeta
	ELSE ''
END																		as siIdTipoDeposito,
Fee vMontoCom,
*/
--Nuevo Campos
Select 
CASE WHEN Trans.IdPaymentType = 2 then Trans.DepositAccountNumber end AccountNo,
--case--#1
--	when p.PayerCode='BAM' and Trans.IdPaymentType=2 then convert(varchar(10),'Corriente')
--	when p.PayerCode='BRGT' and Trans.IdPaymentType=2 then convert(varchar(10),'Savings')--#2
--	when p.PayerCode='BDRHND' and Trans.IdPaymentType=2 then convert(varchar(10),'Savings')--#3
--	when p.PayerCode='MMDOM' and Trans.IdPaymentType=2 then convert(varchar(10),'Savings')--#4
--	WHEN p.PayerCode='EK6' AND Trans.IdPaymentType=2 THEN-- convert(varchar(10),'Savings')--#4
		CASE 
			WHEN LEN(Trans.DepositAccountNumber) = 18 THEN 'CLABE'
			WHEN LEN(Trans.DepositAccountNumber) =16 THEN 'CARD'
			WHEN LEN(Trans.DepositAccountNumber) < 16 THEN 'Savings'
			ELSE ''
		END
	--else convert(varchar(10),' ') 
--end
as AccountType,
p.PayerCode AccountInst,
Trans.IdAgent as AgentID, 
'USA' as AgentCountry,
C.AgentState as AgentState,
C.AgentZipcode as AgentPostalCode, 
'' as CustomField1,  
'US'+LTRIM(RTRIM(C.AgentState))+dbo.FunTNWAmountToString(fee) as CustomField2,  
'' as Note, 
case 
    when p.payercode='GYTCO' and Trans.IdPaymentType = 2  and len (DepositAccountNumber)=11 then substring(DepositAccountNumber,1,3)
	WHEN p.PayerCode='EK6' AND Trans.IdPaymentType=2 THEN '0000'
	else Trans.GatewayBranchCode 
end PayerLocationID ,
p.PayerCode PayerName,
Case Trans.IdPaymentType When 1 Then 'C'                                 
  When 2 Then 'D'  When 4 Then 'C' End as PaymentType, 
case J.CurrencyCode when 'MXP' Then 'MXN' Else J.CurrencyCode End  as PaymentCurrency,
Case CoCurrency.IdCountry  
    When 11 Then 'MEX' 
    WHEN 7 THEN 'ECU' 
    when 5 then 'COL'
	when 12 then 'NIC'
	when 10 then 'HND'
	when 9 then 'GTM'
	when 15 then 'PER'
	when 19 then 'CRI'
	when 13 then 'PAN'
	when 8 then 'SLV'
    Else 'USA'
End as PaymentCountry,
Trans.ConfirmationCode as ConfCode,
Trans.ClaimCode as  ClaimCode, 
case 
    when isnull(UseRefExrate,0) = 0 then ROUND(Trans.AmountInMN,2) 
    else ROUND(Trans.AmountInMN,2)
end
as PaymentAmount,
ExRate,
Trans.IdTransfer as InternalRefNumber,
'USA' as OriginationCountry, 
C.AgentState as OriginationState,
'USD' as OriginationCurrency,
case 
    when isnull(UseRefExrate,0) = 0 then ROUND(Trans.AmountInDollars,2)
    else round(Trans.AmountInMN/Trans.referenceexrate,2)
end
as OriginationAmount,
Trans.DateOfTransfer as TransactionDate,
F.CountryCode as BenCountry, 
I.StateCodeTNC as BenState, 
Case CoCurrency.IdCountry  
    When 11 Then 'MEX' 
    WHEN 7 THEN 'ECU' 
    when 5 then 'COL'
	when 12 then 'NIC'
	when 10 then 'HND'
	when 9 then 'GTM'
	when 15 then 'PER'
	when 19 then 'CRI'
	when 13 then 'PAN'
	when 8 then 'SLV'

    Else 'MEX'
End as  BenCOB,
case when BeneficiaryAddress='' Then 'Conocida' Else isNull([dbo].[fn_EspecialChrEKOFFSpace](BeneficiaryAddress),'Conocida') End as BenAddress,
case when isnull(BeneficiaryCity,'Conocida')='' Then 'Conocida' Else BeneficiaryCity  End as BenCity, 
BeneficiaryBornDate as BenDOB,                                
BeneficiaryName as BenFirst,
BeneficiaryFirstLastName as BenPLast,
BeneficiarySecondLastName as BenMLast, 
CASE 
	WHEN p.PayerCode = 'EASYP' THEN 
		CASE Trans.IdPaymentType 
			WHEN 1 THEN '' 
			--WHEN 2 THEN isnull(benid.BTSIdentificationType,'Cedula') --Para EASYPAGOS este valor es hardcode
			WHEN 2 THEN isnull(benid.BTSIdentificationType,'GOV') --Para EASYPAGOS este valor es hardcode--#6
		END 
	WHEN p.PayerCode = 'EXITO' THEN --Pare exito este valor es harcode (CC Cedula de Ciudadania/CE Cedula de Extranjería)
        --'CC Cedula de Ciudadania'
		'GOV'--#5
	ELSE 'vot'
END as  BenIDType,    
CASE 
	WHEN p.PayerCode = 'EASYP' THEN 
		CASE Trans.IdPaymentType 
			WHEN 1 THEN '' 
			WHEN 2 THEN isnull(BeneficiaryIdentificationNumber,'1234567890') --Cuando se acepten depositos con EASYPAGOS y se tenga en el sistema la captura de la cedula del beneficiario entonces reemplazar este campo
		END 
	ELSE '123456' 
END as BenIDNumber,
BeneficiaryOccupation as BenOccupation,
BeneficiarySSNumber as BenSSN, 
case when BeneficiaryPhoneNumber='' Then '0000000' else IsNull(substring(BeneficiaryPhoneNumber,1,18),'0000000') end as BenTel,
case when BeneficiaryZipCode ='' Then '00000' else Isnull(BeneficiaryZipCode,'00000') End as BenPostalCode, 
'USA' as ClientCountry,  
CustomerState as ClientState, 
'MEX' as ClientCOB, 
[dbo].[fn_EspecialChrEKOFFSpace](CustomerAddress) as ClientAddress, 
CustomerCity as ClientCity,  
CustomerBornDate as ClientDOB,   
CustomerName as ClientFirst,                                
'' as ClientMiddleName, 
CustomerFirstLastName  as ClientPLast,         
CustomerSecondLastName as ClientMLast, 
isnull(TransNetworkIDType,'') as ClientIDType, 
isnull(CustomerIdentificationNumber,'') as ClientIDNumber,
''  as ClientIDState,  
'USA' as ClientIDCountry,  
Isnull(CustomerExpirationIdentification,'') as ClientIDExpDate, 
CustomerOccupation as ClientOccupation, 
CustomerSSNumber as ClientSSN,  
case CustomerPhoneNumber when '' then '1'  when null then '1' Else CustomerPhoneNumber  End as ClientTel,
CustomerZipCode as ClientPostalCode, 
Purpose, 
Relationship, 
MoneySource, 
'' as OriginationType, 
'' as BenNationality,
'' as BenPOB,
'' as BentMiddleName,
'' as BenIDState,
'' as BenIDCountry,
'' as BenIDExpDate,
'' as BenGender,
'' as ClientNationality,
'' as ClientPOB,
'' as ClientGender  
--AgentId
from [dbo].[Transfer] Trans
INNER JOIN [dbo].[CountryCurrency] CoCurrency on Trans.IdCountryCurrency = CoCurrency.IdCountryCurrency
INNER JOIN [dbo].[Currency] Curr on CoCurrency.IdCurrency = Curr.IdCurrency
INNER JOIN [dbo].Payer p on Trans.idpayer = p.idpayer
Left Join CustomerIdentificationType E on (E.IdCustomerIdentificationType=Trans.CustomerIdCustomerIdentificationType) 
Join Agent C On (Trans.IdAgent=C.IdAgent)
Join Country F on (F.IdCountry=CoCurrency.IdCountry)
Join Branch G on (Trans.IdBranch=G.IdBranch)  
Join City H on (G.IdCity=H.IdCity)
Join State I on (H.IdState=I.IdState)
Join Currency J on (J.IdCurrency=Curr.IdCurrency) 
left join [BeneficiaryIdentificationType] benid on benid.IdBeneficiaryIdentificationType=Trans.IdBeneficiaryIdentificationType
left join CountryExrateConfig cex on CoCurrency.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=Trans.idgateway
--left join payer p on trans.idpayer=p.idpayer
Where Trans.IdGateway=20 and Trans.IdStatus=21