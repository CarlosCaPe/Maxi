CREATE PROCEDURE [dbo].[st_SaveAgentSchema]
(
	@IdAgentSchema INT OUT
	,@SchemaName VARCHAR(MAX)
	,@IdFee INT
	,@IdCommission INT
	,@IdCountryCurrency INT
	,@SchemaDefault BIT
	,@EnterByIdUser INT
	,@IdGenericStatus INT
	,@Description VARCHAR(MAX)
	,@IdAgent INT
	,@AgentSchemaDetail XML
	,@IsSpanishLanguage INT -- Idlenguage
	,@HasError BIT OUTPUT
	,@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN TRY

	SELECT 1

	DECLARE @DocHandle INT
			,@Values XML
			,@IdPayerConfig INT
			,@Date DATETIME
			,@IdPreviousFee INT
			,@IdPreviousCommission INT
			,@PreviousTempSpread MONEY
			,@PreviousEndDateTempSpread DATETIME
			,@IdPreviousSpread INT
			,@PreviousSpread MONEY
			,@IdCurrentFee INT
			,@IdCurrentCommission INT
			,@CurrentTempSpread MONEY
			,@CurrentEndDateTempSpread DATETIME
			,@IdCurrentSpread INT
			,@CurrentSpread MONEY

	DECLARE @IdPayerV INT
			,@IdGatewayV INT
			,@IdPaymentTypeV INT
			,@IdCountryCurrencyV INT

	CREATE TABLE #PreviousAgentSchemaDetail(
	IdPayerConfig INT
	, SpreadValue MONEY
	, IdFee INT
	, IdCommission INT
	, TempSpread MONEY
	, EndDateTempSpread DATETIME
	, IdSpread INT
	)

	CREATE TABLE #CurrentAgentSchemaDetail(
	IdPayerConfig INT
	, SpreadValue MONEY
	, IdFee INT
	, IdCommission INT
	, TempSpread MONEY
	, EndDateTempSpread DATETIME
	, IdSpread INT
	)

	SET @HasError=0
	SET @Date=GETDATE()

	DECLARE @isInsert bit

	IF @IdAgentSchema=0
	BEGIN
		set @isInsert=1
		IF (@SchemaDefault=1) AND (ISNULL(@IdAgent,0)=0)
			AND EXISTS (SELECT TOP 1 1 FROM [AgentSchema] WHERE SchemaDefault=1 /*and idgenericstatus=1*/ AND idagent IS NULL AND IdCountryCurrency=@IdCountryCurrency /*and IdAgentSchema!=@IdAgentSchema*/)
		BEGIN
			SET @HasError=1        
			SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (CASE @IsSpanishLanguage WHEN 1 THEN 0 ELSE 1 END,88)   
			RETURN
		END

		INSERT AgentSchema (SchemaName, IdFee, IdCommission, IdCountryCurrency, SchemaDefault, DateOfLastChange, EnterByIdUser, IdGenericStatus, Description, IdAgent)
		VALUES (@SchemaName, @IdFee, @IdCommission, @IdCountryCurrency, @SchemaDefault, @Date, @EnterByIdUser, @IdGenericStatus, @Description, @IdAgent)

		SELECT @IdAgentSchema=SCOPE_IDENTITY ()

		SET @Values= (SELECT * FROM AgentSchema (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
		INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
		VALUES ('AgentSchema','INSERT',@Values,@Date,@EnterByIdUser)

	END
	ELSE
	BEGIN
		set @isInsert=0

		UPDATE AgentSchema
		SET SchemaName=@SchemaName
		, IdFee=@IdFee
		, IdCommission=@IdCommission
		--, IdCountryCurrency=@IdCountryCurrency
		, SchemaDefault=@SchemaDefault
		, DateOfLastChange=@Date
		, EnterByIdUser=@EnterByIdUser
		, IdGenericStatus=@IdGenericStatus
		, Description=@Description
		--, IdAgent=@IdAgent		
		WHERE IdAgentSchema =@IdAgentSchema 

		SET @Values= (SELECT * FROM AgentSchema (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
		INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
		VALUES ('AgentSchema','UPDATE',@Values,@Date,@EnterByIdUser)

	END

	INSERT #PreviousAgentSchemaDetail
	SELECT IdPayerConfig, SpreadValue, IdFee, IdCommission, TempSpread, EndDateTempSpread, IdSpread
	FROM AgentSchemaDetail (NOLOCK) 
	WHERE IdAgentSchema =@IdAgentSchema
	ORDER BY IdPayerConfig

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@AgentSchemaDetail
	
	INSERT #CurrentAgentSchemaDetail
	SELECT IdPayerConfig
	, SpreadValue
	, CASE WHEN ISNULL(IdFee,0)=0 THEN NULL ELSE IdFee END
	, CASE WHEN ISNULL(IdCommission,0)=0 THEN NULL ELSE IdCommission END
	, TempSpread
	, CASE WHEN ISNULL(EndDateTempSpread,'19000101') ='19000101' THEN NULL ELSE EndDateTempSpread END
	, CASE WHEN ISNULL(IdSpread,0)=0 THEN NULL ELSE IdSpread END
	FROM OPENXML (@DocHandle, '/AgentSchemaDetail/Detail',2) 
	WITH (
	IdPayerConfig INT
	,SpreadValue MONEY
	,IdFee INT
	,IdCommission INT
	,TempSpread MONEY
	,EndDateTempSpread DATETIME
	,IdSpread INT
	)
	ORDER BY IdPayerConfig

	EXEC sp_xml_removedocument @DocHandle

	DELETE AgentSchemaDetail WHERE IdAgentSchema =@IdAgentSchema

	INSERT AgentSchemaDetail(IdAgentSchema, IdPayerConfig, SpreadValue, DateOfLastChange, EnterByIdUser, IdFee, IdCommission, TempSpread, EndDateTempSpread, IdSpread)
	SELECT @IdAgentSchema
	, IdPayerConfig
	, SpreadValue 
	, @Date
	, @EnterByIdUser
	, IdFee
	, IdCommission
	, TempSpread
	, EndDateTempSpread
	, IdSpread
	FROM #CurrentAgentSchemaDetail

	SET @Values= (SELECT * FROM AgentSchemaDetail (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
	INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
	VALUES ('AgentSchemaDetail','INSERT',@Values,@Date,@EnterByIdUser)

	IF (ISNULL(@IdAgent,0)=0)
		BEGIN
			IF(@isInsert=1 )
				BEGIN
					SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SchemaSaveOk')
				END
			ELSE
				BEGIN
					SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'SchemaUpdateOk')
				END
		END
	ELSE
		BEGIN
			IF(@isInsert=1 )
				BEGIN
					SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaSaveOk')
				END
			ELSE
				BEGIN
					SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaUpdateOk')
				END
		END

	WHILE EXISTS(SELECT TOP 1 1 FROM #PreviousAgentSchemaDetail )
	BEGIN

		SET @IdPreviousFee =NULL
		SET @IdPreviousCommission =NULL
		SET @PreviousTempSpread =NULL
		SET @PreviousEndDateTempSpread =NULL 
		SET @IdPreviousSpread =NULL
		SET @PreviousSpread =NULL
		SET @IdCurrentFee =NULL
		SET @IdCurrentCommission =NULL
		SET @CurrentTempSpread =NULL
		SET @CurrentEndDateTempSpread =NULL
		SET @IdCurrentSpread =NULL
		SET @CurrentSpread =NULL
		SET @IdPayerV =NULL
		SET @IdGatewayV =NULL
		SET @IdPaymentTypeV =NULL
		SET @IdCountryCurrencyV =NULL

		SELECT TOP 1 @IdPayerConfig=IdPayerConfig, @PreviousSpread=SpreadValue, @IdPreviousFee=IdFee, @IdPreviousCommission=IdCommission, @PreviousTempSpread=TempSpread, @PreviousEndDateTempSpread=EndDateTempSpread, @IdPreviousSpread=IdSpread
		FROM #PreviousAgentSchemaDetail 
		ORDER BY IdPayerConfig

		SELECT TOP 1 @CurrentSpread=SpreadValue , @IdCurrentFee=IdFee, @IdCurrentCommission=IdCommission, @CurrentTempSpread=TempSpread, @CurrentEndDateTempSpread=EndDateTempSpread, @IdCurrentSpread=IdSpread
		FROM #CurrentAgentSchemaDetail
		WHERE IdPayerConfig=@IdPayerConfig 
		ORDER BY IdPayerConfig

		SELECT @IdPayerV=PC.IdPayer
		,@IdGatewayV=PC.IdGateway
		,@IdPaymentTypeV=PC.IdPaymentType
		,@IdCountryCurrencyV=PC.IdCountryCurrency 
		FROM PayerConfig PC (NOLOCK) 
		WHERE PC.IdPayerConfig = @IdPayerConfig 

		DELETE #PreviousAgentSchemaDetail WHERE IdPayerConfig=@IdPayerConfig

		IF @IdPreviousFee<>@IdCurrentFee
		BEGIN
			INSERT AgentSchemaDetailFeeLog (IdAgentSchema, IdPayerConfig, IdPreviousFee, IdCurrentFee, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousFee, @IdCurrentFee, @Date, @EnterByIdUser)
			
			--LOG INVALID
			INSERT INTO PreTransferTrackingLog (ServerDate,idPretransfer,Reason) 
			SELECT getdate(),IdPreTransfer,'Fee has changed @IdAgentSchema='+Convert(VARCHAR,@IdAgentSchema)+' @IdPayerConfig='+Convert(varchar,@IdPayerConfig)+'@PreviousTempSpread='+convert(VARCHAR,@PreviousTempSpread)+'@CurrentTempSpread='+convert(VARCHAR,@CurrentTempSpread)+'@PreviousEndDateTempSpread='+isnull(COnvert(VARCHAR,@PreviousEndDateTempSpread),'NULL')+'@CurrentEndDateTempSpread=' +isnull(COnvert(VARCHAR,@CurrentEndDateTempSpread),'NULL') FROM PreTransfer
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV 
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
			--LOG INVALID
				
			UPDATE PreTransfer 
			SET IsValid=1 
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV  
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
		END
		
		IF @IdPreviousCommission<>@IdCurrentCommission
		BEGIN
			INSERT AgentSchemaDetailCommissionLog (IdAgentSchema, IdPayerConfig, IdPreviousCommission, IdCurrentCommission, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousCommission, @IdCurrentCommission, @Date, @EnterByIdUser)


			--LOG INVALID
			INSERT INTO PreTransferTrackingLog (ServerDate,idPretransfer,Reason) 
			SELECT getdate(),IdPreTransfer,'Comission has changed @IdAgentSchema='+Convert(VARCHAR,@IdAgentSchema)+' @IdPayerConfig='+Convert(varchar,@IdPayerConfig)+'@PreviousTempSpread='+convert(VARCHAR,@PreviousTempSpread)+'@CurrentTempSpread='+convert(VARCHAR,@CurrentTempSpread)+'@PreviousEndDateTempSpread='+isnull(COnvert(VARCHAR,@PreviousEndDateTempSpread),'NULL')+'@CurrentEndDateTempSpread=' +isnull(COnvert(VARCHAR,@CurrentEndDateTempSpread),'NULL')
			 FROM PreTransfer
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV 
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
			--LOG INVALID
			
			UPDATE PreTransfer 
			SET IsValid=1 
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
		END

		IF (@PreviousTempSpread<>@CurrentTempSpread AND @CurrentTempSpread > 0 ) 
		OR (@PreviousEndDateTempSpread<>@CurrentEndDateTempSpread AND @CurrentEndDateTempSpread IS NOT NULL) 
		OR (@PreviousEndDateTempSpread is null and @CurrentEndDateTempSpread is not NULL AND @CurrentTempSpread > 0  )
		BEGIN
			INSERT AgentSchemaDetailTempSpreadLog (IdAgentSchema, IdPayerConfig, PreviousTempSpread, PreviousEndDateTempSpread, CurrentTempSpread, CurrentEndDateTempSpread, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @PreviousTempSpread, @PreviousEndDateTempSpread, @CurrentTempSpread, @CurrentEndDateTempSpread, @Date, @EnterByIdUser)

			--LOG INVALID
			INSERT INTO PreTransferTrackingLog (ServerDate,idPretransfer,Reason) 
			SELECT getdate(),IdPreTransfer,'TempSpread has changed @IdAgentSchema='+Convert(VARCHAR,@IdAgentSchema)+' @IdPayerConfig='+Convert(varchar,@IdPayerConfig)+'@PreviousTempSpread='+convert(VARCHAR,@PreviousTempSpread)+'@CurrentTempSpread='+convert(VARCHAR,@CurrentTempSpread)+'@PreviousEndDateTempSpread='+isnull(COnvert(VARCHAR,@PreviousEndDateTempSpread),'NULL')+'@CurrentEndDateTempSpread=' +isnull(COnvert(VARCHAR,@CurrentEndDateTempSpread),'NULL') 
			FROM PreTransfer
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV 
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
			--LOG INVALID
			
			UPDATE PreTransfer 
			SET IsValid=1 
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
		END

        ---se agrego is null
		IF isnull(@IdPreviousSpread,0)<>@IdCurrentSpread OR @PreviousSpread<>@CurrentSpread 
		BEGIN
			INSERT AgentSchemaDetailSpreadLog (IdAgentSchema, IdPayerConfig, IdPreviousSpreadValue, PreviousSpreadValue, IdCurrentSpreadValue, CurrentSpreadValue, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousSpread, @PreviousSpread, @IdCurrentSpread, @CurrentSpread, @Date, @EnterByIdUser)
			
			--LOG INVALID
			INSERT INTO PreTransferTrackingLog (ServerDate,idPretransfer,Reason) 
			SELECT getdate(),IdPreTransfer,'Spread has changed @IdAgentSchema='+Convert(VARCHAR,@IdAgentSchema)+' @IdPayerConfig='+Convert(varchar,@IdPayerConfig)+'@PreviousTempSpread='+convert(VARCHAR,@PreviousTempSpread)+'@CurrentTempSpread='+convert(VARCHAR,@CurrentTempSpread)+'@PreviousEndDateTempSpread='+isnull(COnvert(VARCHAR,@PreviousEndDateTempSpread),'NULL')+'@CurrentEndDateTempSpread=' +isnull(COnvert(VARCHAR,@CurrentEndDateTempSpread),'NULL')
			FROM PreTransfer
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV 
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
			--LOG INVALID
			
			UPDATE PreTransfer 
			SET IsValid=1 
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
				AND IdAgentSchema = @IdAgentSchema
				AND IsValid != 1
		END

	END

	
END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaSaveError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),ERROR_MESSAGE())  

END CATCH

