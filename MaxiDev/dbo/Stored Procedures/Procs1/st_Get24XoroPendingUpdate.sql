CREATE PROCEDURE st_Get24XoroPendingUpdate
AS
BEGIN

	DECLARE @IdGateway		INT = 39

	SELECT
		t.IdTransfer,
		t.ClaimCode	IdReference
	FROM Transfer t WITH(NOLOCK)
	WHERE 
		t.IdGateway = @IdGateway
		AND t.IdStatus NOT IN (30, 22)
		AND EXISTS
		(
			SELECT 1 FROM TransferDetail td WITH(NOLOCK)
			WHERE td.IdTransfer = t.IdTransfer 
			AND td.IdStatus = 23
		)
END

