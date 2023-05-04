CREATE PROCEDURE MoneyGram.st_SaveMoneyGramPreTransaction
(
	@IdPreTransfer						INT,
	@MgiTransactionSessionID			VARCHAR(40),
	@CustomerReceiveNumber				VARCHAR(30),
	@DisplayAccountID					VARCHAR(300),
	@CustomerServiceMessage				VARCHAR(300),
	@AccountNickname					VARCHAR(40),
	@ReadyForCommit						BIT,
	@ReceiveAgentName					VARCHAR(50),
	@ReceiveAgentAddress				VARCHAR(400),

	-- SendAmountInfo
	@SendAmount							MONEY,
	@SendCurrency						VARCHAR(10),
	@TotalSendFees						MONEY,
	@TotalDiscountAmount				MONEY,
	@TotalSendTaxes						MONEY,
	@TotalAmountToCollect				MONEY,

	-- ReceiveAmountInfo
	@ReceiveAmount						MONEY,
	@ReceiveCurrency						VARCHAR(10),
	@ValidCurrencyIndicator				BIT,
	@PayoutCurrency						VARCHAR(10),
	@TotalReceiveFees					MONEY,
	@TotalReceiveTaxes					MONEY,
	@TotalReceiveAmount					MONEY,
	@ReceiveFeesAreEstimated			BIT,
	@ReceiveTaxesAreEstimated			BIT,

	@ExchangeRateApplied				MONEY,
	@ReceiveFeeDisclosureText			BIT,
	@ReceiveTaxDisclosureText			BIT,

	@ConfirmationNumber					VARCHAR(20),
	@AdditionalFields					XML = NULL,

	@EnterByIdUser						INT
)
AS
BEGIN
	INSERT INTO MoneyGram.[Transaction]
	(
		IdPreTransfer,
		MgiTransactionSessionID,
		CustomerReceiveNumber,
		DisplayAccountID,
		CustomerServiceMessage,
		AccountNickname,
		ReadyForCommit,
		ReceiveAgentName,
		ReceiveAgentAddress,

		SendAmount,
		SendCurrency,
		TotalSendFees,
		TotalDiscountAmount,
		TotalSendTaxes,
		TotalAmountToCollect,

		ReceiveAmount,
		ReceiveCurrency,
		ValidCurrencyIndicator,
		PayoutCurrency,
		TotalReceiveFees,
		TotalReceiveTaxes,
		TotalReceiveAmount,
		ReceiveFeesAreEstimated,
		ReceiveTaxesAreEstimated,

		ExchangeRateApplied,
		ReceiveFeeDisclosureText,
		ReceiveTaxDisclosureText,

		ConfirmationNumber,

		EnterByIdUser,
		CreationDate
	)
	VALUES
	(
		@IdPreTransfer,
		@MgiTransactionSessionID,
		@CustomerReceiveNumber,
		@DisplayAccountID,
		@CustomerServiceMessage,
		@AccountNickname,
		@ReadyForCommit,
		@ReceiveAgentName,
		@ReceiveAgentAddress,

		@SendAmount,
		@SendCurrency,
		@TotalSendFees,
		@TotalDiscountAmount,
		@TotalSendTaxes,
		@TotalAmountToCollect,

		@ReceiveAmount,
		@ReceiveCurrency,
		@ValidCurrencyIndicator,
		@PayoutCurrency,
		@TotalReceiveFees,
		@TotalReceiveTaxes,
		@TotalReceiveAmount,
		@ReceiveFeesAreEstimated,
		@ReceiveTaxesAreEstimated,

		@ExchangeRateApplied,
		@ReceiveFeeDisclosureText,
		@ReceiveTaxDisclosureText,

		@ConfirmationNumber,

		@EnterByIdUser,
		GETDATE()
	)

	IF (@AdditionalFields IS NOT NULL)
	BEGIN
		DECLARE @IdMGTransaction INT = @@identity

		INSERT INTO MoneyGram.TransactionOtherFields(IdTransaction, XmlTag, [Value])
		SELECT
			@IdMGTransaction,
			t.c.value('Key[1]', 'VARCHAR(100)'),
			t.c.value('Value[1]', 'VARCHAR(200)')
		FROM @AdditionalFields.nodes('AdditionalFields/Field') t(c)
	END

	IF ISNULL(@CustomerReceiveNumber, '') <> ''
		WITH CustomerRelation AS
		(
			SELECT
				pt.IdCustomer,
				@CustomerReceiveNumber CustomerReceiveNumber
			FROM dbo.PreTransfer pt
				JOIN dbo.Customer c ON c.IdCustomer = pt.IdCustomer
			WHERE pt.IdPreTransfer = @IdPreTransfer
		)
		MERGE MoneyGram.Customer c
		USING CustomerRelation cr 
			ON cr.IdCustomer = c.IdCustomer AND cr.CustomerReceiveNumber = c.IdCustomerMoneyGram
		WHEN NOT MATCHED THEN
			INSERT (IdCustomer, IdCustomerMoneyGram, CreationDate, EnterByIdUser)
			VALUES (cr.IdCustomer, cr.CustomerReceiveNumber, GETDATE(), @EnterByIdUser);

END