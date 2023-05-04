CREATE FUNCTION dbo.fn_GetNumeric
    (@strAlphaNumeric NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @intAlpha INT
    SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
    WHILE @intAlpha > 0
    BEGIN
        SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
        SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
    END
 END
 RETURN ISNULL(@strAlphaNumeric,0)
END
