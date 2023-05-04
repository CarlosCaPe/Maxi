CREATE PROCEDURE st_GetPayerValidations
(
	@IdPayerConfig			INT
)
AS
BEGIN
	
	DECLARE @RequiredAccountType BIT
	IF EXISTS(SELECT 1 FROM PayerConfig pc JOIN AccountTypePayer atp ON atp.IdPayer = pc.IdPayer WHERE pc.IdPayerConfig = @IdPayerConfig AND pc.IdPaymentType = 2)
		SET @RequiredAccountType = 1

	SELECT 
		ISNULL(@RequiredAccountType, 0) RequiredAccountType

	SELECT
		pab.IdPayerAmountBase,
		pab.IdPayerConfig,
		pab.IdScaleAmountBase,
		sab.AmountBase,
		pab.IsEnabled,
		pab.ValidateUSDAmount
	FROM PayerAmountBase pab
		JOIN ScaleAmountBase sab ON sab.IdScaleAmountBase = pab.IdScaleAmountBase
	WHERE 
		pab.IdPayerConfig = @IdPayerConfig

	SELECT
		abc.CurrencyCode,
		abc.IdPaymentType,
		abc.AtmAmountBase,
		abc.NumberLength,
		abc.MaxAmount
	FROM PayerConfig pc
		JOIN CountryCurrency cc ON cc.IdCountryCurrency = pc.IdCountryCurrency
		JOIN Currency c ON c.IdCurrency = cc.IdCurrency
		JOIN AmountBaseByCurrency abc ON abc.CurrencyCode = c.CurrencyCode AND abc.IdPaymentType = pc.IdPaymentType
	WHERE pc.IdPayerConfig = @IdPayerConfig
END
