CREATE procedure [dbo].[st_GetBGuayaquilBankDepositsCancel]
-- EXEC [dbo].[st_GetBGuayaquilBankDepositsCancel] 1
(
	@Limit				INT = NULL
)
AS
/********************************************************************
<Author></Author>
<app>Aggregators :BGuayaquil</app>
<Description>Get BGuayaquil operations</Description>
<ChangeLog>
</ChangeLog>
*********************************************************************/
--Set nocount on
IF @Limit = 0 
	SET @Limit = 1000

Begin try

Select top (5)
A.DateOfTransfer			T_processDateTime,
'READY_TO_CANCEL'				T_orderStatus,
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
g.PayerCode					BD_bankCode,
cASE 
WHEN AC.AccountTypeId = 1 then 'CHECKING' 
WHEN AC.AccountTypeId = 2 then 'SAVINGS'
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
A.CustomerCountry			SAD_countryCode,
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
A.BeneficiaryCountry		RAD_countryCode,
''							RAD_zipCode,
A.BeneficiaryPhoneNumber	RD_firstPhone,
''							RD_secondPhone,
BEN.BornDate				RD_dateOfBirth,
''							RD_countryOfBirth,
''							RD_occupation,
''							RD_email
From Transfer A
    Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)
    Join Country C on (B.IdCountry=C.IdCountry)
    Join Currency D on (D.IdCurrency=B.IdCurrency)
    Join Agent E on (A.IdAgent=E.IdAgent)
    Join Users F on (F.IdUser=A.EnterByIdUser)
    Join Payer G on (G.IdPayer=A.IdPayer)
	join Customer Cus on (Cus.IdCustomer = A.IdCustomer)
	left join AccountTypePayer AC on AC.AccountTypeId = A.AccountTypeId
    Left Join Branch H on (H.IdBranch=A.IdBranch)
    Left Join City I on (I.IdCity=H.IdCity)
    Left Join State J on (J.IdState=I.IdState)
    Left Join CustomerIdentificationType K on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)
    left join beneficiary ben on ben.idbeneficiary=a.idbeneficiary
    left join [BeneficiaryIdentificationType] benid on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
    left join CountryExrateConfig cex on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway = 54 
    And IdStatus = 25
	AND A.IdPaymentType = 2

--Select top 1000
--A.DateOfTransfer			T_processDateTime,
--'READY_TO_CANCEL'			T_orderStatus,
----COUNT(A.IdTransfer)		listCounter,
--A.ClaimCode					PD_moneyTransferCode,
--A.IdTransfer				PD_saleMovementID,
--A.DateOfTransfer			PD_saleDateTime,
--'BANK_DEPOSIT'				PD_paymentTypeCode
--From Transfer A
--Where a.IdGateway = 54 
--    And IdStatus = 25
--	AND A.IdPaymentType = 2

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