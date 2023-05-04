
CREATE   PROCEDURE [dbo].[st_SaveCustomerHistoryRequest]
	@InitialDate DATE,
    @FinalDate DATE,
	
	@SelectedMoneyTransfer BIT,
	@SelectedBillPayment BIT,
	@SelectedTopUp BIT,

	@IdCustomer INT,
	@IdCustomerPhoneCode INT,
	@CustomerPhoneNumber NVARCHAR(1000),
	@CustomerName NVARCHAR(1000),
	@CustomerLastName NVARCHAR(1000),
	@CustomerSecondLastName NVARCHAR(1000),
	@CustomerAddress NVARCHAR(1000),
	@CustomerZipCode NVARCHAR(1000),
	
	@Beneficiary NVARCHAR(1000),
	
	@IdIdentificationCountry INT,
	@IdIdentificationType INT,
	@DeliveryMethodText NVARCHAR(1000),
	
	@SelectedCustomerEmail BIT,
	@SelectedAgencyEmail BIT,
	@SelectedAgencyFax BIT,
	@IdentificationNumber NVARCHAR(1000),
	
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT
AS
/********************************************************************
<Author>Roman Arce</Author>
<app>MaxiAgente</app>
<Description></Description>
<ChangeLog>
	<log Date="11/04/2013" Author="raarce">Creacion del Store</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	
	INSERT INTO CustomerHistoryRequest 
	(
	InitialDate,
    FinalDate,
	
	SelectedMoneyTransfer,
	SelectedBillPayment,
	SelectedTopUp,

	IdCustomer,
	IdCustomerPhoneCode,
	CustomerPhoneNumber,
	CustomerName,
	CustomerLastName,
	CustomerSecondLastName,
	CustomerAddress,
	CustomerZipCode,
	
	Beneficiary,
	
	IdIdentificationCountry,
	IdIdentificationType,
	DeliveryMethodText,
	
	SelectedCustomerEmail,
	SelectedAgencyEmail,
	SelectedAgencyFax,
	IdentificationNumber
	)
	VALUES 
	(
	@InitialDate,
    @FinalDate,
	
	@SelectedMoneyTransfer,
	@SelectedBillPayment,
	@SelectedTopUp,

	@IdCustomer,
	@IdCustomerPhoneCode,
	@CustomerPhoneNumber,
	@CustomerName,
	@CustomerLastName,
	@CustomerSecondLastName,
	@CustomerAddress,
	@CustomerZipCode,
	
	@Beneficiary,
	
	@IdIdentificationCountry,
	@IdIdentificationType,
	@DeliveryMethodText,
	
	@SelectedCustomerEmail,
	@SelectedAgencyEmail,
	@SelectedAgencyFax,
	@IdentificationNumber
	)
	
	SET @HasError = 0
	SET @Message = ''

END TRY
BEGIN CATCH
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_SaveCustomerHistoryRequest', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH
