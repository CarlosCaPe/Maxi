CREATE PROCEDURE st_UpdateAgentSchemaDetails
(
	@IdAgent			INT,
	@IdAgentSchema		INT,
	@SchemaDetail		XML,
	@IdUser				INT,

	@Success			BIT OUT,
	@ErrorMessage		VARCHAR(200) OUT
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY

		;WITH UpdateSchemasDetail AS
		(
			SELECT
				t.c.value('IdAgentSchemaDetail[1]', 'int') IdAgentSchemaDetail,
				t.c.value('SpreadValue[1]', 'money') SpreadValue,
				t.c.value('(IdFee/text())[1]', 'int') IdFee,
				t.c.value('(IdCommission/text())[1]', 'int') IdCommission,
				t.c.value('TempSpread[1]', 'money') TempSpread,
				t.c.value('EndDateTempSpread[1]', 'datetime') EndDateTempSpread,
				t.c.value('(IdSpread/text())[1]', 'int') IdSpread
			FROM @SchemaDetail.nodes('/root/SchemaDetailForUpdate') t(c)
		)
		--SELECT * FROM UpdateSchemasDetail
		UPDATE asd SET
			SpreadValue = u.SpreadValue,
			IdFee = u.IdFee,
			IdCommission = u.IdCommission,
			TempSpread = u.TempSpread,
			EndDateTempSpread = u.EndDateTempSpread,
			IdSpread = u.IdSpread,
			DateOfLastChange = GETDATE()
		OUTPUT INSERTED.*
		FROM AgentSchemaDetail asd
			JOIN AgentSchema s ON s.IdAgentSchema = asd.IdAgentSchema
			JOIN UpdateSchemasDetail u ON u.IdAgentSchemaDetail = asd.IdAgentSchemaDetail
		WHERE 
			s.IdAgent = @IdAgent
			AND s.IdAgentSchema = @IdAgentSchema

		SELECT	@Success = 1,
				@ErrorMessage = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating AgentSchemaDetail'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
