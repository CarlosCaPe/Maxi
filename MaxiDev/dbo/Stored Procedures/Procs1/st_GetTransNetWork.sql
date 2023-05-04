
CREATE Procedure [dbo].[st_GetTransNetWork] 
 --exec st_GetTransNetWork ;
AS                                
Set nocount on    

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="06/08/2019" Author="jdarellano" Name="#1">Se agrega hardcodeo para tipo de pago "Depósito" para pagador "BAM", con palabra "Corriente".</log>
<log Date="27/08/2019" Author="bortega" >Se agregan campos en la consulta.</log>
<log Date="13/10/2019" Author="jdarellano" Name="#2">Se agrega hardcodeo para tipo de pago "Depósito" para pagador "Banrural", con palabra "Savings".</log>
<log Date="13/10/2019" Author="jdarellano" Name="#3">Se agrega hardcodeo para tipo de pago "Depósito" para pagador "Banrural Honduras", con palabra "Savings".</log>
<log Date="13/10/2019" Author="jdarellano" Name="#4">Se agrega hardcodeo para tipo de pago "Depósito" para pagador "Remesas Dominicanas", con palabra "Savings".</log>
<log Date="13/10/2019" Author="jdarellano" Name="#5">Se modifica hardcodeo para pagador "EXITO", en el campo BenIDType con palabra "GOV".</log>
<log Date="13/10/2019" Author="jdarellano" Name="#6">Se modifica hardcodeo para pagador "EASYPAY", en el campo BenIDType con palabra "GOV".</log>
<log Date="13/11/2019" Author="jdarellano" Name="#7">Se aplica hardcodeo para pagadores de red de pago de SLV.</log>
<log Date="13/11/2019" Author="jdarellano" Name="#8">Se aplica hardcodeo para pagadores de red de pago de SLV para pagos tipo "Deposit".</log>
<log Date="20/05/2020" Author="jdarellano" Name="#9">Se aplica hardcodeo para pagador Fedecrédito.</log>
<log Date="20/05/2020" Author="jdarellano" Name="#10">Se aplica hardcodeo para pagador Scotiabank.</log>
<log Date="21/05/2020" Author="jdarellano" Name="#11">Se aplica hardcodeo para pagador Fedecrédito.</log>
<log Date="14/09/2020" Author="jdarellano" Name="#12">Se aplica hardcodeo para pagador ABANK.</log>
<log Date="31/01/2022" Author="jcsiera" Name="#13"> Se realiza Merge con las versiones en conflicto de prod, agregando Elektra y Fedecrédito </log>
<log Date="27/04/2022" Author="adominguez" Name="#14">Se agrega tipo de cuenta para depósito Checks Or Saving.</log>
<log Date="09/05/2022" Author="jdarellano" Name="#15">Se hace merge de versión productiva y backup obtenido el día 27 de abril de 2022, y se agregan WITH (NOLOCK).</log>
<log Date="13/07/2022" Author="adominguez" Name="#16">Se agrega pagador Coop. Jardin Azuayo.</log>
<log Date="14/02/2023" Author="adominguez" Name="#17">Se agrega pagadores de Teledoral CRC.</log>
*********************************************************************/
                            
--- Get Minutes to wait to be send to service ---                            
Declare @MinutsToWait Int                            
Select @MinutsToWait=Convert(int,Value) From dbo.GlobalAttributes WITH (NOLOCK) where [Name]='TimeFromReadyToAttemp'   
--set @MinutsToWait=5                         
                            
