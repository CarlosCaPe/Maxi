CREATE procedure [dbo].[st_GetBGuayaquilBankDeposits]
(
	@Limit				INT = NULL
)
AS
/********************************************************************
<Author></Author>
<app>Aggregators :BGuayaquil</app>
<Description>Get BGuayaquil operations</Description>
<ChangeLog>
<log Date="11/11/2022" Author="adominguez" Name="#1">Se muestra codigo de pais en formato ISO3166.</log>
</ChangeLog>
*********************************************************************/
--Set nocount on

Begin try

--- Get Minutes to wait to be send to service ---
Declare @MinutsToWait Int
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes With(nolock)  where Name='TimeFromReadyToAttemp'
--Set @MinutsToWait=0

--- Update transfer to Attempt -----------------
if (@Limit > 0)
Begin
	Select top (@Limit) IdTransfer into #temp from Transfer WITH (NOLOCK) Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=54 and IdStatus=20 AND IdPaymentType = 2
	Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)

	--------- Tranfer log ---------------------------
	Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
	Select 21,IdTransfer,GETDATE() from #temp
end
else
Begin
	Select top 1000 IdTransfer into #temp2 from Transfer WITH (NOLOCK) Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=54 and IdStatus=20 AND IdPaymentType = 2
	Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp2)
		--------- Tranfer log ---------------------------
	Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)
	Select 21,IdTransfer,GETDATE() from #temp2
End



Select top 1000
A.DateOfTransfer			T_processDateTime,
'READY_TO_PAY'				T_orderStatus,
--COUNT(A.IdTransfer)		listCounter,
A.ClaimCode					PD_moneyTransferCode,
A.IdTransfer				PD_saleMovementID,
A.DateOfTransfer			PD_saleDateTime,
'BANK_DEPOSIT'				PD_paymentTypeCode,
D.CurrencyCode				SA_currencyCode,
A.AmountInDollars			SA_amount,
A.ExRate					SA_exchangeRate,
A.AmountInDollars			RA_amount,
'USD'						RA_currencyCode,
'017'					    BD_bankCode,
cASE 
WHEN A.AccountTypeId = 1 then 'CHECKING' 
WHEN A.AccountTypeId = 2 then 'SAVINGS'
ELSE '' END 				BD_accountType,
a.DepositAccountNumber		BD_accountNumber,
A.CustomerName				SD_firsName,
''							SD_middleName,
A.CustomerFirstLastName		SD_lastName,
A.CustomerSecondLastName	SD_motherLastName,
case 
	when benid.Name = 'CEDULA' then 'NATIONAL_ID_CARD'
	when benid.Name = 'PASSPORT' then 'PASSPORT'
else '' 
End							SID_type,
A.CustomerIdentificationNumber SID_number,
A.CustomerExpirationIdentification SID_expirationDate,
''							SID_issuerCountryCode,
''							SID_issuerStateCode,
A.CustomerAddress			SAD_street,
A.CustomerCity				SAD_city,
''							SAD_stateCode,
C1.CountryCodeISO3166		SAD_countryCode,--#1
A.CustomerZipcode			SAD_zipCode,
A.CustomerPhoneNumber		SD_firstPhone,
''							SD_secondPhone,
Cus.BornDate				SD_dateOfBirth,
''							SD_countryOfBirth,
''							SD_occupation,
''							SD_email,
A.BeneficiaryName			RD_firsName,
''							RD_middleName,
A.BeneficiaryFirstLastName	RD_lastName,
A.BeneficiarySecondLastName	RD_motherLastName,
case 
	when K.Name = 'CEDULA' then 'NATIONAL_ID_CARD'
	when K.Name = 'PASSPORT' then 'PASSPORT'
else '' 
End							RID_type,
BEN.IdentificationNumber	RID_number,
getdate()					RID_expirationDate,
''							RID_issuerCountryCode,
''							RID_issuerStateCode,
A.BeneficiaryAddress		RAD_street,
A.BeneficiaryCity			RAD_city,
''							RAD_stateCode,
C2.CountryCodeISO3166		RAD_countryCode,--#1
''							RAD_zipCode,
A.BeneficiaryPhoneNumber	RD_firstPhone,
''							RD_secondPhone,
BEN.BornDate				RD_dateOfBirth,
''							RD_countryOfBirth,
''							RD_occupation,
''							RD_email
From Transfer A WITH(NOLOCK)
    Join CountryCurrency B WITH(NOLOCK) on (A.IdCountryCurrency=B.IdCountryCurrency)
    Join Country C WITH(NOLOCK) on (B.IdCountry=C.IdCountry)
    Join Currency D WITH(NOLOCK) on (D.IdCurrency=B.IdCurrency)
    Join Agent E WITH(NOLOCK) on (A.IdAgent=E.IdAgent)
    Join Users F WITH(NOLOCK) on (F.IdUser=A.EnterByIdUser)
    Join Payer G WITH(NOLOCK) on (G.IdPayer=A.IdPayer)
	join Customer Cus WITH(NOLOCK) on (Cus.IdCustomer = A.IdCustomer)
	left Join Country C1 WITH(NOLOCK) on (a.CustomerCountry=C1.CountryCode)
	left Join Country C2 WITH(NOLOCK) on (A.BeneficiaryCountry=C2.CountryName)
    Left Join Branch H WITH(NOLOCK) on (H.IdBranch=A.IdBranch)
    Left Join City I WITH(NOLOCK) on (I.IdCity=H.IdCity)
    Left Join State J WITH(NOLOCK) on (J.IdState=I.IdState)
    Left Join CustomerIdentificationType K WITH(NOLOCK) on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)
    left join beneficiary ben WITH(NOLOCK) on ben.idbeneficiary=a.idbeneficiary
    left join [BeneficiaryIdentificationType] benid WITH(NOLOCK) on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
    left join CountryExrateConfig cex WITH(NOLOCK) on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway = 54 
    And IdStatus = 21
	AND A.IdPaymentType = 2
    --And IdTransfer in (9985299,9985300);

End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessage nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(20), ERROR_LINE()), 
	   @ErrorMessage = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetBGuayaquilBankDeposits',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

End Catch