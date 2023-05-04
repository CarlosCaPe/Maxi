CREATE PROCEDURE [dbo].[st_UpdateConfigTerminal]
(
	@IdAgentPosTerminal	    INT,
	@PortTerminal	        INT,
	@IPTerminal				VARCHAR(50)=NULL,
    @OSVersion				VARCHAR(100)='',
	@DeviceType				VARCHAR(100)='',

	@Success				BIT OUTPUT,
	@Message			    VARCHAR(200) OUTPUT
)
AS
 /********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
	<log Date="01/04/2023" Author="raarce"> BM-567 : Se agrego validacion en caso de que OSVersion y DeviceType sean null</log>
</ChangeLog>
********************************************************************/
BEGIN
BEGIN TRANSACTION
	BEGIN TRY 
		DECLARE @IdPosTerminal		    INT = NULL;

		IF @OSVersion IS NULL
		BEGIN
			SET @OSVersion = ''
		END
		IF @DeviceType IS NULL
		BEGIN
			SET @DeviceType = ''
		END

		UPDATE AgentPosTerminal SET
			AgentPosTerminal.Port = @PortTerminal,
			AgentPosTerminal.IP = @IPTerminal
		WHERE 
			AgentPosTerminal.IdAgentPosterminal = @IdAgentPosTerminal;
			
		SELECT @IdPosTerminal = IdPosTerminal from AgentPosTerminal 
		WHERE 
		    IdAgentPosterminal = @IdAgentPosTerminal;		
		
		UPDATE PosTerminal SET
			PosTerminal.OSVersion = @OSVersion,
			PosTerminal.DeviceType = @DeviceType
		WHERE 
			PosTerminal.IdPosTerminal = @IdPosTerminal 
			
		SET	@Success = 1
		SET	@Message = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SET	@Success = 0
		SET	@Message = 'An unexpected error occurred while updating AgentPosTerminal'

		DECLARE @ExMessage VARCHAR(1000) 
		SELECT  @ExMessage=ERROR_MESSAGE()   
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
