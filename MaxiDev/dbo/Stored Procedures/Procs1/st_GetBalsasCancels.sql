CREATE PROCEDURE [dbo].[st_GetBalsasCancels]
AS
BEGIN
	DECLARE @IdGateWay		INT
	
	SELECT 
		@IdGateWay = g.IdGateway 
	FROM Gateway g WHERE g.Code = 'BALSAS'

	SELECT
		t.ClaimCode						ClaimCode,
		t.AmountInMN					Amount,
		'01'							CurrencyCode,
		t.DateOfTransfer				TransferDate,
		b.code							BranchCode,
		b.BranchName					BranchName,
		b.Address						BranchDirection,
		t.BeneficiaryName				BeneficiaryName,
		CONCAT(
			t.BeneficiaryFirstLastName, 
			' ', 
			t.BeneficiarySecondLastName
		)								BeneficiaryLastName,
		t.BeneficiaryAddress			BeneficiaryDirection,
		t.BeneficiaryPhoneNumber		BeneficiaryPhone,
		t.CustomerName					CustomerName,
		CONCAT(
			t.CustomerFirstLastName,
			' ',
			t.CustomerSecondLastName
		)								CustomerLastName,
		t.CustomerPhoneNumber			CustomerPhone,
		t.CustomerAddress				CustomerDirection,
		ct.CityName						TransferCity,
		''								AccountNumber,
		''								Bank,
		''								Branch,
		''								AccountOwner
	FROM Transfer t WITH(NOLOCK)
		JOIN Branch b WITH(NOLOCK) ON b.IdBranch = t.IdBranch
		JOIN City ct WITH(NOLOCK) ON b.IdCity = ct.IdCity
	WHERE t.IdGateway = @IdGateWay AND t.IdStatus = 25
END
