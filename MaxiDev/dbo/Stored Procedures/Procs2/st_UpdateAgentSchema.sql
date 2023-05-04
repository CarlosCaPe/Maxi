CREATE PROCEDURE st_UpdateAgentSchema
(
	@IdAgent					INT,
	@idAgentSchema				INT,
	@SchemaName					VARCHAR(500),
	@IdFee						INT,
	@IdCommission				INT,
	--@IdCountryCurrency			INT,
	@SchemaDefault				BIT,
	@Description				VARCHAR(500),
	@Spread						MONEY,
	@EndDateSpread				DATETIME,
	@IdGenericStatus			INT,
	@IdUser						INT,

	@Success			BIT OUT,
	@ErrorMessage		VARCHAR(200) OUT
)
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY

		UPDATE s SET
			s.SchemaName = UPPER(@SchemaName),
			s.IdFee = @IdFee,
			s.IdCommission = @IdCommission,
			--s.IdCountryCurrency =@IdCountryCurrency,
			s.SchemaDefault = @SchemaDefault,
			s.Description = UPPER(@Description),
			s.Spread = @Spread,
			s.EndDateSpread = @EndDateSpread,
			s.IdGenericStatus = @IdGenericStatus,
			s.DateOfLastChange = GETDATE()
		FROM AgentSchema s
		WHERE 
			s.IdAgent = @IdAgent
			AND s.IdAgentSchema = @idAgentSchema

		SELECT	@Success = 1,
				@ErrorMessage = NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating AgentSchema'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
--GO
--DECLARE @XML XML = '
--<root>
--  <SchemaDetailForUpdate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
--    <IdAgentSchemaDetail>208581417</IdAgentSchemaDetail>
--    <SpreadValue>-0.0101</SpreadValue>
--    <IdFee>26</IdFee>
--    <IdCommission>121</IdCommission>
--    <TempSpread>0.0</TempSpread>
--    <EndDateTempSpread>2021-10-08T20:32:16.535Z</EndDateTempSpread>
--    <IdSpread xsi:nil="true" />
--  </SchemaDetailForUpdate>
--</root>'

--DECLARE @Success BIT,
--		@ErrorMessage VARCHAR(200)


--EXEC st_UpdateAgentSchema 1242, 65773, @XML, 1, @Success OUT, @ErrorMessage OUT

--SELECT @Success, @ErrorMessage





--SELECT * FROM ErrorLogForStoreProcedure e WHERE e.StoreProcedure = 'st_UpdateAgentSchema'
