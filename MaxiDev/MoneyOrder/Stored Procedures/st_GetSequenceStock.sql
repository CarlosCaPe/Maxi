CREATE PROCEDURE MoneyOrder.st_GetSequenceStock
(
	@IdAgent INT
)
AS
BEGIN 
	DECLARE @IdSequenceStatusAvailable INT = 1

	SELECT
		MIN(s.[Sequence])	NextSequence,
		COUNT(1)			AvailableToPrint,
		MAX(s.[Sequence])	FinalSequence
	FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
		JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
	WHERE 
		sm.IdAgent = @IdAgent
		AND s.IdSequenceStatus = @IdSequenceStatusAvailable

END