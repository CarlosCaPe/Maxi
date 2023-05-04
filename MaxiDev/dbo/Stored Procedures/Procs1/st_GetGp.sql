
CREATE procedure [dbo].[st_GetGp]                                    
as
--/********************************************************************
--<Author>jVelarde</Author>
--<app>MaxiGateways</app>
--<Description></Description>

--<ChangeLog>
--<log Date="2017/08/01" Author="snevarez">S32 :: Change of code by Mexico(ISO3)</log>
--</ChangeLog>
--********************************************************************/                       
Set nocount on                                     
                                              
--- Get Minutes to wait to be send to service ---                                              
Declare @MinutsToWait Int                                              
Declare @IdGateway int = 34
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                       
                                         
                                              
---  Update transfer to Attempt -----------------                                              
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=@IdGateway and  IdStatus=20                                            
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                                  
--------- Tranfer log ---------------------------                                          
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                           
Select 21,IdTransfer,GETDATE() from #temp                                            
                                    
                                    
                              
Select  
    e.AgentCode as AgentCode,
    e.AgentName as AgentName,
    isnull(e.AgentAddress,'') as AgentAddress,
    isnull(e.AgentCity,'') as AgentCity,
    isnull(e.AgentState,'') as AgentStateCode,
    isnull(e.AgentZipcode,'') as AgentPostalCode,
    'US' as AgentCountryCode,

    replace(CONVERT(VARCHAR(10),a.dateoftransfer,102), '.','') as DateT,
    replace(convert(varchar, a.dateoftransfer, 108), ':','') as TimeT,

    a.ClaimCode as ConfirmationNumber,
    case 
	    when a.IdPaymentType=1 then 'Cash'
	    --when a.IdPaymentType=2 then 2
	    --when a.IdPaymentType=3 then 3
	    when a.IdPaymentType=4 then 'Cash'
    else
	    ''
    end as DestinationPaymentMethodCode,
    'US' as OriginCountryCode,
    c.CountryCodeISO3166 as DestinationCountryCode,
    a.AmountInDollars as AmountSend,
    a.Fee as FeeAmount,
    'USD' as OriginCurrencyCode,
    a.ExRate as ExchangeRate,
    a.AmountInMN as DestinationAmount,
    case when d.CurrencyCode='MXP' then 'MXN' else d.CurrencyCode end as DestinationCurrencyCode,
    '' as SenderMessage,
    '' as Instructions,
    case when a.IdPaymentType=2 then 'Cdr' else '' end BankAccountTypeCode, --Cdr Credit, crdt Credit 2
    case when a.IdPaymentType=2 then isnull(a.DepositAccountNumber,'') else '' end as BankAccountNumber,
    case when a.IdPaymentType=2 then g.PayerCode else '' end as BankCode,
    case when a.IdPaymentType=2 then g.PayerName else '' end as BankName,

    a.IdCustomer as SenderCustomerIdentifier,
    a.CustomerName as SenderFirstName,
    '' as SenderMiddleName,
    a.CustomerFirstLastName as SenderLastName,
    a.CustomerSecondLastName as SenderSecondLastName,
    a.CustomerAddress as SenderAddress,
    a.CustomerCity as SenderCity,
    a.CustomerState as SenderStateCode,
    a.CustomerZipcode as SenderPostalCode,
    'US' as SenderCountryCode,
    case when len(isnull(a.CustomerPhoneNumber,''))>0 then a.CustomerPhoneNumber else   case when len(isnull(a.CustomerCelullarNumber ,''))>0 then a.CustomerCelullarNumber else '999-999-9999' end end as SenderPhone,
    a.CustomerCelullarNumber as SenderMobilePhone,
    '' as SenderEmail,
    case 
	    when isnull(k.IdCustomerIdentificationType,0) =1 then 'SID'	
	    when isnull(k.IdCustomerIdentificationType,0) =2 then 'DLS'
	    when isnull(k.IdCustomerIdentificationType,0) =3 then 'PAS'
		when isnull(k.IdCustomerIdentificationType,0) =4 then 'RAC'
		when isnull(k.IdCustomerIdentificationType,0) =5 then 'MAC'
		when isnull(k.IdCustomerIdentificationType,0) =6 then 'CDE'
		when isnull(k.IdCustomerIdentificationType,0) =7 then 'SID'
		when isnull(k.IdCustomerIdentificationType,0) =8 then 'PAS'
		when isnull(k.IdCustomerIdentificationType,0) =9 then 'MID'
		when isnull(k.IdCustomerIdentificationType,0) =59 then 'RAC'
		when isnull(k.IdCustomerIdentificationType,0) =60 then 'RAC'
		when isnull(k.IdCustomerIdentificationType,0) =61 then 'RAC'
		when isnull(k.IdCustomerIdentificationType,0) =63 then 'RAC'

	    --else isnull(k.BTSIdentificationType,'')
	    else ''
    end
    as SenderITypeCode, --verificar
    a.CustomerIdentificationNumber as SenderINumber,
    isnull(case when k.BTSIdentificationIssuer = 'FED' then 'GOV' ELSE k.BTSIdentificationIssuer END,'') as SenderIIssueEntityCode, --verificar
    isnull(ic.CountryCodeISO3166,'') as SenderIIssueCountryCode,
    case when ic.CountryCode = 'USA' then ist.StateCode else '' end as SenderIIssueStateCode,
    replace(CONVERT(VARCHAR(10), a.CustomerExpirationIdentification, 112), '.','')  as SenderIExpirationDate,
    replace(CONVERT(VARCHAR(10), a.CustomerBornDate, 112), '.','') as SenderDateOfBirth,
    isnull(ISS.CountryCodeISO3166,'') as SenderCountryOfBirthCode,
    '' /*isnull(a.CustomerOccupation,'')*/ as SenderOccupation,
    case 
	    when a.MoneySource = 'SAVINGS' then 'SAV' 
	    when a.MoneySource = 'AHORROS' then 'SAV' 
	    when a.MoneySource = 'TAX REFUND' then 'ITX' 
	    when a.MoneySource = 'REEMBOLSO DE IMPUESTOS' then 'ITX' 
	    when a.MoneySource = 'WORK (INCOME)' then 'SAL' 
	    when a.MoneySource = 'TRABAJO' then 'SAL' 
	    else ''
    end as SenderSourceOfFundsCode,
    'FAM'  as SenderTransferReasonCode, --HLP Help, HBL Hospital Bill, MPT Mortgage Payment
    case 
	/*
	FRIEND	AMIGO
	SISTER	HERMANA
	BROTHER	HERMANO
	AUNT	TIA
	UNCLE	TIO
	BOYFRIEND	NOVIOCOUSIN	PRIMA
COUSIN	PRIMO
GIRLFRIEND
NOVIA
	*/
	    when a.Relationship = 'AUNT' then 'ANT' 
	    when a.Relationship = 'TIA' then 'ANT' 
		when a.Relationship = 'BOYFRIEND' then 'BYF' 
		when a.Relationship = 'NOVIO' then 'BYF' 
		when a.Relationship = 'BROTHER' then 'BRO' 
	    when a.Relationship = 'HERMANO' then 'BRO' 
	    when a.Relationship = 'FRIEND' then 'FND' 
		when a.Relationship = 'AMIGO' then 'FND' 		
	    when a.Relationship = 'HERMANA' then 'SIS' 
	    when a.Relationship = 'SISTER' then 'SIS' 
		when a.Relationship = 'UNCLE' then 'UNC' 
	    when a.Relationship = 'TIO' then 'UNC' 
		when a.Relationship = 'COUSIN' then 'UNC' 
		when a.Relationship = 'PRIMO' then 'UNC' 
		when a.Relationship = 'PRIMA' then 'UNC' 
		when a.Relationship = 'GIRLFRIEND' then 'GRF' 
		when a.Relationship = 'NOVIA' then 'GRF' 
		
		
	    else ''
    end
	as SenderBeneficiatyRelationCode, -- BRO Brother,  SIS Sister, UNC Uncle
    a.BeneficiaryName as RecipientFirstName,
    '' as RecipientMiddleName,
    a.BeneficiaryFirstLastName as RecipientLastName,
    a.BeneficiarySecondLastName as RecipientSecondLastName,
    a.BeneficiaryAddress as RecipientAddress,
    i.CityName as RecipientCity, --a.BeneficiaryCity

    --case
    --    when si.StateCodeISO3166='AGU' then 'MX - AG' --AGUASCALIENTES
    --    when si.StateCodeISO3166='BCN' then 'MX - BC' --BAJA CALIFORNIA NORTE
    --    when si.StateCodeISO3166='BCS' then '' --BAJA CALIFORNIA SUR
    --    when si.StateCodeISO3166='CAM' then 'MX - CM' --CAMPECHE
    --    when si.StateCodeISO3166='CHP' then 'MX - CS' --CHIAPAS
    --    when si.StateCodeISO3166='CHH' then 'MX - CH' --CHIHUAHUA
    --    when si.StateCodeISO3166='COA' then 'MX - CO' --COAHUILA
    --    when si.StateCodeISO3166='COL' then 'MX - CL' --COLIMA
    --    when si.StateCodeISO3166='DIF' then 'BR-DF' --DISTRITO FEDERAL
    --    when si.StateCodeISO3166='DUR' then 'MX - DG' --DURANGO
    --    when si.StateCodeISO3166='MEX' then '' --ESTADO DE MEXICO
    --    when si.StateCodeISO3166='GUA' then 'MX - GT' --GUANAJUATO
    --    when si.StateCodeISO3166='GRO' then 'MX - GR' --GUERRERO
    --    when si.StateCodeISO3166='HID' then 'MX - HG' --HIDALGO
    --    when si.StateCodeISO3166='JAL' then 'MX - JC' --JALISCO
    --    when si.StateCodeISO3166='MIC' then '' --MICHOACAN
    --    when si.StateCodeISO3166='MOR' then 'MX - MS' --MORELOS
    --    when si.StateCodeISO3166='NAY' then 'MX - NT' --NAYARIT
    --    when si.StateCodeISO3166='NLE' then '' --NUEVO LEON
    --    when si.StateCodeISO3166='OAX' then 'MX - OC' --OAXACA
    --    when si.StateCodeISO3166='PUE' then 'MX - PL' --PUEBLA
    --    when si.StateCodeISO3166='QUE' then '' --QUERETARO
    --    when si.StateCodeISO3166='ROO' then 'MX - QR' --QUINTANA ROO
    --    when si.StateCodeISO3166='SLP' then '' --SAN LUIS POTOSI
    --    when si.StateCodeISO3166='SIN' then 'MX - SL' --SINALOA
    --    when si.StateCodeISO3166='SON' then 'MX - SR' --SONORA
    --    when si.StateCodeISO3166='TAB' then 'MX - TC' --TABASCO
    --    when si.StateCodeISO3166='TAM' then 'MX - TS' --TAMAULIPAS
    --    when si.StateCodeISO3166='TLA' then 'MX - TL' --TLAXCALA
    --    when si.StateCodeISO3166='VER' then 'MX - VZ' --VERACRUZ
    --    when si.StateCodeISO3166='YUC' then '' --YUCATAN
    --    when si.StateCodeISO3166='ZAC' then 'MX - ZS' --ZACATECAS
    --else
    --si.StateCodeISO3166 end as RecipientStateCode,

   case 
		  when si.StateCodeISO3166='DIF' then 'CMX' --DISTRITO FEDERAL/CIUDAD DE MEXICO
		  when si.IdCountry = 9 then replace(si.StateCodeISO3166, 'GT-', '')	--9	GUATEMALA
		  when si.IdCountry = 10 then replace(si.StateCodeISO3166, 'HN-', '') --10	HONDURAS
	    else 
		  si.StateCodeISO3166 end AS RecipientStateCode, /*S32*/

    isnull(a.BeneficiaryZipcode,'') as RecipientPostalCode,
    c.CountryCodeISO3166 as RecipientCountryCode,
    isnull(a.BeneficiaryPhoneNumber,'') as RecipientPhone,
    isnull(a.BeneficiaryCelularNumber,'') as RecipientMobilePhone,
    '' as RecipientEmail,
    '' as RecipientITypeCode,
    '' as RecipientINumber,
    '' as RecipientIIssueEntityCode,
    '' as RecipientIIssueCountryCode,
    '' as RecipientIIssueStateCode,
    null as RecipientIExpirationDate,
    --a.BeneficiaryBornDate as RecipientDateOfBirth,
	replace(CONVERT(VARCHAR(10), a.BeneficiaryBornDate, 112), '.','') as RecipientDateOfBirth,
    '' as RecipientCountryOfBirthCode,
    '' as RecipientStateOfBirthCode,
    '' as RecipientNationalityCode,
    '' as RecipientOccupation,
    '' as RecipientGenderCode,

    g.PayerCode as PayerCode,
    a.GatewayBranchCode as PayerLocationCode

From Transfer A                     
    Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)                                    
    Join Country C on (B.IdCountry=C.IdCountry)
    Join Currency D on (D.IdCurrency=B.IdCurrency)           
    JOIN AGENT E ON E.IDAGENT=A.IDAGENT 
    Join Payer G on (G.IdPayer=A.IdPayer)         
    left Join Country IC on (A.CustomerIdentificationIdCountry=IC.IdCountry)
    left Join State  IST on (A.CustomerIdentificationIdState=IST.IdSTATE)
    left Join Country ISS on (A.CustomerIdCountryOfBirth=ISS.IdCountry)
    LEFT JOIN BRANCH h ON H.IdBranch=A.IdBranch
    LEFT JOIN CITY I ON I.IDCITY=H.IDCITY
    LEFT JOIN STATE SI ON SI.IDSTATE=I.IDSTATE
    Left Join CustomerIdentificationType K on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)    
    --Left Join BeneficiaryIdentificationType L on (A.IdBeneficiaryIdentificationType=L.IdbeneficiaryIdentificationType)  
Where a.IdGateway=@IdGateway and IdStatus=21

