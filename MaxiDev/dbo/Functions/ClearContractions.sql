CREATE FUNCTION [dbo].[ClearContractions]
(
	@Input				VARCHAR(500)
)
RETURNS VARCHAR(500)
AS
BEGIN

	IF(RIGHT(@Input, 1) <> '')
		SET @Input = @Input + ' '

	IF(LEFT(@Input, 1) <> '')
		SET @Input = ' ' + @Input

	SET @Input = REPLACE(@Input, ' DEL ', ' ')
	SET @Input = REPLACE(@Input, ' DE LOS ', ' ')
	SET @Input = REPLACE(@Input, ' DE LA ', ' ')
	SET @Input = REPLACE(@Input, ' DE LAS ', ' ')
	SET @Input = REPLACE(@Input, ' DE ', ' ')
	SET @Input = REPLACE(@Input, ' EL ', ' ')
	SET @Input = REPLACE(@Input, ' LOS ', ' ')
	SET @Input = REPLACE(@Input, ' LA ', ' ')
	SET @Input = REPLACE(@Input, ' LAS ', ' ')
	SET @Input = REPLACE(@Input, ' LO ', ' ')
	SET @Input = REPLACE(@Input, ' LOS ', ' ')
	SET @Input = REPLACE(@Input, ' AL ', ' ')

	SET @Input = LTRIM(RTRIM(@Input))
	RETURN @Input
END