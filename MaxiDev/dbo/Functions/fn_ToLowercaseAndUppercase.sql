-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-30
-- Description:	Return first letter of words in Uppercase and Lowercase for the rest
-- =============================================
CREATE FUNCTION [dbo].[fn_ToLowercaseAndUppercase]
(
	-- Add the parameters for the function here
	@Text NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NewString NVARCHAR(MAX)

	DECLARE @Words TABLE ([Word] NVARCHAR(MAX))

	-- Add the T-SQL statements to compute the return value here
	INSERT INTO @Words
		SELECT [Item] FROM [dbo].[fnSplit](@Text,' ')

	SELECT @NewString = COALESCE(@NewString + ' ', '') + (UPPER(LEFT([Word],1))+LOWER(SUBSTRING([Word],2,LEN([Word])))) FROM @Words

	-- Return the result of the function
	RETURN @NewString

END
