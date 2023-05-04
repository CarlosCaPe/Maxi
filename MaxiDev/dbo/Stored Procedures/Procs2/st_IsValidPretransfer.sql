CREATE PROCEDURE st_IsValidPretransfer
(
	@IdPretransfer	BIGINT
)
AS
BEGIN
	DECLARE @IsValid	BIT

	SELECT
		@IsValid = CASE WHEN p.Status = 0 THEN 1 ELSE 0 END
	FROM PreTransfer p
	WHERE p.IdPreTransfer = @IdPretransfer
	AND p.IdTransfer IS NOT NULL

	IF @IsValid IS NULL
		SET @IsValid = 0

	SELECT @IsValid
END
