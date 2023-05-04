CREATE PROCEDURE [Corp].[st_SaveValidationRule]
(
	@IdValidationRule int,
	@IdEntityToValidate int,
	@IdValidator int,
	@IdPayerConfig int,
	@Field varchar(50),
	@ErrorMessageES varchar(500),
	@ErrorMessageUS varchar(500),
	@OrderByEntityToValidate int,
	@IdGenericStatus int,
	@IsAllowedToEdit bit,
	@Min int= null,
	@Max int= null,
	@From varchar(50)= null,
	@To varchar(50)= null,
	@Type varchar(50)= null,
	@ComparisonValue varchar(50)= null,
	@Expression varchar(50)= null,
	@Pattern varchar(500) = null,
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @NewIDValidationRule int
	SET @HasError = 0
	SET @Message = ''
 declare @ValidatorName nvarchar(255)

 
 set @ValidatorName = (SELECT ValidatorName	FROM Validator WITH (NOLOCK)	WHERE 	IdValidator = @IdValidator  )

	BEGIN TRY
		IF (@IdValidationRule = 0)
			BEGIN
			INSERT INTO [dbo].[ValidationRules] ([IdEntityToValidate], [IdValidator], [IdPayerConfig], [Field], [ErrorMessageES], [ErrorMessageUS], [OrderByEntityToValidate], 
					[IdGenericStatus], [IsAllowedToEdit])
				VALUES (@IdEntityToValidate, @IdValidator, @IdPayerConfig, @Field, @ErrorMessageES, @ErrorMessageUS, @OrderByEntityToValidate, @IdGenericStatus, @IsAllowedToEdit)
				SET @NewIDValidationRule = SCOPE_IDENTITY()

				IF(@ValidatorName='LengthRule')
				BEGIN
					INSERT INTO [dbo].LengthRule ([IdValidationRule], [Minimum], [Maximo])
					VALUES (@NewIDValidationRule , @Min, @Max)
				END
				IF(@ValidatorName='RangeRule')
				BEGIN
					INSERT INTO [dbo].RangeRule ([IdValidationRule], [FromValue], [ToValue], [Type])
					VALUES (@NewIDValidationRule , @From, @To, @Type)
				END
				IF(@ValidatorName='RegularExpressionRule')
				BEGIN
					INSERT INTO [dbo].RegularExpressionRule ([IdValidationRule], [Pattern])
					VALUES (@NewIDValidationRule , @Pattern)
				END
				IF(@ValidatorName='SimpleComparison')
				BEGIN
					INSERT INTO [dbo].SimpleComparisonRule ([IdValidationRule], [ComparisonValue],[Type], [Expression])
					VALUES (@NewIDValidationRule , @ComparisonValue, @Type, @Expression)
				END
				
			END
		ELSE 
			BEGIN
				UPDATE [dbo].[ValidationRules]
				SET [IdEntityToValidate] = @IdEntityToValidate, 
					[IdValidator] = @IdValidator, 
					[IdPayerConfig] = @IdPayerConfig, 
					[Field] = @Field, 
					[ErrorMessageES] = @ErrorMessageES, 
					[ErrorMessageUS] = @ErrorMessageUS, 
					[OrderByEntityToValidate] = @OrderByEntityToValidate, 
					[IdGenericStatus] = @IdGenericStatus, 
					[IsAllowedToEdit] = @IsAllowedToEdit
				WHERE IdValidationRule = @IdValidationRule


				IF(@ValidatorName='LengthRule')
				BEGIN
					UPDATE [dbo].LengthRule 
					SET [Minimum] = @Min,
					    [Maximo] = @Max
					WHERE IdValidationRule = @IdValidationRule
					
				END
				IF(@ValidatorName='RangeRule')
				BEGIN
					UPDATE [dbo].RangeRule 
						SET [FromValue] = @From,
							[ToValue] = @To,
							[Type]=@Type
						WHERE IdValidationRule = @IdValidationRule	
				END
				IF(@ValidatorName='RegularExpressionRule')
				BEGIN
				UPDATE [dbo].RegularExpressionRule 
					SET [Pattern] = @Pattern
					WHERE IdValidationRule = @IdValidationRule
				END
				IF(@ValidatorName='SimpleComparison')
				BEGIN
				UPDATE [dbo].SimpleComparisonRule 
						SET [ComparisonValue] = @ComparisonValue,
							[Type] = @Type,
							[Expression]=@Expression
						WHERE IdValidationRule = @IdValidationRule
				END
			END
	END TRY
	BEGIN CATCH 
	SET @HasError=1;
	DECLARE @ErrorMessage nvarchar(max)                                                                                             
    SELECT @ErrorMessage=ERROR_MESSAGE()   
	SET @Message= @ErrorMessage                                          
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES ('[Corp].[st_SaveValidationRule]',Getdate(),@ErrorMessage)   
	END CATCH
END
