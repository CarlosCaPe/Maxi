CREATE FUNCTION [dbo].[fnClearOFACName]
(
	@Input	NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	SET @Input = CONCAT(' ', @Input, ' ')

	SET @Input = REPLACE(@Input, '.', ' ')
	SET @Input = REPLACE(@Input, ',', ' ')
	SET @Input = REPLACE(@Input, ' LLC ', '')
	SET @Input = REPLACE(@Input, ' LTD ', '')
	SET @Input = REPLACE(@Input, ' INC ', '')
	SET @Input = REPLACE(@Input, '  ', ' ')

	SET @Input = LTRIM(RTRIM(@Input))

	RETURN @Input
END