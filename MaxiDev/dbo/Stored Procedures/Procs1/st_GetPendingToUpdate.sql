CREATE PROCEDURE [dbo].[st_GetPendingToUpdate]
AS
BEGIN
	SELECT
		t.IdTransfer,
		t.ClaimCode,
		t.ConfirmationCode		IssuerTicket
	FROM Transfer t WITH(NOLOCK)
	WHERE 
		t.IdGateway = 46 /*46*/
		--AND t.IdStatus IN (23, 25)
		AND t.IdStatus NOT IN (23, 22, 20, 31)
		AND ISNULL(t.ConfirmationCode, '') <> ''
END
