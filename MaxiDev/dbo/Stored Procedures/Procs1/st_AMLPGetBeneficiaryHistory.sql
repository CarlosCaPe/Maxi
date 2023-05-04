CREATE PROCEDURE [dbo].[st_AMLPGetBeneficiaryHistory]
(
	@IdBeneficiary	INT
)
AS
BEGIN
	SELECT
		b.*
	FROM Beneficiary b  WITH(NOLOCK)
	WHERE b.IdBeneficiary = @IdBeneficiary
END
