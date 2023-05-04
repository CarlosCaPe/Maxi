CREATE PROCEDURE [Corp].[st_DeleteFee]
(
	@IdFee INT
	,@EnterByIdUser INT
	,@IsSpanishLanguage INT
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY

	SET @HasError =0
	SET @MessageOut=''

	IF NOT EXISTS (SELECT TOP 1 1 FROM Fee WHERE IdFee =@IdFee)
	BEGIN
		SET @HasError =1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'FeeNoExists')
		RETURN
	END

	IF EXISTS (SELECT TOP 1 1 FROM AgentSchema WHERE IdFee =@IdFee)
	OR EXISTS (SELECT TOP 1 1 FROM AgentSchemaDetail WHERE IdFee =@IdFee)
	BEGIN
		SET @HasError =1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'FeeCanNot')
		RETURN
	END

	DELETE FeeDetail WHERE IdFee =@IdFee
	DELETE Fee WHERE IdFee =@IdFee

	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'FeeDeleteOk')

END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'FeeDeleteError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE())  

END CATCH
