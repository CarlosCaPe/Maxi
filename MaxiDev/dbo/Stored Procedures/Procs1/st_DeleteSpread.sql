CREATE PROCEDURE [dbo].[st_DeleteSpread]
(
	@IdSpread INT
	,@EnterByIdUser INT
	,@IsSpanishLanguage INT
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY

	DECLARE @Values XML

	SET @HasError=0
	SET @MessageOut=''

	IF NOT EXISTS (SELECT TOP 1 1 FROM Spread WHERE IdSpread =@IdSpread)
	BEGIN
		SET @HasError=1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadNoExists')
		RETURN
	END

	IF EXISTS (SELECT TOP 1 1 FROM AgentSchemaDetail WHERE IdSpread =@IdSpread)
	BEGIN
		SET @HasError=1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadDeleteError')
		RETURN
	END

	SET @Values= (SELECT * FROM SpreadDetail (NOLOCK) WHERE IdSpread=@IdSpread FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('SpreadDetail','DELETE',@Values,GETDATE(),@EnterByIdUser)

	SET @Values= (SELECT * FROM Spread (NOLOCK) WHERE IdSpread=@IdSpread FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('Spread','DELETE',@Values,GETDATE(),@EnterByIdUser)

	DELETE SpreadDetail WHERE IdSpread =@IdSpread
	DELETE Spread WHERE IdSpread =@IdSpread

	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadDeleteOk')

END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadDeleteError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE())  

END CATCH
