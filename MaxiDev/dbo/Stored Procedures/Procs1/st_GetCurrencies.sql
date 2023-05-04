CREATE PROCEDURE [dbo].[st_GetCurrencies] 
	@IdCurrency INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@IdCurrency = 0)
		BEGIN
			SELECT [IdCurrency], [CurrencyName], [CurrencyCode], [DateOfLastChange], [EnterByIdUser], [DivisorExchangeRate]
			FROM [dbo].[Currency] WITH(NOLOCK)
		END
	ELSE
		BEGIN
			SELECT [IdCurrency], [CurrencyName], [CurrencyCode], [DateOfLastChange], [EnterByIdUser], [DivisorExchangeRate]
			FROM [dbo].[Currency] WITH(NOLOCK)
			WHERE [IdCurrency] = @IdCurrency
		END
END