---  Update transfer to Attempt -----------------                            
Select top 300 IdTransfer into #temp from dbo.[Transfer] WITH (NOLOCK) Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=3 and  IdStatus=20 /*---*/                         
Update dbo.[Transfer] Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                              
--------- Tranfer log ---------------------------                        
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                         
Select 21,IdTransfer,GETDATE() from #temp                            
                            
                                
Select   
/*       
case when D.PayerCode='CUSC' then D.PayerCode
     when D.PayerCode='CITG' then D.PayerCode
     when D.PayerCode='CITH' then D.PayerCode
     when D.PayerCode='BU06' then D.PayerCode
     when D.PayerCode='CITP' then D.PayerCode
     when D.PayerCode='CITR' then D.PayerCode
     when D.PayerCode='BP01' then D.PayerCode
     when D.PayerCode='EC01' then D.PayerCode
else 
    ''
end
as*/
case 
	when D.PayerCode='EK6' then 'ELKTR'
	when D.IdPayer=446 then 'BF01'--Banco Fomento Agropecuario /*#7
	when D.IdPayer=5325 then 'B AZUL'--Banco Azul
	when D.IdPayer=5290 then 'SPSE'--Súper Selectos
	when D.IdPayer=5293 then 'UNIR'--La Curacao
	when D.IdPayer=5289 then 'UNIR'--Tropigas
	when D.IdPayer=487 then 'HIPS'--Walmart SLV--
	when D.IdPayer=5328 then 'PRAM'--Banco Promerica
	when D.IdPayer=5294 then 'AKISV'--Red AKI
	when D.IdPayer=5326 then 'DLC'--DLC
	when D.IdPayer=5291 then 'DFES'--Despensa Familiar
	when D.IdPayer=450 then 'WMAT'--Despensa Don Juan
	when D.IdPayer=5327 then 'TEXACO'--TEXACO #7*/
	when D.IdPayer=5337 then 'FDCD'--Fedecrédito #9
	when D.IdPayer=5338 then 'CUSC'--Scotiabank #10
	when D.IdPayer=5340 then 'FDCD'--Fedecrédito #11
	when D.IdPayer=5373 then 'ABANK'--ABANK #12
	when D.IdPayer=5641 then 'Coop. Jardín Azuayo' --Para EASYPAGOS (Coop. Jardín Azuayo)
	/*Pagadores Teledoral Inicio*/ --#17
	when D.IdPayer= 7030 then 'TELEDOLAR'
	when D.IdPayer= 7031 then 'Banco Central'
	when D.IdPayer= 7032 then 'Bac San Jose '
	when D.IdPayer= 7033 then 'Davivienda (Costa Rica) S.A.'
	when D.IdPayer= 7034 then 'BCT S.A.'
	when D.IdPayer= 7035 then 'Lafise S.A.'
	when D.IdPayer= 7036 then 'Promerica S.A.'
	when D.IdPayer= 7037 then 'Improsa S.A.'
	when D.IdPayer= 7038 then 'Scotiabank  de Costa Rica S.A.'
	when D.IdPayer= 7039 then 'Cathay de Costa Rica S.A.'
	when D.IdPayer= 7040 then 'Banco General (Costa Rica) S.A.'
	when D.IdPayer= 7041 then 'Banco CMB (Costa Rica) S.A.'
	when D.IdPayer= 7042 then 'Banco Nacional de C.R. '
	when D.IdPayer= 7043 then 'Banco de Costa Rica '
	when D.IdPayer= 7044 then 'Banco Popular de Desarrollo Comunal '
	when D.IdPayer= 7045 then 'Banco Hipotecario de la Vivienda '
	when D.IdPayer= 7046 then 'Prival Bank (Costa Rica) S.A.'
	when D.IdPayer= 7047 then 'Grupo Mutual Alajuela - La Vivienda'
	when D.IdPayer= 7048 then 'Mutual Cartago'
	when D.IdPayer= 7049 then 'Financiera Cafsa'
	when D.IdPayer= 7050 then 'Financiera MultiMoney S.A'
	when D.IdPayer= 7051 then 'Financiera Comeca'
	when D.IdPayer= 7052 then 'Financiera Desyfin'
	when D.IdPayer= 7053 then 'Financiera Monge, S.A.'
	when D.IdPayer= 7054 then 'Coopeguanacaste R.L.'
	when D.IdPayer= 7055 then 'Coocique'
	when D.IdPayer= 7056 then 'COOPE SAN MARCOS'
	when D.IdPayer= 7057 then 'CoopeAlianza'
	when D.IdPayer= 7058 then 'COOPENAE'
	when D.IdPayer= 7059 then 'Cooperativa de Servicios Publicos'
	when D.IdPayer= 7060 then 'Coope Ande N° 1 RL'
	when D.IdPayer= 7061 then 'CoopeCaja'
	when D.IdPayer= 7062 then 'Caja de ANDE'
	when D.IdPayer= 7063 then 'COOPEMEP'
	when D.IdPayer= 7064 then 'CREDECOOP R.L.'
	when D.IdPayer= 7065 then 'COOPESAN RAMoN R.L.'
	when D.IdPayer= 7066 then 'COOPEBANPO'
	when D.IdPayer= 7067 then 'Coopeamistad R.L.'
	when D.IdPayer= 7068 then 'Coopecar R.L.'
	when D.IdPayer= 7069 then 'COOPEGRECIA R.L.'
	when D.IdPayer= 7070 then 'COOPAVEGRA'
	when D.IdPayer= 7071 then 'COOPEUNA R.L.'
	when D.IdPayer= 7072 then 'COOPEMEDICOS R.L.'
	when D.IdPayer= 7073 then 'Coopejudicial'
	when D.IdPayer= 7074 then 'COOPELECHEROS R.L'
	when D.IdPayer= 7075 then 'Coopedetallistas, R.L.'
	when D.IdPayer= 7076 then 'COOPEFYL R.L.'
	when D.IdPayer= 7077 then 'CoopeAyA'
	when D.IdPayer= 7079 then 'Banpro'
	when D.IdPayer= 7080 then 'Lafise Bancentro'
	when D.IdPayer= 7081 then 'Banco de Finanzas BDF'
	when D.IdPayer= 7082 then 'Banco Ficosha'
	when D.IdPayer= 7083 then 'Banco Avanz (Procredit)'
	when D.IdPayer= 7084 then 'Banco de América Central BAC'
	when D.IdPayer= 7085 then 'BANPRO'
	when D.IdPayer= 7086 then 'BANPRO'
	when D.IdPayer= 7087 then 'BANPRO'
	when D.IdPayer= 7088 then 'BANPRO'
	when D.IdPayer= 7089 then 'BANPRO'
	when D.IdPayer= 7090 then 'BANPRO'
	when D.IdPayer= 7091 then 'LAFISE'
	when D.IdPayer= 7092 then 'LAFISE'
	when D.IdPayer= 7093 then 'LAFISE'
	when D.IdPayer= 7094 then 'LAFISE'
	when D.IdPayer= 7095 then 'LAFISE'
	when D.IdPayer= 7096 then 'LAFISE'
	/*Pagadores Teledoral Fin*/
