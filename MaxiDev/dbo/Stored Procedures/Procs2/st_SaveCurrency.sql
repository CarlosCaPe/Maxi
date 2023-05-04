CREATE PROCEDURE [dbo].[st_SaveCurrency]
(
	@IdCurrency int,
	@CurrencyName nvarchar(max),
    @CurrencyCode nvarchar(max),
    @DateOfLastChange datetime = null,
    @EnterByIdUser int,
    @DivisorExchangeRate decimal(4,2),
	@HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		IF (@IdCurrency = 0)
			BEGIN
				INSERT INTO [dbo].[Currency] ([CurrencyName], [CurrencyCode], [DateOfLastChange], [EnterByIdUser], [DivisorExchangeRate])
				VALUES (@CurrencyName, @CurrencyCode, GETDATE(), @EnterByIdUser, @DivisorExchangeRate)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[Currency]
				SET [CurrencyName] = @CurrencyName, 
					[CurrencyCode] = @CurrencyCode, 
					[DateOfLastChange] = GETDATE(), 
					[EnterByIdUser] = @EnterByIdUser, 
					[DivisorExchangeRate] = @DivisorExchangeRate
				WHERE IdCurrency = @IdCurrency
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END




