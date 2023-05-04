CREATE PROCEDURE MoneyGram.st_GetReceiptLanguageByPretransfer
(
	@IdPretransfer	INT
)
AS
BEGIN 

	DECLARE @SecondaryLanguage VARCHAR(200) = 'SPA'
	
	IF EXISTS (
		SELECT 1 
		FROM dbo.PreTransfer p 
			JOIN dbo.CountryCurrency c ON c.IdCountryCurrency = p.IdCountryCurrency AND	c.IdCountry = 3
		WHERE p.IdPreTransfer = @IdPretransfer
	)
		SET @SecondaryLanguage = 'FRA'

	SELECT
		'ENG' PrimaryLanguage,
		@SecondaryLanguage SecondaryLanguage
END