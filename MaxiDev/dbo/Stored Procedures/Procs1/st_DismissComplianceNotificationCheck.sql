

CREATE PROCEDURE [dbo].[st_DismissComplianceNotificationCheck] 
( 
	@IdMessage INT, 
	@IsSpanishLanguage BIT,
	@HasError BIT OUTPUT,
	@MessageOut NVARCHAR(MAX) OUTPUT,
	@idCheck INT = NULL
) 
AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="23/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON;
BEGIN 
	TRY
		DECLARE @CheckUpdate INT = 0

		UPDATE [dbo].[CheckNoteNotification] SET [IdGenericStatus] = 2 WHERE [IdMessage] = @IdMessage AND [IdGenericStatus] = 1;

		SET @CheckUpdate = @@ROWCOUNT
		IF @CheckUpdate = 0
		BEGIN
			-- ::: TODO ::: REVISAR PARA QUE ES LA TABLA DE TRANSFERCLOSENOTIFICATION.... 
			--UPDATE ChecklosedNoteNotification SET IdGenericStatus = 2 WHERE IdMessage = @IdMessage and IdGenericStatus = 1

			IF @@ROWCOUNT = 0
			BEGIN 
				SET @HasError = 1
				SELECT @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,65) --Notificación descartada previamente
				RETURN 
			END
		END

		IF @CheckUpdate > 0 AND @idCheck IS NOT NULL AND 
			NOT EXISTS(
					SELECT 1
					FROM [dbo].[CheckDetails] AS A WITH (NOLOCK)
						JOIN [dbo].[CheckNote] AS B WITH (NOLOCK) ON A.IdCheckDetail = B.IdCheckDetail
						JOIN [dbo].[CheckNoteNotification] AS TNN WITH (NOLOCK) ON (B.IdCheckNote = TNN.idCheckNote)
					WHERE
						A.[IdCheck] = @idCheck
						AND IdGenericStatus = 1 )

		UPDATE [dbo].[Checks] SET [AgentNotificationSent] = 0 WHERE IdCheck = @idCheck;
	
		UPDATE [msg].[MessageSubcribers] SET [IdMessageStatus] = 4, [DateOfLastChange] = GETDATE() WHERE [IdMessage] = @IdMessage;

		UPDATE [msg].[Messages] SET [DateOfLastChange] = GETDATE() WHERE [IdMessage] = @IdMessage;

		SET @HasError = 0
		SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 

	END TRY
	BEGIN CATCH
		 SET @HasError=1 
		 SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,65) 
		 DECLARE @ErrorMessage nvarchar(max) 
		 SELECT @ErrorMessage=ERROR_MESSAGE() 
		 INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure],[ErrorDate],[ErrorMessage])
			VALUES('st_DismissComplianceNotificationCheck',GETDATE(),@ErrorMessage)
	END CATCH


	--EXEC SP_HELPTEXT st_DismissComplianceNotification
