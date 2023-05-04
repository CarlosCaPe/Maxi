CREATE PROCEDURE [dbo].[st_saveTransferCustomerInfoByPayer]
(
 @idcustomer int , 
 @idpayer int , 
 @idBeneficiary int,
 @accountnumber varchar(max)
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Insert or update the deposit account number by custormer and payer</Description>

<ChangeLog>
<log Date="2017/04/28" Author="mdelgado">Creation procedure</log>
<log Date="2018-12-17" Author="jmolina">Add with(nolock) and enable NOCOUNT</log>
</ChangeLog>
********************************************************************/
Set nocount on;
BEGIN TRY
	IF EXISTS( SELECT 1 FROM TransfersCustomerInfoByPayer with(nolock) where idCustomer = @idcustomer AND idPayer = @idpayer AND IdBeneficiary = @idBeneficiary)
	BEGIN
		UPDATE TransfersCustomerInfoByPayer
			SET DepositAccountNumber = @accountnumber
		WHERE idCustomer = @idcustomer  AND idPayer = @idpayer and IdBeneficiary = @idBeneficiary ;
	END
	ELSE 
	BEGIN
		INSERT TransfersCustomerInfoByPayer values (@idcustomer, @idpayer, @accountnumber, @idBeneficiary);
	END
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_saveTransferCustomerInfoByPayer' ,GETDATE(), @ErrorMessage);
END CATCH
