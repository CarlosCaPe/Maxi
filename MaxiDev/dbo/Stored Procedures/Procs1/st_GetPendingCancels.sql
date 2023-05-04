CREATE PROCEDURE [dbo].[st_GetPendingCancels]
(
	@IdGateway			INT,
	@Limit				INT = NULL
)
AS
BEGIN
	SELECT
		t.ClaimCode		IdReference,
		rc.Reason
	FROM Transfer t WITH(NOLOCK)
		JOIN ReasonForCancel rc WITH(NOLOCK) ON t.IdReasonForCancel = rc.IdReasonForCancel
	WHERE 
		t.IdGateway = @IdGateWay
		AND t.IdStatus = 25
END