CREATE PROCEDURE Corp.GetAgentSuspendedSubStatus
	@IdAgent	INT
AS
BEGIN

	
	
	
	SELECT D.IdMaxiDepartment, D.MaxiDepartment, isnull(S.Suspended, 0) AS Suspended
	FROM Corp.MaxiDepartment D LEFT JOIN
		Corp.AgentSuspendedSubStatus S ON S.IdMaxiDepartment = D.IdMaxiDepartment
										AND S.IdAgent = @IdAgent

END