CREATE PROCEDURE Corp.st_SaveAgentToCorrectBalance
	@IdAgent 	INT,
	@ApplyDate	DATE,
	@HasError	BIT OUT,
	@Message	VARCHAR(max) OUT
AS
BEGIN


	
	
	IF EXISTS(SELECT 1 FROM Soporte.AgentToCorrect WHERE IdAgent = @IdAgent)
	BEGIN
		
		SET @HasError = 1
		SET @Message = 'Cannot save duplicate Agent to correct balance.'
	
	END
	ELSE
	BEGIN
	
		DECLARE @PrevMovementDate DATE
	
		SELECT TOP 1 @PrevMovementDate = MovementDate
		FROM 
		(
		SELECT  DISTINCT convert(DATE, DateOfMovement) AS MovementDate 
		FROM AgentBalance 
		WHERE DateOfMovement < @ApplyDate 
			AND IdAgent = @IdAgent 
		) A
		ORDER BY A.MovementDate DESC
	
		INSERT INTO Soporte.AgentToCorrect ([IdAgent],[Begin])
		VALUES (@IdAgent, @ApplyDate)
		
		SET @HasError = 0
		SET @Message = 'Agent to correct balance saved successfully.'
	
	END


	
	
	
 
	

END
