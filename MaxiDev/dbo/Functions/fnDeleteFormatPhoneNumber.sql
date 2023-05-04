create FUNCTION [dbo].[fnDeleteFormatPhoneNumber](@PhoneNo VARCHAR(20))
RETURNS VARCHAR(25)
AS
BEGIN
DECLARE @Formatted VARCHAR(25)

    SET @Formatted = REPLACE(REPLACE(REPLACE(REPLACE(@PhoneNo, '(', ''), ')', ''), '-', ''), ' ', '')

RETURN @Formatted
END