else 
    D.PayerCode
end as AccountInst,
A.ConfirmationCode as ConfCode,                                
A.ClaimCode as  ClaimCode,                                
A.IdTransfer as InternalRefNumber,                                
A.DateOfTransfer as TransactionDate,                                
'USD' as OriginationCurrency,                                
'USA' as OriginationCountry,                                

--A.AmountInDollars as OriginationAmount,                                
--Cambios para respetar el tipo de cambio oficial de honduras
case 
	WHEN A.IdPaymentType = 2 AND D.IdPayer=5641 THEN Round(A.AmountInDollars, 2, 0) --Para EASYPAGOS (Coop. Jardín Azuayo)																													  
    when isnull(UseRefExrate,0) = 0 then A.AmountInDollars 
    else round(A.AmountInMN/A.referenceexrate,4)
end
as OriginationAmount,

C.AgentState as OriginationState,   --M00095                              
Case A.IdPaymentType When 1 Then 'C'                                 
  When 2 Then 'D'  When 4 Then 'C' End as PaymentType,                                
case J.CurrencyCode when 'MXP' Then 'MXN' Else J.CurrencyCode End  as PaymentCurrency,                                
Case B.IdCountry  
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

--A.AmountInMN as PaymentAmount,                                
case 
    when isnull(UseRefExrate,0) = 0 then A.AmountInMN 
    else A.AmountInMN
