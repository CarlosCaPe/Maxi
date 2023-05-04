CREATE PROCEDURE st_GetEvaluationOFACAutoRelease
(
    @IdReference                   INT,
    @IdEvaluationEntityType        INT
)
AS
BEGIN
    SELECT * FROM EvaluationOFACAutoRelease e WITH(NOLOCK)
    WHERE e.IdReference = @IdReference AND e.IdEvaluationEntityType = @IdEvaluationEntityType
END