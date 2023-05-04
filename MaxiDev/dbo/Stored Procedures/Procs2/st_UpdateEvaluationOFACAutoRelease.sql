CREATE PROCEDURE st_UpdateEvaluationOFACAutoRelease
(
    @IdReference                     INT,
    @IdEvaluationEntityType          INT,

    @EnableAutoRelease               BIT
)
AS
BEGIN

    IF EXISTS (SELECT 1 FROM EvaluationOFACAutoRelease e WHERE e.IdReference = @IdReference AND e.IdEvaluationEntityType = @IdEvaluationEntityType)
        UPDATE EvaluationOFACAutoRelease SET
            DateOfLastChange = GETDATE(),
            EnableAutoRelease = @EnableAutoRelease
        WHERE IdReference = @IdReference AND IdEvaluationEntityType = @IdEvaluationEntityType
    ELSE
        INSERT INTO EvaluationOFACAutoRelease(IdReference, IdEvaluationEntityType, EnableAutoRelease, CreationDate, DateOfLastChange)
        VALUES (@IdReference, @IdEvaluationEntityType, @EnableAutoRelease, GETDATE(), GETDATE())
END