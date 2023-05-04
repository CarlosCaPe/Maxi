CREATE PROCEDURE st_GetPayerById
(
	@IdPayer	INT
)
AS
BEGIN
	SELECT
		p.IdPayer,
		p.PayerName,
		CASE 
			WHEN p.PayerCode = 'NULL' THEN NULL
			ELSE p.PayerCode
		END PayerCode,
		p.Folio,
		p.IdGenericStatus,
		p.DateOfLastChange,
		p.EnterByIdUser,
		p.PayerLogo
	FROM Payer p WITH(NOLOCK)
	WHERE p.IdPayer = @IdPayer
END
