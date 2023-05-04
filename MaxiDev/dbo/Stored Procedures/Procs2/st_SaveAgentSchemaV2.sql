﻿/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="14/12/2018" Author="smacias"> Creado </log>
<log Date="15/04/2019" Author="jresendiz"> Return Id </log>
<log Date="17/04/2019" Author="esalazar"> Validate IdFee and IdCommission for Schema </log>
<log Date="25/11/2019" Author="jzuniga"> #1 Se especifican columnas de busqueda, se agrego with(nolock) </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_SaveAgentSchemaV2]
(

	@IdAgentSchema INT OUT,
		@IdAgentSchemaOUT INT OUT
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

	----New Schema
	IF @IdAgentSchema=0
	BEGIN

		set @isInsert=1
		IF (@SchemaDefault=1) AND (ISNULL(@IdAgent,0)=0) --#1
			AND EXISTS (SELECT TOP 1 1 FROM [AgentSchema] WITH(NOLOCK) WHERE SchemaDefault=1 /*and idgenericstatus=1*/ AND idagent IS NULL AND IdCountryCurrency=@IdCountryCurrency /*and IdAgentSchema!=@IdAgentSchema*/)
		BEGIN
			SET @HasError=1        
			SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (CASE @IsSpanishLanguage WHEN 1 THEN 0 ELSE 1 END,88)   
			RETURN
		END
		---No IdFee , IdCommission
		IF((@IdFee IS NULL OR @IdFee= 0) AND (@IdCommission IS NULL OR @IdCommission = 0) )
			BEGIN
				INSERT AgentSchema (SchemaName, /*IdFee, IdCommission,*/ IdCountryCurrency, SchemaDefault, DateOfLastChange, EnterByIdUser, IdGenericStatus, Description, IdAgent)
				VALUES (@SchemaName, /*@IdFee, --@IdCommission,*/ @IdCountryCurrency, @SchemaDefault, @Date, @EnterByIdUser, @IdGenericStatus, @Description, @IdAgent)
			END
			ELSE 
			BEGIN
			INSERT AgentSchema (SchemaName, IdFee, IdCommission, IdCountryCurrency, SchemaDefault, DateOfLastChange, EnterByIdUser, IdGenericStatus, Description, IdAgent)
				VALUES (@SchemaName, @IdFee, @IdCommission, @IdCountryCurrency, @SchemaDefault, @Date, @EnterByIdUser, @IdGenericStatus, @Description, @IdAgent)
			END

		

		SELECT @IdAgentSchemaOUT=SCOPE_IDENTITY();
			--SELECT @IdAgentSchemaOUT=@IdAgentSchema;
		SET @IdAgentSchema=@IdAgentSchemaOUT;

		--#1
		SET @Values= (SELECT IdAgentSchema, SchemaName, IdFee, IdCommission, IdCountryCurrency, SchemaDefault, DateOfLastChange, EnterByIdUser, IdGenericStatus, Description, IdAgent, IdAgentSchemaParent, Spread, EndDateSpread FROM AgentSchema (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
		INSERT AuditLog (ObjectName, Operation, [Values], DateOfLastChange, EnterByIdUser)
		VALUES ('AgentSchema','INSERT',@Values,@Date,@EnterByIdUser)

	END
	ELSE
	BEGIN
		set @isInsert=0
IF((@IdFee IS NULL OR @IdFee= 0) AND (@IdCommission IS NULL OR @IdCommission = 0) )
	BEGIN
		UPDATE AgentSchema
		SET SchemaName=@SchemaName
		--, IdFee=@IdFee
		--, IdCommission=@IdCommission
		--, IdCountryCurrency=@IdCountryCurrency
		, SchemaDefault=@SchemaDefault
		, DateOfLastChange=@Date
		, EnterByIdUser=@EnterByIdUser
		, IdGenericStatus=@IdGenericStatus
		, Description=@Description
		--, IdAgent=@IdAgent		
		WHERE IdAgentSchema =@IdAgentSchema 
	END
	ELSE 
	BEGIN
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
	END
		-- #1
		SET @Values= (SELECT IdAgentSchema, SchemaName, IdFee, IdCommission, IdCountryCurrency, SchemaDefault, DateOfLastChange, EnterByIdUser, IdGenericStatus, Description, IdAgent, IdAgentSchemaParent, Spread, EndDateSpread FROM AgentSchema (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
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
	-- #1
	SET @Values= (SELECT IdAgentSchemaDetail, IdAgentSchema, IdPayerConfig, SpreadValue, DateOfLastChange, EnterByIdUser, IdFee, IdCommission, TempSpread, EndDateTempSpread, IdSpread FROM AgentSchemaDetail (NOLOCK) WHERE IdAgentSchema=@IdAgentSchema FOR XML AUTO,ELEMENTS)
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
			INSERT [dbo].AgentSchemaDetailFeeLog (IdAgentSchema, IdPayerConfig, IdPreviousFee, IdCurrentFee, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousFee, @IdCurrentFee, @Date, @EnterByIdUser)

			UPDATE PreTransfer 
			SET IsValid=1 , DateOfLastChange=GETDATE()
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV  
		END

		IF @IdPreviousCommission<>@IdCurrentCommission
		BEGIN
			INSERT [dbo].AgentSchemaDetailCommissionLog (IdAgentSchema, IdPayerConfig, IdPreviousCommission, IdCurrentCommission, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousCommission, @IdCurrentCommission, @Date, @EnterByIdUser)

			UPDATE PreTransfer 
			SET IsValid=1 , DateOfLastChange=GETDATE()
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
		END

		IF ((@PreviousTempSpread<>@CurrentTempSpread) AND (@CurrentTempSpread > 0) AND ((@PreviousEndDateTempSpread<>@CurrentEndDateTempSpread) AND (@CurrentEndDateTempSpread IS NOT NULL))  ) 
		--OR ((@PreviousEndDateTempSpread<>@CurrentEndDateTempSpread) AND (@CurrentEndDateTempSpread IS NOT NULL)) 
		OR ((@PreviousEndDateTempSpread is null) AND ((@CurrentEndDateTempSpread IS NOT NULL) AND (@CurrentTempSpread > 0) ) )
		BEGIN
			INSERT AgentSchemaDetailTempSpreadLog (IdAgentSchema, IdPayerConfig, PreviousTempSpread, PreviousEndDateTempSpread, CurrentTempSpread, CurrentEndDateTempSpread, DateOfLastChange, EnterByIdUser, IdAgent)
			VALUES (@IdAgentSchema, @IdPayerConfig, @PreviousTempSpread, @PreviousEndDateTempSpread, @CurrentTempSpread, @CurrentEndDateTempSpread, @Date, @EnterByIdUser, @IdAgent)

			UPDATE PreTransfer 
			SET IsValid=1 , DateOfLastChange=GETDATE()
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
		END

        ---se agrego is null
		IF isnull(@IdPreviousSpread,0)<>@IdCurrentSpread OR @PreviousSpread<>@CurrentSpread 
		BEGIN
			INSERT [dbo].AgentSchemaDetailSpreadLog (IdAgentSchema, IdPayerConfig, IdPreviousSpreadValue, PreviousSpreadValue, IdCurrentSpreadValue, CurrentSpreadValue, DateOfLastChange, EnterByIdUser)
			VALUES (@IdAgentSchema, @IdPayerConfig, @IdPreviousSpread, @PreviousSpread, @IdCurrentSpread, @CurrentSpread, @Date, @EnterByIdUser)

			UPDATE PreTransfer 
			SET IsValid=1 , DateOfLastChange=GETDATE()
			WHERE IdPayer =@IdPayerV 
				AND IdGateway =@IdGatewayV 
				AND IdPaymentType =@IdPaymentTypeV
				AND IdCountryCurrency =@IdCountryCurrencyV
		END

	END

	
END TRY
BEGIN CATCH

	SET @HasError=1
	SELECT @MessageOut =dbo.GetMessageFromMultiLenguajeResorces (@IsSpanishLanguage,'AgentSchemaSaveError')
	INSERT ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES(ERROR_PROCEDURE(),GETDATE(),CONCAT(ERROR_MESSAGE(), ERROR_LINE()))  

END CATCH