end
as PaymentAmount,

Case  
	When A.IdPaymentType = 2 Then 'DEPOSIT'   
	Else '' 
End as EndAccountType,   

CASE 
	WHEN A.IdPaymentType = 2 AND D.IdPayer = 5641 THEN A.DepositAccountNumber --Para EASYPAGOS (Coop. Jardín Azuayo)																												
	WHEN A.IdPaymentType = 2 AND D.PayerCode = 'EASYP' THEN LTRIM(RTRIM(A.DepositAccountNumber)) + ',' + LTRIM(RTRIM(G.BranchName)) + ',' + 'CC'
	ELSE A.DepositAccountNumber
END as AccountNo,
A.IdAgent as AgentID,                                
C.AgentZipcode as AgentPostalCode,                                
C.AgentState as AgentState,                      
'USA' as AgentCountry,                                
case when BeneficiaryAddress='' Then 'Conocida' Else isNull([dbo].[fn_EspecialChrEKOFFSpace](BeneficiaryAddress),'Conocida') End as BenAddress,                                
case when isnull(BeneficiaryCity,'Conocida')='' Then 'Conocida' Else BeneficiaryCity  End as BenCity,                                
BeneficiaryBornDate as BenDOB,                                
BeneficiaryName as BenFirst,                                
--Importane: Para EASYPAGOS solo se acepta la operacion si BenIdNumber y BendIDType van vacios o si ambos van con informacion
CASE 
	WHEN D.PayerCode = 'EASYP' THEN 
		CASE A.IdPaymentType 
			WHEN 1 THEN '' 
			WHEN 2 THEN isnull(BeneficiaryIdentificationNumber,'1234567890') --Cuando se acepten depositos con EASYPAGOS y se tenga en el sistema la captura de la cedula del beneficiario entonces reemplazar este campo
		END 
	ELSE '123456' 
END as BenIDNumber,                                
CASE 
	WHEN D.PayerCode = 'EASYP' AND D.IdPayer = 5641 THEN ('Cedula') --Para EASYPAGOS (Coop. Jardín Azuayo)																															 
	WHEN D.PayerCode = 'EASYP' THEN 
		CASE A.IdPaymentType 
			WHEN 1 THEN '' 
			--WHEN 2 THEN isnull(benid.BTSIdentificationType,'Cedula') --Para EASYPAGOS este valor es hardcode
			WHEN 2 THEN isnull(benid.BTSIdentificationType,'GOV') --Para EASYPAGOS este valor es hardcode--#6
		END 
	WHEN D.PayerCode = 'EXITO' THEN --Pare exito este valor es harcode (CC Cedula de Ciudadania/CE Cedula de Extranjería)
        --'CC Cedula de Ciudadania'
		'GOV'--#5
	ELSE 'vot'
END as  BenIDType,                                
BeneficiarySecondLastName as BenMLast,                                
BeneficiaryOccupation as BenOccupation,                                
BeneficiaryFirstLastName as BenPLast,                                
BeneficiarySSNumber as BenSSN,                                
F.CountryCode as BenCountry,                                
--isnull(I.StateCode,'') as BenState, 
isnull(I.StateCodeTNC, 
	case 
		when A.IdPaymentType=2 then st.StateCodeTNC
	else '' end) BenState,	
