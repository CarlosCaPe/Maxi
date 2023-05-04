CREATE PROCEDURE MoneyGram.st_GetBeneficiaryRelation
(
	@IdBeneficiary		BIGINT
)
AS
BEGIN
	SELECT
		b.*
	FROM MoneyGram.Beneficiary b
	WHERE IdBeneficiary = @IdBeneficiary
END