
CREATE PROCEDURE [dbo].[st_GetTransactionReceiptFieldLabels]
(
	@IdTransfer INT 
)
AS
BEGIN
	
	DECLARE @CorporativeLenguage	INT = 1,
			@CustomerLenguage		INT = 2,
			@IdCountryCurrency		INT

	SELECT
		@IdCountryCurrency = t.IdCountryCurrency
	FROM Transfer t WHERE t.IdTransfer = @IdTransfer

	IF @IdCountryCurrency IS NULL
		SELECT
			@IdCountryCurrency = t.IdCountryCurrency
		FROM TransferClosed t WHERE t.IdTransferClosed = @IdTransfer 

	IF EXISTS(SELECT 1 FROM CountryCurrency cc WHERE cc.IdCountryCurrency = @IdCountryCurrency AND cc.IdCountry = 3)
		SET @CustomerLenguage = 3

	DECLARE @Labels TABLE(Id INT IDENTITY, [Key] VARCHAR(200), [Message] VARCHAR(MAX))

	INSERT INTO @Labels([Key])
	VALUES
	('PickUpLocation'),
	('Sender'),
	('ReceiveTextMessages'),
	('Recipient'),
	('TransferAmount'),
	('TransferFee'),
	('TotalAmountPaid'),
	('ExchangeRate'),
	('TotalRecipient'),
	('DateAvailable'),
	('Account'),
	('AccountTypeName'),
	('StateTax'),
	('Folio'),
	('ChangeRequest'),
	('Discount'),
	('PaymentMethod'),
	('PayeeConfirmation')

	DECLARE @I				INT = 1

	WHILE (@I <= (SELECT COUNT(1) FROM @Labels))
	BEGIN
		DECLARE @CurrentKey			VARCHAR(200) = NULL,
				@CorportativeText	VARCHAR(200) = NULL,
				@CustomerText		VARCHAR(200) = NULL,
				@LabelText			VARCHAR(200) = NULL


		SELECT 
			@CurrentKey = CONCAT('MTReceipt.', l.[Key])
		FROM @Labels l WHERE l.Id = @I

		SELECT
			@CorportativeText = lr.Message
		FROM LenguageResource lr
		WHERE lr.IdLenguage = @CorporativeLenguage
		AND lr.MessageKey = @CurrentKey

		SELECT
			@CustomerText = lr.Message
		FROM LenguageResource lr
		WHERE lr.IdLenguage = @CustomerLenguage
		AND lr.MessageKey = @CurrentKey

		IF ISNULL(@CustomerText, '') = ''
			SET @LabelText = @CorportativeText
		ELSE
			SET @LabelText = CONCAT(@CorportativeText, ' / ', @CustomerText)

		UPDATE @Labels SET
			Message = @LabelText
		WHERE Id = @I
			
		SET @I = @I + 1
	END

	SELECT
		MAX(CASE WHEN l.[Key] = 'ChangeRequest' THEN l.Message END) ChangeRequest,
		MAX(CASE WHEN l.[Key] = 'PickUpLocation' THEN l.Message END) PickUpLocation,
		MAX(CASE WHEN l.[Key] = 'Sender' THEN l.Message END) Sender,
		MAX(CASE WHEN l.[Key] = 'ReceiveTextMessages' THEN l.Message END) ReceiveTextMessages,
		MAX(CASE WHEN l.[Key] = 'Recipient' THEN l.Message END) Recipient,
		MAX(CASE WHEN l.[Key] = 'TransferAmount' THEN l.Message END) TransferAmount,
		MAX(CASE WHEN l.[Key] = 'TransferFee' THEN l.Message END) TransferFee,
		MAX(CASE WHEN l.[Key] = 'TotalAmountPaid' THEN l.Message END) TotalAmountPaid,
		MAX(CASE WHEN l.[Key] = 'ExchangeRate' THEN l.Message END) ExchangeRate,
		MAX(CASE WHEN l.[Key] = 'TotalRecipient' THEN l.Message END) TotalRecipient,
		MAX(CASE WHEN l.[Key] = 'DateAvailable' THEN l.Message END) DateAvailable,
		MAX(CASE WHEN l.[Key] = 'Account' THEN l.Message END) Account,
		MAX(CASE WHEN l.[Key] = 'AccountTypeName' THEN l.Message END) AccountTypeName,
		MAX(CASE WHEN l.[Key] = 'StateTax' THEN l.Message END) StateTax,
		MAX(CASE WHEN l.[Key] = 'Folio' THEN l.Message END) Folio,
		MAX(CASE WHEN l.[Key] = 'Discount' THEN l.Message END) Discount,
		MAX(CASE WHEN l.[Key] = 'PaymentMethod' THEN l.Message END) PaymentMethod,
		MAX(CASE WHEN l.[Key] = 'PayeeConfirmation' THEN l.Message END) PayeeConfirmation
	FROM @Labels l
END