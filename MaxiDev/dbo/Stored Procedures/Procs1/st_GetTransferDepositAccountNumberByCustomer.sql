
CREATE PROCEDURE [dbo].[st_GetTransferDepositAccountNumberByCustomer]
(
	@idCustomer int
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Get Deposit Account Numbers by customers</Description>

<ChangeLog>
	<log Date="2017/04/28" Author="mdelgado">Creation procedure</log>
	<log Date="2017/08/09" Author="mdelgado">Fix add idBeneficiary</log>
	<log Date="2022/06/13" Author="jcsierra">Add IdDialingCodeBeneficiaryPhoneNumber</log>
</ChangeLog>
********************************************************************/
BEGIN
	SELECT 
		t.idCustomer, 
		t.idPayer, 
		t.DepositAccountNumber, 
		t.idBeneficiary,
		b.IdDialingCodePhoneNumber IdDialingCodeBeneficiaryPhoneNumber
	FROM TransfersCustomerInfoByPayer t WITH(NOLOCK)
		LEFT JOIN Beneficiary b WITH(NOLOCK) ON b.IdBeneficiary = t.idBeneficiary
	WHERE t.idCustomer = @idCustomer
END