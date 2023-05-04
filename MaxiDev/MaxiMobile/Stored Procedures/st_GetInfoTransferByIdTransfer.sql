CREATE PROCEDURE [MaxiMobile].[st_GetInfoTransferByIdTransfer]
(
	@IdTransfer INT
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> Sp para obtener los datos del cliente y beneficiario de la remesa </Description>

<ChangeLog>
<log Date="05/06/2017" Author="rmacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	select CustomerName, CustomerFirstLastName, CustomerSecondLastName, CustomerOccupation, CustomerOccupationDetail, CustomerAddress, t.CustomerIdCustomerIdentificationType, 
		ci.Name as CustomeridentifycationName, CustomerIdentificationNumber, CustomerSSNumber, CustomerBornDate, CustomerIdCountryOfBirth, ccb.CountryEs, BeneficiaryName, BeneficiaryFirstLastName, 
		BeneficiarySecondLastName, BeneficiaryBornDate, BeneficiaryIdCountryOfBirth, bcb.CountryEs, t.IdBeneficiaryIdentificationType, bi.Name, BeneficiaryIdentificationNumber 
	from Transfer (nolock) t
	left join CountryBirth (nolock) ccb on ccb.IdCountryBirth = t.CustomerIdCountryOfBirth
	left join CountryBirth (nolock) bcb on bcb.IdCountryBirth = t.BeneficiaryIdCountryOfBirth
	left join CustomerIdentificationType (nolock) ci on ci.IdCustomerIdentificationType = t.CustomerIdCustomerIdentificationType
	left join BeneficiaryIdentificationType (nolock) bi on bi.IdBeneficiaryIdentificationType = t.IdBeneficiaryIdentificationType
	where IdTransfer = @IdTransfer

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetInfoTransferByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH
