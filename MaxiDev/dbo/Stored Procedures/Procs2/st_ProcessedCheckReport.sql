CREATE PROCEDURE [dbo].[st_ProcessedCheckReport]
(
	@FechaInicio DATETIME,
	@FechaFin DATETIME,
	@IdAgent INT= null
)
AS
Set nocount on         
Select @FechaInicio=dbo.RemoveTimeFromDatetime(@FechaInicio),@FechaFin=dbo.RemoveTimeFromDatetime(@FechaFin+1)      
BEGIN

	SELECT 
		ab.DateOfMovement,
		CASE WHEN ab.Reference IS NULL THEN convert(varchar,ab.IdAgentBalance) ELSE ab.Reference END reference,
		c.Name + ' ' + c.FirstLastName + ' ' + c.SecondLastName AS [Name],
		--CASE WHEN TypeOfMovement IN ('CHNFS','CHRTN') THEN 0 ELSE c.fee END 

		CASE WHEN c.IdStatus IN (31,22) AND TypeOfMovement='CHRTN' THEN c.fee*(-1)
			ELSE 
					CASE WHEN c.IdStatus IN (31,22) AND TypeOfMovement='CH' AND 
						 ( SELECT COUNT (val.TypeOfMovement)  
						FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
						AND val.Reference=ab.Reference
						HAVING COUNT(val.TypeOfMovement) > 1) is not null
					 THEN c.fee
					ELSE
						CASE WHEN c.IdStatus IN (31,22) AND TypeOfMovement='CH' AND 
							 ( SELECT COUNT (val.TypeOfMovement)  
								FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
								AND val.Reference=ab.Reference
								HAVING COUNT(val.TypeOfMovement) > 1) is null
						 THEN c.fee*(-1)
						 ELSE 0 END  
					END
			END	
		
		AS TransferFee,
		ab.FxFee As ValFee,
		--CASE WHEN TypeOfMovement = 'CHNFS' THEN ab.Amount ELSE 0 END  
		CASE WHEN c.IdStatus IN (31) AND TypeOfMovement='CHRTN' THEN c.ReturnFee
		  ELSE 
			CASE WHEN c.IdStatus IN (31) AND TypeOfMovement='CH'  AND 
			 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
				FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
				AND val.Reference=ab.Reference
				HAVING COUNT(val.TypeOfMovement) > 1) is null
			THEN c.ReturnFee
			ELSE 0 END 
		END
		
		AS [NSFFee],
		CASE WHEN TypeOfMovement = 'CHNFS' THEN  0
		ELSE
			CASE WHEN DebitOrCredit = 'Credit' THEN ab.Amount*(-1) ELSE ab.Amount END 
		END 		
		AS Credit,
		CASE WHEN c.IdStatus=30 AND TypeOfMovement='CH' THEN c.Amount
		ELSE 
			CASE WHEN c.IdStatus IN (31,22) AND TypeOfMovement='CH'  AND 
			 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
				FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
				AND val.Reference=ab.Reference
				HAVING COUNT(val.TypeOfMovement) > 1) is not null
			THEN c.Amount
			ELSE 0 END 
		END	
		AS [Amount],
		ab.Balance AS Balance,
		ab.TypeOfMovement,
		--CASE WHEN c.IdStatus=30  THEN ' ' ELSE 
		--CASE WHEN c.IdStatus IN (31,22) AND TypeOfMovement='CH'  AND 
		--	 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
		--		FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
		--		AND val.Reference=ab.Reference
		--		HAVING COUNT(val.TypeOfMovement) > 1) is not null
		--	THEN ' '
		--ELSE s.StatusName END
		s.StatusName
--	END
		 AS Status,
		(SELECT TOP 1 Balance FROM AgentBalance WHERE TypeOfMovement in ('CH','CHRTN') AND IdAgent = @IdAgent
		AND	CONVERT(DATE, [DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
		AND CONVERT(DATE, [DateOfMovement]) < CONVERT(DATE, @FechaFin) ORDER BY DateOfMovement DESC) AS LastBalance
	FROM dbo.AgentBalance ab WITH(NOLOCK)
		INNER JOIN dbo.checks c WITH(NOLOCK) ON c.IdCheck = ab.reference
		INNER JOIN  dbo.Status s WITH(NOLOCK) ON s.IdStatus = c.IdStatus
	WHERE ab.TypeOfMovement in ('CH','CHRTN') 
		AND ab.IdAgent = @IdAgent
		AND	CONVERT(DATE, [ab].[DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
		AND CONVERT(DATE, [ab].[DateOfMovement]) < CONVERT(DATE, @FechaFin)
	ORDER BY ab.DateOfMovement ASC;

END