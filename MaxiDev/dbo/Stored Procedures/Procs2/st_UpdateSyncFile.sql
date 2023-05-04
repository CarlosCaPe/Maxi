CREATE   PROCEDURE [dbo].[st_UpdateSyncFile]
(
	@IdReference			INT,
	@IdDocumentType         INT,
	@FileName               VARCHAR(300),
	@Extension              VARCHAR(5),
	@Url                    VARCHAR(300),

	@Success				BIT OUT,
	@ErrorMessage			VARCHAR(200) OUT,
	@IdAgentDocument		INT OUT
)
AS
/********************************************************************
<Author>Miguel Prado</Author>
<date>30/01/2023</date>
<app>CorporativeServices.Agents</app>
<Description>Sp para actualizar registro de Documentos Sincronizados de Aws S3 </Description>

<ChangeLog>
<log Date="XX/XX/XXXX" Author=""></log>
</ChangeLog>
*********************************************************************/
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		SELECT	@Success = 1,
				@ErrorMessage = NULL

		SELECT @IdAgentDocument = IdAgentDocument
		FROM AgentDocument AD WITH (NOLOCK)
		WHERE IdAgent = @IdReference AND IdDocumentType = @IdDocumentType
		AND FileName =@FileName AND Extension = @Extension
		AND Url = @Url AND IsUpload = 0
		AND IdGenericStatus = 1

		IF ISNULL(@IdAgentDocument,0) = 0
		BEGIN
			SET @Success = 0
			SET @ErrorMessage = 'An unexpected error occurred while search the AgentDocument'

			ROLLBACK TRANSACTION
			RETURN
		END
		ELSE
		BEGIN
			UPDATE AD
			SET AD.IsUpload = 1,
			AD.DateOfLastChange = GETDATE()
			FROM AgentDocument AD WITH (NOLOCK)
			WHERE AD.IdAgentDocument = @IdAgentDocument
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating AgentDocument'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH

END
