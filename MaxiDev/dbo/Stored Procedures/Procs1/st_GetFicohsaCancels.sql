CREATE PROCEDURE [dbo].[st_GetFicohsaCancels]
AS
BEGIN
	DECLARE @IdGateWay		INT
	
	SELECT 
		@IdGateWay = g.IdGateway 
	FROM Gateway g WHERE g.Code = 'FICOHSA'

	SELECT
		t.ClaimCode		IdRemittance,
		t.IdBeneficiary	IdRemitter,
		'CANCELLED'		NewStatus
	FROM Transfer t 
	WHERE 
		t.IdGateway = @IdGateWay
		AND t.IdStatus = 25
END
