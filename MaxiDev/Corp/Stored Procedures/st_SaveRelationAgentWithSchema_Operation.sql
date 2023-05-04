CREATE PROCEDURE [Corp].[st_SaveRelationAgentWithSchema_Operation]
    @IdAgent INT,
    @IdProvider INT = NULL,
    @Schemas XML,
    @EnterByIdUser INT,
    @IdLenguage INT,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY

	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END
  
	DECLARE @TempSchema TABLE
	(
		[IdSchema] INT
	)
   
	DECLARE @DocHandle INT
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Schemas
	INSERT INTO @TempSchema ([IdSchema])
	SELECT [IdSchema]
	FROM OPENXML (@DocHandle, '/Schemas/Detail',2)
	WITH ([IdSchema] INT)

	DELETE [TransFerTo].[AgentSchema]
	WHERE [IdAgent] = @IdAgent
		AND [IdSchema] NOT IN (SELECT [IdSchema] FROM @TempSchema)
		AND [IdSchema] IN (
							SELECT [IdSchema]
							FROM [TransFerTo].[Schema] WITH (NOLOCK)
							WHERE [IdOtherProduct]=@IdOtherProduct)
               
	INSERT INTO [TransFerTo].[AgentSchema] ([IdSchema], [IdAgent], [DateOfLastchange], [EnterByIdUser])
	SELECT 
		[IdSchema]
		, @IdAgent
		, GETDATE()
		, @EnterByIdUser
	FROM @TempSchema
	WHERE [IdSchema] NOT IN (
								SELECT [IdSchema]
								FROM [TransFerTo].[AgentSchema] WITH (NOLOCK)
								WHERE [IdAgent]=@IdAgent)
		AND ISNULL([IdSchema],0) != 0
    
	SET @HasError=0
	SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaSave')

END TRY
BEGIN CATCH
    SET @HasError=1            
    SELECT @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()            
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[Corp].[st_SaveRelationAgentWithSchema_Operation]', GETDATE(),@ErrorMessage)
END CATCH

