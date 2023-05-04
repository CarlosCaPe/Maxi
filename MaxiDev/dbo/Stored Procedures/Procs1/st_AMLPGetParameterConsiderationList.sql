CREATE PROCEDURE st_AMLPGetParameterConsiderationList
(
	@IdParameter INT
)
AS
BEGIN
	SELECT
		cl.IdParameterConsiderationList,
		cl.IdParameter,
		cl.IdReference,
		cl.RiskValue
	FROM AMLP_ParameterConsiderationList cl WITH(NOLOCK)
	WHERE cl.IdParameter = @IdParameter
END


