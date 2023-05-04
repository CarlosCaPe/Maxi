
CREATE PROCEDURE [dbo].[st_DismissComplianceNotification] 
( 
	 @IdMessage INT, 
	 @IsSpanishLanguage BIT,
	 @HasError BIT OUTPUT,
	 @MessageOut NVARCHAR(MAX) OUTPUT,
	 @TransferId INT = NULL
) 
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

Begin Try
	DECLARE @TransferUpdate INT = 0
	UPDATE [dbo].[TransferNoteNotification] SET [IdGenericStatus] = 2 WHERE [IdMessage] = @IdMessage AND [IdGenericStatus] = 1
	SET @TransferUpdate = @@ROWCOUNT
	IF @TransferUpdate = 0
	BEGIN
		UPDATE [dbo].TransferClosedNoteNotification set IdGenericStatus = 2 where IdMessage = @IdMessage and IdGenericStatus = 1
		IF @@ROWCOUNT = 0
		BEGIN 
			SET @HasError = 1
			SELECT @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,65) --Notificación descartada previamente
			RETURN 
		END
	END

	IF @TransferUpdate > 0
		AND @TransferId IS NOT NULL AND NOT EXISTS(
					SELECT 1 --TOP 1 1
					FROM [dbo].[TransferDetail] AS A WITH (NOLOCK)
						JOIN [dbo].[TransferNote] AS B WITH (NOLOCK) ON A.IdTransferDetail=B.IdTransferDetail
						JOIN [dbo].[TransferNoteNotification] AS TNN WITH (NOLOCK) ON (B.IdTransferNote= TNN.IdTransferNote)
					WHERE
						A.[IdTransfer] = @TransferId
						AND IdGenericStatus = 1 )
		UPDATE [dbo].[Transfer] SET [AgentNotificationSent] = 0 where IdTransfer=@TransferId
	
	UPDATE [msg].[MessageSubcribers] SET [IdMessageStatus] = 4, [DateOfLastChange] = GETDATE() WHERE [IdMessage] = @IdMessage
	UPDATE [msg].[Messages] SET [DateOfLastChange] = GETDATE() WHERE [IdMessage] = @IdMessage

	SET @HasError = 0
	SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 
END TRY
BEGIN CATCH
	 SET @HasError=1 
	 SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,65) 
	 DECLARE @ErrorMessage nvarchar(max) 
	 SELECT @ErrorMessage=ERROR_MESSAGE() 
	 INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure],[ErrorDate],[ErrorMessage])
		VALUES('st_DismissComplianceNotification',GETDATE(),@ErrorMessage)
END CATCH