--I.StateCodeTNC as BenState,       --M00095
case when BeneficiaryPhoneNumber='' Then '0000000' else IsNull(substring(BeneficiaryPhoneNumber,1,18),'0000000') end as BenTel,                                
case when BeneficiaryZipCode ='' Then '00000' else Isnull(BeneficiaryZipCode,'00000') End as BenPostalCode,                                
Case B.IdCountry  
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
[dbo].[fn_EspecialChrEKOFFSpace](CustomerAddress) as ClientAddress,                                
CustomerCity as ClientCity,                                
CustomerBornDate as ClientDOB,                                
CustomerName as ClientFirst,                                
'' as ClientMiddleName,                                
CustomerFirstLastName  as ClientPLast,         
CustomerSecondLastName as ClientMLast,                                
CustomerOccupation as ClientOccupation,                    
CustomerSSNumber as ClientSSN,                                
CustomerState as ClientState,                                
case CustomerPhoneNumber when '' then '1'  when null then '1' Else CustomerPhoneNumber  End as ClientTel,                                
CustomerZipCode as ClientPostalCode,                                
'MEX' as ClientCOB,                              
'USA' as ClientCountry,                                                              
isnull(CustomerIdentificationNumber,'') as ClientIDNumber,                                
isnull(TransNetworkIDType,'') as ClientIDType,       --M00095
'USA' as ClientIDCountry,                   
''  as ClientIDState,                                
Isnull(CustomerExpirationIdentification,'') as ClientIDExpDate,                                
'' as CustomField1,                                
'US'+LTRIM(RTRIM(C.AgentState))+dbo.FunTNWAmountToString(fee) as CustomField2,                                
'' as Note,                                
case when D.PayerCode='CUSC' and A.IdPaymentType=1 then 'TNSLV'--#8
     when D.PayerCode='CITG' then 'TNGTM'
     when D.PayerCode='CITH' then 'TNHND'
     when D.PayerCode='BU06' then 'TNNIC'
     when D.PayerCode='CITP' then 'TNPAN'
     when D.PayerCode='CITR' then 'TNCRI'
     when D.PayerCode='BP01' then 'TNPER'
     when D.PayerCode='EC01' then 'TNECU'
	 when D.PayerCode='EK6' then 'ELKTR'

	 when D.IdPayer=447 and A.IdPaymentType=2 then 'CUSC'--/* #8
	 when D.IdPayer=5328 and A.IdPaymentType=2 then 'PRAM'--*/ #8
	 when D.IdPayer=5337 and A.IdPaymentType=2 then 'FDCD'--*/ #9
	 when D.IdPayer=5340 and A.IdPaymentType=2 then 'FDCD'--*/ #11
else 
    D.PayerCode
end
as PayerName,     
case 
    when D.payercode='GYTCO' and A.IdPaymentType = 2  and len (DepositAccountNumber)=11 then substring(DepositAccountNumber,1,3)
	WHEN D.PayerCode='EK6' AND A.IdPaymentType=2 THEN '0000'
	else ISNULL(NULLIF(A.GatewayBranchCode, ''), '0') 
