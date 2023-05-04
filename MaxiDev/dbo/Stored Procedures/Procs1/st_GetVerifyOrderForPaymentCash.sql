CREATE procedure [dbo].[st_GetVerifyOrderForPaymentCash] --'11063926737'
(
	@ClaimCode varchar(50)
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



Select 
A.DateOfTransfer			T_processDateTime,
case 
	when A.IdStatus in (20,21) then 'READY_TO_PAY'
	when A.IdStatus = 23 then 'DEPOSIT_IN_PROCESS'
	when A.IdStatus = 40 then 'CONFIRM_RECEIVED'
	when A.IdStatus = 22 then 'CANCELLED'
	when A.IdStatus = 30 then 'PAID'
	when A.IdStatus = 25 then 'CONFIRM_CANCELLED'
	when A.IdStatus = 25 then 'READY_TO_CANCEL'
	when A.IdStatus = 25 then 'ABORT'
	when A.IdStatus = 22 then 'CANCELLED'
END							T_orderStatus,
A.ClaimCode					PD_moneyTransferCode,
A.IdTransfer				PD_saleMovementID,
A.DateOfTransfer			PD_saleDateTime,
'CASH_PICKUP'				PD_paymentTypeCode,
D.CurrencyCode				SA_currencyCode,
A.AmountInDollars			SA_amount,
A.ExRate					SA_exchangeRate,
A.AmountInDollars			RA_amount,
'USD'						RA_currencyCode,
A.CustomerName				SD_firsName,
''							SD_middleName,
A.CustomerFirstLastName		SD_lastName,
A.CustomerSecondLastName	SD_motherLastName,
A.CustomerAddress			SAD_street,
A.CustomerCity				SAD_city,
''							SAD_stateCode,
C1.CountryCodeISO3166		SAD_countryCode,--#1
A.CustomerZipcode			SAD_zipCode,
A.CustomerPhoneNumber		SD_firstPhone,
A.BeneficiaryName			RD_firsName,
''							RD_middleName,
A.BeneficiaryFirstLastName	RD_lastName,
A.BeneficiarySecondLastName	RD_motherLastName,
A.BeneficiaryAddress		RAD_street,
A.BeneficiaryCity			RAD_city,
''							RAD_stateCode,
C2.CountryCodeISO3166		RAD_countryCode,--#1
''							RAD_zipCode,
A.BeneficiaryPhoneNumber	RD_firstPhone
From Transfer A with(nolock)
    Join CountryCurrency B with(nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)
    Join Country C with(nolock) on (B.IdCountry=C.IdCountry)
    Join Currency D with(nolock) on (D.IdCurrency=B.IdCurrency)
    Join Agent E with(nolock) on (A.IdAgent=E.IdAgent)
    Join Users F with(nolock) on (F.IdUser=A.EnterByIdUser)
    Join Payer G with(nolock) on (G.IdPayer=A.IdPayer)
	join Customer Cus with(nolock) on (Cus.IdCustomer = A.IdCustomer)
	left Join Country C1 WITH(NOLOCK) on (a.CustomerCountry=C1.CountryCode)
	left Join Country C2 WITH(NOLOCK) on (A.BeneficiaryCountry=C2.CountryName)
    Left Join Branch H with(nolock) on (H.IdBranch=A.IdBranch)
    Left Join City I with(nolock) on (I.IdCity=H.IdCity)
    Left Join State J with(nolock) on (J.IdState=I.IdState)
    Left Join CustomerIdentificationType K with(nolock) on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)
    left join beneficiary ben with(nolock) on ben.idbeneficiary=a.idbeneficiary
    left join [BeneficiaryIdentificationType] benid with(nolock) on benid.IdBeneficiaryIdentificationType=a.IdBeneficiaryIdentificationType
    left join CountryExrateConfig cex with(nolock) on B.idcountry=cex.idcountry and cex.IdGenericStatus=1 and cex.idgateway=a.idgateway
Where a.IdGateway = 54 
	AND A.IdPaymentType in(1,4)
    and A.Claimcode = @ClaimCode

End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessage nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(20), ERROR_LINE()), 
	   @ErrorMessage = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetVerifyOrderForPaymentCash',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

End Catch