CREATE PROCEDURE [Corp].[st_DismissComplianceNotificationByIdCheck]
(
@IdCheck INT, 
@IsSpanishLanguage BIT, 
@HasError BIT OUT, 
@MessageOut VARCHAR(MAX) OUT 
)AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="23/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update and begin try </log>
</ChangeLog>
********************************************************************/

SET NOCOUNT ON;
BEGIN TRY

	DECLARE @IdMessages TABLE (IdMessage INT)
	DECLARE @totalMessages INT
	DECLARE @totalErrors INT

	DECLARE @CurrentIdMessage INT
	DECLARE @CurrentHasError BIT
	DECLARE @CurrertErrorMessage VARCHAR(MAX)

	SET @totalErrors = 0
	SET @totalMessages = 0

	IF EXISTS(SELECT 1 FROM [dbo].Checks WITH(NOLOCK) WHERE IdCheck = @IdCheck)
	BEGIN

		INSERT INTO @IdMessages
		SELECT cnn.IdMessage 
		FROM [dbo].CheckNoteNotification AS cnn WITH(NOLOCK) 
		INNER JOIN [dbo].CheckNote  AS cn WITH(NOLOCK) ON cn.idCheckNote = cnn.idChecknote
		INNER JOIN [dbo].CheckDetails AS cd WITH(NOLOCK) ON cn.idCheckDetail = cd.idCheckDetail AND cd.idCheck = @idCheck
		WHERE cnn.IdGenericStatus = 1;

	END 
	--///REVISAR SI VA O NO EXISTE.... POR LE MOMENTO NO EXISTEN checkClosedNotification
	--ELSE 
	--BEGIN

	--	INSERT INTO @IdMessages
	--	SELECT TCNN.IdMessage 
	--	FROM TransferClosedNoteNotification TCNN
	--	INNER JOIN TransferClosedNote TCN on TCNN.IdTransferClosedNote = TCN.IdTransferClosedNote
	--	INNER JOIN TransferClosedDetail TCD on TCN.IdTransferClosedDetail = TCD.IdTransferClosedDetail and TCD.IdTransferClosed = @IdTransfer
	--	WHERE TCNN.IdGenericStatus = 1

	--END

	WHILE EXISTS(SELECT 1 FROM @IdMessages)
	BEGIN

		SELECT TOP 1 @CurrentIdMessage= IdMessage FROM @IdMessages
		EXEC [Corp].st_DismissComplianceNotificationCheck @CurrentIdMessage, @IsSpanishLanguage, @CurrentHasError out, @CurrertErrorMessage out
		SET @totalErrors = @totalErrors+@CurrentHasError
		SET @totalMessages = @totalMessages+1
		DELETE @IdMessages WHERE IdMessage = @CurrentIdMessage

	END

	SET @HasError = CASE WHEN @totalErrors > 0 THEN 1 ELSE 0 END

	SELECT @MessageOut=cast(@totalErrors AS VARCHAR(10))+' / '+cast(@totalMessages AS VARCHAR(10))+' '+ dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 
END TRY
BEGIN CATCH
	DECLARE @MessageError varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('Corp.st_DismissComplianceNotificationByIdCheck', GETDATE(), @MessageError)
END CATCH
