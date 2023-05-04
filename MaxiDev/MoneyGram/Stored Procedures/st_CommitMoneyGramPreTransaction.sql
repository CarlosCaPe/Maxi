CREATE PROCEDURE MoneyGram.st_CommitMoneyGramPreTransaction
(
	@IdPretransfer                  BIGINT,
	@IdTransfer                     BIGINT,
	
	@ReferenceNumber                VARCHAR(20),
	@PartnerConfirmationNumber      VARCHAR(20),
	@PartnerName                    VARCHAR(200),
	@FreePhoneCallPIN               VARCHAR(20),
	@TollFreePhoneNumber            VARCHAR(20),
	@ExpectedDateOfDelivery         DATETIME,
	@TransactionDateTime            DATETIME,
	@ReferenceNumberTextCode        VARCHAR(50),
	@ReferenceNumberText            VARCHAR(50),
	@ReferenceNumberConsumerText    VARCHAR(50),

	@IdUser							INT
)
AS
BEGIN

	DECLARE @OriginalClaimCode		VARCHAR(200)
	SELECT
		@OriginalClaimCode = t.ClaimCode
	FROM Transfer t WITH(NOLOCK)
	WHERE t.IdTransfer = @IdTransfer

	UPDATE MoneyGram.[Transaction] SET
		IdTransfer = @IdTransfer,
		ReferenceNumber = @ReferenceNumber,
		PartnerConfirmationNumber = @PartnerConfirmationNumber,
		PartnerName = @PartnerName,
		FreePhoneCallPIN = @FreePhoneCallPIN,
		TollFreePhoneNumber = @TollFreePhoneNumber,
		ExpectedDateOfDelivery = @ExpectedDateOfDelivery,
		TransactionDateTime = @TransactionDateTime,
		IdUserLastUpdate = @IdUser,
		DateOfLastChange = GETDATE(),
		OriginalClaimCode = @OriginalClaimCode
	WHERE IdPreTransfer = @IdPretransfer

	UPDATE Transfer SET
		ClaimCode = @ReferenceNumber
	WHERE IdTransfer = @IdTransfer

END