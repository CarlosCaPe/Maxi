CREATE PROCEDURE st_UpdatePreviewModuleByAgent
(
	@IdAgent				INT,
	@IdAgentPreviewModule	NVARCHAR(80),
	@EnableFeature			BIT,
	@IdUser					INT,
	@IsError				BIT OUT,
	@ErrorMessage			NVARCHAR(200) OUT
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE	@ModuleKey				NVARCHAR(80),
				@PermissionsValue		NVARCHAR(MAX),
				@OriginalValue			NVARCHAR(MAX)
		DECLARE @PermissionsTable	TABLE (IdValue INT)
		
		SELECT
			@ModuleKey = ap.ModuleKey,
			@IdAgentPreviewModule = ap.IdAgentPreviewModule,
			@OriginalValue = ga.Value,
			@PermissionsValue = ga.Value
		FROM AgentPreviewModule ap WITH(NOLOCK)
			JOIN GlobalAttributes ga WITH(NOLOCK) ON ga.Name = ap.ModuleKey
		WHERE ap.IdAgentPreviewModule = @IdAgentPreviewModule

		IF @IdAgentPreviewModule IS NULL
		BEGIN
			SELECT	@IsError = 1,
					@ErrorMessage = 'The module not exists'

			COMMIT TRANSACTION
			RETURN 
		END

		INSERT INTO @PermissionsTable(IdValue)
		SELECT s.item FROM dbo.fnSplit(@PermissionsValue, ',') s

		IF @EnableFeature = 1
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM @PermissionsTable pt WHERE pt.IdValue = @IdAgent)
				INSERT INTO @PermissionsTable(IdValue)
				VALUES (@IdAgent)
		END
		ELSE
			DELETE FROM @PermissionsTable WHERE IdValue = @IdAgent

		SET @PermissionsValue = ''
		SELECT 
			@PermissionsValue = COALESCE(CONCAT(@PermissionsValue, ',', t.IdValue), ',')
		FROM @PermissionsTable t
		SET @PermissionsValue = SUBSTRING(@PermissionsValue, 2, LEN(@PermissionsValue))

		UPDATE ga SET
			ga.Value = @PermissionsValue
		FROM GlobalAttributes ga 
			JOIN AgentPreviewModule apm ON ga.Name = apm.ModuleKey
		WHERE apm.ModuleKey = @ModuleKey

		-- Log Change
		INSERT INTO AgentPreviewModuleLog(IdAgentPreviewModule, LastValue, NewValue, [Message], IdUser, CreationDate)
		VALUES
		(
			@IdAgentPreviewModule, 
			@OriginalValue, 
			@PermissionsValue, 
			CONCAT((CASE WHEN @EnableFeature = 1 THEN 'ENABLE' ELSE 'DISABLE' END), ' IdAgent: ', @IdAgent), 
			@IdUser, 
			GETDATE()
		)

		SELECT	@IsError = 0,
				@ErrorMessage = 'The registry was successfully updated'

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@IsError = 1,
				@ErrorMessage = CONCAT('Unespected Error saving (', @ModuleKey ,') module')
	END CATCH
END