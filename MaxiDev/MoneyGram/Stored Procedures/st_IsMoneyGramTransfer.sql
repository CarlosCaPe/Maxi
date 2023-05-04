CREATE PROCEDURE MoneyGram.st_IsMoneyGramTransfer
(
	@IdPretransfer	BIGINT
)
AS
BEGIN
	DECLARE @IsValid	BIT

	SELECT
		@IsValid = CASE WHEN p.IdGateway = 44 THEN 1 ELSE 0 END
	FROM PreTransfer p
	WHERE p.IdPreTransfer = @IdPretransfer

	IF @IsValid IS NULL
		SET @IsValid = 0

	SELECT @IsValid
END
