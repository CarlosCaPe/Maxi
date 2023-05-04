-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-24
-- Description:	Save a TopUp scheme // BackOffice-BillPayment
-- =============================================
CREATE PROCEDURE [Operation].[st_SaveSchema]
(   
    @IdSchema INT,
    @SchemaName NVARCHAR(MAX),
    @IdCountry INT,
    @IdCarrier INT,
    @IdProduct INT,
    @BeginValue MONEY,
    @EndValue MONEY,
    @Commission MONEY,
    @IsDefault BIT,
    @IdGenericStatus INT,
	@EnterByIdUser INT,
    @IdLenguage INT,
    @IdSchemaOut INT OUTPUT,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT,
    @Idprovider INT = NULL
)
AS
BEGIN TRY

	SET NOCOUNT ON
	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	SET @HasError=0
	SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaSave')

	IF @IdOtherProduct=7 -- TransferTo Top Up
	BEGIN
		IF @IdSchema=0
		BEGIN
			IF (EXISTS (	SELECT TOP 1 1
							FROM [TransFerTo].[Schema] WITH (NOLOCK)
							WHERE [IdOtherProduct]=@IdOtherProduct
								AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
								AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
								AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
								AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
								AND ISNULL([EndValue],0)=ISNULL(@EndValue,0)
								AND [IsDefault]=0
								AND [Commission]=@Commission)
							AND @IsDefault=0)
				OR
				(EXISTS (	SELECT TOP 1 1
							FROM [TransFerTo].[Schema] WITH (NOLOCK)
							WHERE [IdOtherProduct]=@IdOtherProduct
								AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
								AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
								AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
								AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
								AND ISNULL([EndValue],0)=ISNULL(@EndValue,0)
								AND [IsDefault]=1)
							AND @IdProduct IS NOT NULL
							AND @IsDefault=1)
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
				RETURN
			END

			IF EXISTS (	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
							AND [IsDefault]=1
							AND (
									(ISNULL(@BeginValue,0)>=[BeginValue]
									AND ISNULL(@BeginValue,0)<=[EndValue])
								OR
									(ISNULL(@EndValue,0)>=[BeginValue]
									AND ISNULL(@EndValue,0)<=[EndValue])
								)
							AND [IsDefault]=1)
						AND @IdProduct IS NULL
						AND @IsDefault=1
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
				RETURN
			END

			INSERT INTO [TransFerTo].[Schema]
				   ([SchemaName]
				   ,[IdCountry]
				   ,[IdCarrier]
				   ,[IdProduct]
				   ,[BeginValue]
				   ,[EndValue]
				   ,[Commission]
				   ,[IsDefault]
				   ,[IdGenericStatus]
				   ,[DateOfCreation]
				   ,[DateOfLastChange]
				   ,[EnterByIdUser]
				   ,IdOtherProduct
				   )
			 VALUES
				 (
					@SchemaName,
					@IdCountry,
					@IdCarrier,
					@IdProduct,
					@BeginValue,
					@EndValue,
					@Commission,
					@IsDefault,
					@IdGenericStatus,
					GETDATE(),
					GETDATE(),
					@EnterByIdUser,
					@IdOtherProduct
				 )
      
			 SET @IdSchemaOut = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			IF (EXISTS(	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0)
							AND [IsDefault]=0
							AND [Commission]=@Commission
							AND [IdSchema]!=@IdSchema)
						AND @IsDefault=0)
				OR
				(EXISTS (	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0)
							AND [IsDefault]=1
							AND [IdSchema]!=@IdSchema)
						AND @IdProduct IS NOT NULL
						AND @IsDefault=1)
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
				RETURN
			END

			IF EXISTS (	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND ISNULL([IdProduct],0)=ISNULL(@IdProduct,0)
							AND [IsDefault]=1
							AND (
									(ISNULL(@BeginValue,0)>=[BeginValue]
									AND ISNULL(@BeginValue,0)<=[EndValue])
								OR
									(ISNULL(@EndValue,0)>=[BeginValue]
									AND ISNULL(@EndValue,0)<=[EndValue])
								)
							AND [IsDefault]=1
							AND [IdSchema]!=@IdSchema)
						AND @IdProduct IS NULL
						AND @IsDefault=1
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
				RETURN
			END

			UPDATE [TransFerTo].[Schema]
				SET [SchemaName] = @SchemaName
					,[IdCountry] = @IdCountry
					,[IdCarrier] = @IdCarrier
					,[IdProduct] = @IdProduct
					,[BeginValue] = @BeginValue
					,[EndValue] = @EndValue
					,[Commission] = @Commission
					,[IsDefault] = @IsDefault
					,[IdGenericStatus] = @IdGenericStatus      
					,[DateOfLastChange] = GETDATE()
					,[EnterByIdUser] = @EnterByIdUser
					,IdOtherProduct=@IdOtherProduct
			WHERE IdSchema=@IdSchema

			SET @IdSchemaOut = @IdSchema
		END
	END

	IF @IdOtherProduct IN (9, 17) -- Lunex Top Up, Regalii Top Up
	BEGIN
		IF @IdSchema=0
		BEGIN
			IF (EXISTS(	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL(IdCarrier,0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=0
							AND [Commission]=@Commission
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0))
						AND @IsDefault=0)
				OR
				(EXISTS(SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
							WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=1
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0))
						AND @IsDefault=1)
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
				RETURN
			END

			IF EXISTS (	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=1
							AND (
									(ISNULL(@BeginValue,0)>=[BeginValue]
									AND ISNULL(@BeginValue,0)<=[EndValue])
								OR
									(ISNULL(@EndValue,0)>=[BeginValue]
									AND ISNULL(@EndValue,0)<=[EndValue])
								)
							AND [IsDefault]=1)
						AND @IsDefault=1
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
				RETURN
			END

			INSERT INTO [TransFerTo].[Schema]
				   ([SchemaName]
				   ,[IdCountry]
				   ,[IdCarrier]
				   ,[IdProduct]
				   ,[BeginValue]
				   ,[EndValue]
				   ,[Commission]
				   ,[IsDefault]
				   ,[IdGenericStatus]
				   ,[DateOfCreation]
				   ,[DateOfLastChange]
				   ,[EnterByIdUser]
				   ,[IdOtherProduct]
				   )
			 VALUES
			 (
				@SchemaName,
				@IdCountry,
				@IdCarrier,
				@IdProduct,
				@BeginValue,
				@EndValue,
				@Commission,
				@IsDefault,
				@IdGenericStatus,
				GETDATE(),
				GETDATE(),
				@EnterByIdUser,
				@IdOtherProduct
			 )
      
			 SET @IdSchemaOut = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			IF (EXISTS(	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL(IdCarrier,0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=0
							AND [Commission]=@Commission
							AND IdSchema!=@IdSchema
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0))
						AND @IsDefault=0)
				OR
				(EXISTS(SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=1
							AND [IdSchema]!=@IdSchema
							AND ISNULL([BeginValue],0)=ISNULL(@BeginValue,0)
							AND ISNULL([EndValue],0)=ISNULL(@EndValue,0))
						AND @IsDefault=1)
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
				RETURN
			END

			IF EXISTS (	SELECT TOP 1 1
						FROM [TransFerTo].[Schema] WITH (NOLOCK)
						WHERE [IdOtherProduct]=@IdOtherProduct
							AND ISNULL([IdCountry],0)=ISNULL(@IdCountry,0)
							AND ISNULL([IdCarrier],0)=ISNULL(@IdCarrier,0)
							AND [IsDefault]=1
							AND (
									(ISNULL(@BeginValue,0)>=[BeginValue]
									AND ISNULL(@BeginValue,0)<=[EndValue])
								OR
									(ISNULL(@EndValue,0)>=[BeginValue]
									AND ISNULL(@EndValue,0)<=[EndValue])
								)
							AND [IsDefault]=1
							AND [IdSchema]!=@IdSchema)
						AND @IsDefault=1
			BEGIN
				SET @HasError=1
				SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
				RETURN
			END

			UPDATE [TransFerTo].[Schema]
			   SET [SchemaName] = @SchemaName
				  ,[IdCountry] = @IdCountry
				  ,[IdCarrier] = @IdCarrier
				  ,[IdProduct] = @IdProduct
				  ,[BeginValue] = @BeginValue
				  ,[EndValue] = @EndValue
				  ,[Commission] = @Commission
				  ,[IsDefault] = @IsDefault
				  ,[IdGenericStatus] = @IdGenericStatus      
				  ,[DateOfLastChange] = GETDATE()
				  ,[EnterByIdUser] = @EnterByIdUser
				  ,IdOtherProduct=@IdOtherProduct
			WHERE IdSchema=@IdSchema

			SET @IdSchemaOut = @IdSchema
		END
	END

END TRY
BEGIN CATCH
	SET @HasError=1
	SELECT @Message =[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('TransFerTo.st_SaveSchema', GETDATE(), @ErrorMessage)
END CATCH
