create FUNCTION dbo.[fnEncryptData] (@KeyGuid UNIQUEIDENTIFIER, @Data VARBINARY(max))
RETURNS VARBINARY(max)
AS
BEGIN

 RETURN  encryptbykey( @KeyGuid, @Data)

END