end PayerLocationID  ,                
--convert(varchar(10),' ') as AccountType                              
case--#1
	when D.PayerCode='EASYP' and A.IdPaymentType=2 and AccountTypeId = 1 then convert(varchar(10),'CC')--Para EASYPAGOS (Coop. Jardín Azuayo)
	when D.PayerCode='EASYP' and A.IdPaymentType=2 and AccountTypeId = 2 then convert(varchar(10),'CA')--Para EASYPAGOS (Coop. Jardín Azuayo)																																								
	when D.PayerCode='PICHIN' and A.IdPaymentType=2 and AccountTypeId = 1 then convert(varchar(10),'Checking')--#14
	when D.PayerCode='PICHIN' and A.IdPaymentType=2 and AccountTypeId = 2 then convert(varchar(10),'Savings')--#14
	when D.PayerCode='BAM' and A.IdPaymentType=2 then convert(varchar(10),'Corriente')
	when D.PayerCode='BRGT' and A.IdPaymentType=2 then convert(varchar(10),'Savings')--#2
	when D.PayerCode='BDRHND' and A.IdPaymentType=2 then convert(varchar(10),'Savings')--#3
	when D.PayerCode='MMDOM' and A.IdPaymentType=2 then convert(varchar(10),'Savings')--#4
	when D.IdPayer=5337 and A.IdPaymentType=2 then convert(varchar(10),'Savings')--Fedecrédito #9
	when D.IdPayer=5340 and A.IdPaymentType=2 then convert(varchar(10),'Savings')--Fedecrédito #11
	when D.IdPayer in (7030,7031,7032,7033,7034,7035,7036,7037,7038,7039,7040,7041,7042,7043,7044,7045,7046,7047,7048,7049,
		7050,7051,7052,7053,7054,7055,7056,7057,7058,7059,7060,7061,7062,7063,7064,7065,7066,7067,7068,7069,7070,7071,7072,7073,7074,7075,7076,7077,7079,7080,7081,7082,7083,7084,
		7085,7086,7087,7088,7089,7090,7091,7092,7093,7094,7095,7096) and A.IdPaymentType=2 and A.AccountTypeId = 2 then convert(varchar(10),'SAVINGS')--Teledolar #17
	when D.IdPayer in (7030,7031,7032,7033,7034,7035,7036,7037,7038,7039,7040,7041,7042,7043,7044,7045,7046,7047,7048,7049,
		7050,7051,7052,7053,7054,7055,7056,7057,7058,7059,7060,7061,7062,7063,7064,7065,7066,7067,7068,7069,7070,7071,7072,7073,7074,7075,7076,7077,7079,7080,7081,7082,7083,7084,
		7085,7086,7087,7088,7089,7090,7091,7092,7093,7094,7095,7096) and A.IdPaymentType=2 and A.AccountTypeId = 1 then convert(varchar(10),'OTHER')--Teledolar #17
	WHEN D.PayerCode='EK6' AND A.IdPaymentType=2 THEN-- convert(varchar(10),'Savings')--#4
		CASE LEN(A.DepositAccountNumber)
			WHEN 18 THEN 'CLABE'
			WHEN 16 THEN 'CARD'
			WHEN 14 THEN 'Savings'
			WHEN 20 THEN 'Savings'
			ELSE ''
		END
	else convert(varchar(10),' ') 
end
as AccountType, 
Purpose, 
Relationship, 
MoneySource, 
ExRate,  --M00095
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
'' as ClientGender  --M00095
From dbo.[Transfer] A WITH (NOLOCK)             
Join dbo.CountryCurrency B WITH (NOLOCK) on (A.IdCountryCurrency=B.IdCountryCurrency)                                
Join dbo.Agent C WITH (NOLOCK) On (A.IdAgent=C.IdAgent)                                
Join dbo.Payer D WITH (NOLOCK) on (D.IdPayer=A.IdPayer)                                
Left Join dbo.CustomerIdentificationType E WITH (NOLOCK) on (E.IdCustomerIdentificationType=A.CustomerIdCustomerIdentificationType)                                
Join dbo.Country F WITH (NOLOCK) on (F.IdCountry=B.IdCountry)                      
left Join dbo.Branch G WITH (NOLOCK) on (A.IdBranch=G.IdBranch)                          
left Join dbo.City H WITH (NOLOCK) on (G.IdCity=H.IdCity)                          
left Join dbo.[State] I WITH (NOLOCK) on (H.IdState=I.IdState)
left join dbo.City cit WITH (NOLOCK) on cit.IdCity = A.TransferIdCity
left join dbo.[State] st WITH (NOLOCK) on cit.idstate=st.idstate
Join dbo.Currency J WITH (NOLOCK) on (J.IdCurrency=B.IdCurrency)                                  
left join dbo.[BeneficiaryIdentificationType] benid WITH (NOLOCK) on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
left join dbo.CountryExrateConfig cex WITH (NOLOCK) on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
where a.IdGateway=3 and IdStatus=21

