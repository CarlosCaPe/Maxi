CREATE Procedure [dbo].[st_GetTTAPI]
AS
/********************************************************************
<Author></Author>
<app>PaymentServices : PaymentService.TransferToV2 - TTAPI </app>
<Description>Get Monty operations in payment ready </Description>

<ChangeLog>
<log Date="03/05/2018" Author="snevarez">Get operations in payment ready</log>
</ChangeLog>
*********************************************************************/
Set nocount on  
               
--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int;
Select @MinutsToWait=Convert(int,Value)
    From GlobalAttributes 
Where Name='TimeFromReadyToAttemp';
--set @MinutsToWait=5                         
                            
---  Update transfer to Attempt -----------------
Select IdTransfer 
    into #temp from Transfer WITH(NOLOCK)
Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait
    and IdGateway=35
    and IdStatus=20
    --and IdTransfer in (9986083,9986081,9986071,9985795) /*Test New Mapeo*/;

Update Transfer 
    Set 
	   IdStatus=21
	   ,DateStatusChange=GETDATE()
Where IdTransfer in (Select IdTransfer from #temp);
--------- Tranfer log ---------------------------
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
Select 21,IdTransfer,GETDATE() from #temp;

select 
    a.idtransfer,
    
    --ClaimCode as external_id,
     /*2018-May-03*/
	   CASE WHEN s.serial IS NULL 
		  THEN A.ClaimCode 
		  ELSE A.ClaimCode + '_' + CONVERT(nvarchar(max),s.serial) 
	   END as external_id,

    /*
    5250	Tigo Money SLV		159
	5251	Dummy Mobile Wallet	1
    5252	Dummy Bank Account	2
    5253	Tigo Money USD	5
    5254	Tigo Money GTQ	38
    5255	Dummy Cash Pick-up	342
    */
    --p.payercode as payer_id,
    case 
	    when a.IdPayer=5250 then '159'
		when a.IdPayer=5251 then '1'
	    when a.IdPayer=5252 then '2'
	    when a.IdPayer=5253 then '5'
	    when a.IdPayer=5254 then '38'
	    when a.IdPayer=5255 then '342'
	   else ''
    end payer_id,
    'DESTINATION_AMOUNT' as mode,
    null as source_amount,
    'USD' as source_currency,
    'USA' as source_country_iso_code,
    a.AmountInMN as destination_amount,
    c.CurrencyCode as destination_currency,
    a.ExRate as retail_rate,
    '' as additional_information_1,
    '' as additional_information_2,
    '' as additional_information_3,

    -- revisar si existe catalogo del lado del proveedor
    a.Purpose as purpose_of_remittance,

    '' as callback_url,
    'USD' as retail_fee_currency,
    '' as external_code,
    case 
	    when a.IdPaymentType=5 then a.DepositAccountNumber 
	    when a.IdPaymentType=1 then a.BeneficiaryCelularNumber 
	    else '' 
    end as credit_party_identifier_msisdn,
    --case when a.IdPaymentType=2 then a.DepositAccountNumber else '' end as credit_party_identifier_bank_account_number,
    --'' as credit_party_identifier_msisdn,
    case when a.IdPaymentType=2 then a.DepositAccountNumber else '' end as credit_party_identifier_bank_account_number,
    '' as credit_party_identifier_swift_bic_code,
    a.fee as retail_fee,
    a.CustomerName as sender_firstname,
    convert(varchar(10),a.CustomerExpirationIdentification,120) as sender_id_expiration_date,
    a.CustomerFirstLastName + isnull(' '+ a.CustomerSecondLastName,'') as sender_lastname,
    isnull(cusc.CountryCode,'') as sender_country_of_birth_iso_code,
    a.MoneySource as sender_source_of_funds,
    convert(varchar(10),a.CustomerBornDate,120) as sender_date_of_birth,
    'USA' as sender_country_iso_code,
    Relationship as sender_beneficiary_relationship,
    '' as sender_nativename,
    case when isnull(idc.CountryCode,'')='' and len(isnull(CustomerIdentificationNumber,''))>0 then 'USA' else isnull(idc.CountryCode,'') end as sender_id_country_iso_code,
    '' as sender_email,
    CustomerCity as sender_city,
    a.CustomerZipcode as sender_postal_code,
    /*
    PASSPORT, 
    NATIONAL_ID, 
    OTHER, 
    SOCIAL_SECURITY, 
    TAX_ID, 
    SENIOR_CITIZEN_ID, 
    BIRTH_CERTIFICATE, 
    VILLAGE_ELDER_ID, 
    RESIDENT_CARD, 
    ALIEN_REGISTRATION, 
    PAN_CARD, VOTERS_ID, 
    HEALTH_CARD, 
    EMPLOYER_ID, 
    OTHER*/
    case 
	   when a.CustomerIdCustomerIdentificationType=1 then 'OTHER'
	   when a.CustomerIdCustomerIdentificationType=2 then 'OTHER'
	   when a.CustomerIdCustomerIdentificationType=3 then 'PASSPORT'
	   when a.CustomerIdCustomerIdentificationType=4 then 'ALIEN_REGISTRATION'
	   when a.CustomerIdCustomerIdentificationType=5 then 'OTHER'
	   when a.CustomerIdCustomerIdentificationType=6 then 'VOTERS_ID'
	   when a.CustomerIdCustomerIdentificationType=7 then 'OTHER'
	   when a.CustomerIdCustomerIdentificationType=8 then 'PASSPORT'
	   when a.CustomerIdCustomerIdentificationType=9 then 'OTHER'
	   else 'OTHER'
    end as sender_id_type,
    a.CustomerAddress as sender_address,
    a.CustomerIdentificationNumber as sender_id_number,
    '' as sender_gender,
    '' as sender_code,
    '' as sender_id_delivery_date,
    '' as sender_middlename,
    isnull(a.CustomerOccupation,'') as occupation,
    a.CustomerState as sender_province_state,
    replace(replace(replace(replace(isnull(a.CustomerPhoneNumber,''),' ',''),')',''),'(',''),'-','') as sender_msisdn,
    isnull(cusbc.CountryCode,'') as nationality_country_iso_code,

    a.BeneficiaryName as beneficiary_firstname,
    '' as beneficiary_bank_account_holder_name,
    '' as beneficiary_id_expiration_date,
    '' as beneficiary_lastname2,
    convert(varchar(10),a.BeneficiaryBornDate,120) as beneficiary_date_of_birth,
    isnull(bc.CountryCode,'') as beneficiary_country_iso_code,
    a.BeneficiaryFirstLastName + isnull(' '+ a.BeneficiarySecondLastName,'') as beneficiary_lastname,
    '' as beneficiary_nativename,
    '' as beneficiary_id_country_iso_code,
    '' as beneficiary_email,
    '' as beneficiary_city,
    a.BeneficiaryZipcode as beneficiary_postal_code,
    '' as beneficiary_id_type,
    a.BeneficiaryAddress as beneficiary_address,
    '' as beneficiary_id_number,
    '' as beneficiary_gender,
    '' as beneficiary_code,
    '' as beneficiary_id_delivery_date,
    '' as beneficiary_middlename,
    isnull(BeneficiaryOccupation,'') as beneficiary_occupation,
    '' as beneficiary_province_state,
    isnull(benbc.CountryCode,'') as beneficiary_country_of_birth_iso_code,
    a.DepositAccountNumber as beneficiary_msisdn,
    isnull(benbc.CountryCode,'') as beneficiary_nationality_country_iso_code

From Transfer A WITH(NOLOCK)
    join payer p WITH(NOLOCK) on p.IdPayer=a.IdPayer
    join CountryCurrency cc WITH(NOLOCK) on cc.IdCountryCurrency=a.IdCountryCurrency
    join Currency c WITH(NOLOCK) on c.IdCurrency=cc.IdCurrency
    left join Country cusc WITH(NOLOCK) on cusc.IdCountry=a.CustomerIdCountryOfBirth
    left join Country idc WITH(NOLOCK) on idc.IdCountry=a.CustomerIdentificationIdCountry
    left join CustomerIdentificationType idt WITH(NOLOCK) on idt.IdCustomerIdentificationType=a.CustomerIdCustomerIdentificationType
    left join Country cusbc WITH(NOLOCK) on cusbc.IdCountry=a.CustomerIdCountryOfBirth
    left join Country bc WITH(NOLOCK) on bc.IdCountry=cc.IdCountry
    left join Country benbc WITH(NOLOCK) on benbc.IdCountry=a.BeneficiaryIdCountryOfBirth
    left join [dbo].[TTApiSerial] AS s WITH(NOLOCK) on A.IdTransfer=s.IdTransfer
where  IdGateway=35 and  IdStatus=21;