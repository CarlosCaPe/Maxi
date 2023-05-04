CREATE PROCEDURE MoneyGram.st_GetMoneyGramPreTransfer
(
	@IdPretransfer	BIGINT
)
AS
BEGIN

	SELECT
		t.MgiTransactionSessionID
	FROM MoneyGram.[Transaction] t
	WHERE 
		t.IdPretransfer = @IdPretransfer

	--SELECT '' FieldKey, '' FieldValue
END