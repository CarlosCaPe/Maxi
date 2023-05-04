CREATE   PROCEDURE [dbo].[st_UpdateAgent]
(
	@IdAgent							INT,
	@AccountNumberCollection			INT,
	@RoutingNumberCollection			INT,
	@AccountNumberCommission			INT,
	@RoutingNumberCommission			INT,

	@IdUser								INT,

	@Document_AgentDocuments			XML,

	@Success							BIT OUT,
	@ErrorMessage						VARCHAR(200) OUT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Agents</app>
<Description>This stored is used in Ares 2.0 Apis Legacy to update a Agent</Description>

<ChangeLog>
<log Date="##/##/####" Author=""> </log>
</ChangeLog>
*********************************************************************/
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
		SELECT	@Success = 1,
				@ErrorMessage = NULL

		--BEGIN BM-586
		DECLARE  @DocHandle INT

		CREATE TABLE #AgentDocuments
		(
			IdDocumentType	INT,
			FileName		VARCHAR(300),
			Extension		VARCHAR(5),
			Url				VARCHAR(300)
		);
	
		EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Document_AgentDocuments

		INSERT INTO #AgentDocuments
		SELECT IdDocumentType, FileName, Extension, Url
		FROM OPENXML (@DocHandle, '/AgentDocuments/AgentDocument',2)
		WITH (
				IdDocumentType		INT,
				FileName			VARCHAR(300),
				Extension			VARCHAR(5),
				Url					VARCHAR(300)
			);

		EXEC sp_xml_removedocument @DocHandle
		--END BM-586

		UPDATE A SET
			A.AccountNumberCommission = @AccountNumberCollection,
			A.RoutingNumberCommission = @RoutingNumberCommission,
			A.AccountNumber = @AccountNumberCollection,
			A.RoutingNumber = @RoutingNumberCollection
		FROM Agent A WITH (NOLOCK)
		WHERE IdAgent = @IdAgent

		--BEGIN BM-586
		IF EXISTS(SELECT 1 FROM #AgentDocuments)
		BEGIN
			INSERT INTO [dbo].[AgentDocument]  ([IdAgent], [IdDocumentType], [FileName], [Extension], [Url], [IsUpload], [IdGenericStatus], [CreationDate], [DateOfLastChange], [EnterByIdUser])
			SELECT @IdAgent, AD.IdDocumentType, AD.FileName, AD.Extension, AD.Url, 0, 1, GETDATE(), GETDATE(), @IdUser FROM #AgentDocuments AD
		END
		--END BM-586

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while updating Agent'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
