CREATE FUNCTION [dbo].[PhoneticStandardize]
(
	@Input				VARCHAR(500),
	@NotConstraints		BIT
)
RETURNS VARCHAR(500)
AS
BEGIN
	SET @Input = UPPER(@Input)

	SET @Input = dbo.fn_EspecialChrOFF(@Input)
	SET @Input = dbo.fn_EspecialChrEKOFF(@Input)

	-- SimilarEsp
	SET @Input = REPLACE(@Input, 'CE', 'SE')
	SET @Input = REPLACE(@Input, 'CI', 'SI')
	
	SET @Input = REPLACE(@Input, 'ZA', 'SA')
	SET @Input = REPLACE(@Input, 'ZE', 'SE')
	SET @Input = REPLACE(@Input, 'ZI', 'SI')
	SET @Input = REPLACE(@Input, 'ZO', 'SO')
	SET @Input = REPLACE(@Input, 'ZU', 'SU')

	SET @Input = REPLACE(@Input, 'AZ', 'AS')
	SET @Input = REPLACE(@Input, 'EZ', 'ES')
	SET @Input = REPLACE(@Input, 'IZ', 'IS')
	SET @Input = REPLACE(@Input, 'OZ', 'OS')
	SET @Input = REPLACE(@Input, 'UZ', 'US')
	
	SET @Input = REPLACE(@Input, 'GE', 'JE')
	SET @Input = REPLACE(@Input, 'GI', 'JI')
	
	SET @Input = REPLACE(@Input, 'XI', 'JI')
	SET @Input = REPLACE(@Input, 'XA', 'JA')
		
	SET @Input = REPLACE(@Input, 'XE', 'SE')
	SET @Input = REPLACE(@Input, 'XO', 'SO')
	SET @Input = REPLACE(@Input, 'XO', 'SU')

	SET @Input = REPLACE(@Input, 'VA', 'BA')
	SET @Input = REPLACE(@Input, 'VE', 'BE')
	SET @Input = REPLACE(@Input, 'VI', 'BI')
	SET @Input = REPLACE(@Input, 'VO', 'BO')
	SET @Input = REPLACE(@Input, 'VU', 'BU')
	
	SET @Input = REPLACE(@Input, 'SS', 'S')
	SET @Input = REPLACE(@Input, 'FF', 'F')
	SET @Input = REPLACE(@Input, 'JJ', 'J')
	SET @Input = REPLACE(@Input, 'AA', 'A')
	SET @Input = REPLACE(@Input, 'OO', 'O')

	SET @Input = REPLACE(@Input, 'LL', 'Y')

	-- Y as consonant
	SET @Input = REPLACE(@Input, 'YA', 'JA')
	SET @Input = REPLACE(@Input, 'YE', 'JE')
	SET @Input = REPLACE(@Input, 'YI', 'JI')
	SET @Input = REPLACE(@Input, 'YO', 'JO')
	SET @Input = REPLACE(@Input, 'YU', 'JU')
	
	-- Y as vocal
	SET @Input = REPLACE(@Input, 'Y', 'I')

	SET @Input = REPLACE(UPPER(@Input), 'H', '');


	IF (@NotConstraints = 1)
	BEGIN
		SET @Input = dbo.ClearContractions(@Input)
		--SET @Input = REPLACE(@Input, ' DEL ', ' ')
		--SET @Input = REPLACE(@Input, ' DE LOS ', ' ')
		--SET @Input = REPLACE(@Input, ' DE LA ', ' ')
		--SET @Input = REPLACE(@Input, ' DE LAS ', ' ')
		--SET @Input = REPLACE(@Input, ' DE ', ' ')
		--SET @Input = REPLACE(@Input, ' EL ', ' ')
		--SET @Input = REPLACE(@Input, ' LOS ', ' ')
		--SET @Input = REPLACE(@Input, ' LA ', ' ')
		--SET @Input = REPLACE(@Input, ' LAS ', ' ')
		--SET @Input = REPLACE(@Input, ' LO ', ' ')
		--SET @Input = REPLACE(@Input, ' LOS ', ' ')
		--SET @Input = REPLACE(@Input, ' AL ', ' ')
	END

	SET @Input = REPLACE(@Input, ' ', '')
	
	RETURN @Input
END
