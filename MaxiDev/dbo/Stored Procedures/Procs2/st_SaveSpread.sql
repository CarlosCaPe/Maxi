CREATE PROCEDURE [dbo].[st_SaveSpread] 
(
	@IdSpread INT OUTPUT
	,@SpreadName VARCHAR(MAX)
	,@IdCountryCurrency INT
	,@EnterByIdUser INT
	,@SpreadDetail XML
	,@IsSpanishLanguage INT
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY

	DECLARE @DocHandle INT
			,@Values XML

	CREATE TABLE #SpreadDetail(
	FromAmount MONEY
	,ToAmount MONEY
	,SpreadValue MONEY
	)
	
	SET @HasError=0

	IF @IdSpread=0
	BEGIN
		INSERT Spread (SpreadName, IdCountryCurrency, DateOfLastChange, EnterByIdUser)
		VALUES (@SpreadName, @IdCountryCurrency,GETDATE(),@EnterByIdUser)

		SELECT @IdSpread=SCOPE_IDENTITY ()

		SET @Values= (SELECT * FROM Spread (NOLOCK) WHERE IdSpread=@IdSpread FOR XML AUTO,ELEMENTS)
		INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
		VALUES ('Spread','INSERT',@Values,GETDATE(),@EnterByIdUser)

	END
	ELSE
	BEGIN
		UPDATE Spread
		SET SpreadName =@SpreadName 
		,DateOfLastChange =GETDATE()
		WHERE IdSpread =@IdSpread
		
		SET @Values= (SELECT * FROM Spread (NOLOCK) WHERE IdSpread=@IdSpread FOR XML AUTO,ELEMENTS)
		INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
		VALUES ('Spread','UPDATE',@Values,GETDATE(),@EnterByIdUser)
		 
	END


      -- buscar agencias afectadas por el cambio de schema
    update pretransfer set isvalid=1,
	DateOfLastChange=GETDATE()
	where idagentschema in(
        select idagentschema from agentschemadetail where IdSpread=@IdSpread)

	DELETE SpreadDetail WHERE IdSpread=@IdSpread

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@SpreadDetail
	
	INSERT #SpreadDetail
	SELECT FromAmount, ToAmount, SpreadValue FROM OPENXML (@DocHandle, '/Spread/Detail',2) 
	WITH (
	FromAmount MONEY
	,ToAmount MONEY
	,SpreadValue MONEY
	)

	EXEC sp_xml_removedocument @DocHandle

	INSERT SpreadDetail (IdSpread, FromAmount, ToAmount, SpreadValue, DateOfLastChange, EnterByIdUser)
	SELECT @IdSpread, FromAmount, ToAmount, SpreadValue, GETDATE(), @EnterByIdUser
	FROM #SpreadDetail
	ORDER BY FromAmount

	SET @Values= (SELECT * FROM SpreadDetail (NOLOCK) WHERE IdSpread=@IdSpread FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('SpreadDetail','INSERT',@Values,GETDATE(),@EnterByIdUser)

   

	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadSaveOk')

END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SpreadSaveError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE())  

END CATCH
