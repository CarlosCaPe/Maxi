create FUNCTION dbo.[fnDecryptData] (@Data VARBINARY(max))
RETURNS VARCHAR(max)
AS
BEGIN

 RETURN convert( VARCHAR(max), decryptbykeyautocert( cert_id( 'MAXI_CERTIFICATE' ), null, @Data))

END