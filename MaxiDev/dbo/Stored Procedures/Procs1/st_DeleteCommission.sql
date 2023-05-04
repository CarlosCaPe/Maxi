


CREATE PROCEDURE [dbo].[st_DeleteCommission]
(
	@IdCommission INT
	,@EnterByIdUser INT
	,@IsSpanishLanguage INT
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY

	SET @HasError =0
	SET @MessageOut=''

	IF NOT EXISTS (SELECT TOP 1 1 FROM Commission WHERE IdCommission =@IdCommission)
	BEGIN
		SET @HasError =1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'CommissionNoExists')
		RETURN
	END

	IF EXISTS (SELECT TOP 1 1 FROM AgentSchema WHERE IdCommission =@IdCommission)
	OR EXISTS (SELECT TOP 1 1 FROM AgentSchemaDetail WHERE IdCommission =@IdCommission)
	BEGIN
		SET @HasError =1
		SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'CommissionCanNot')
		RETURN
	END

	DELETE CommissionDetail WHERE IdCommission =@IdCommission
	DELETE Commission WHERE IdCommission =@IdCommission

	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'CommissionDeleteOk')

END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'CommissionDeleteError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE())  

END CATCH
