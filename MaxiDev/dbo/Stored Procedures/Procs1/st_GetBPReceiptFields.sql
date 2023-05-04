CREATE PROCEDURE [dbo].[st_GetBPReceiptFields]
(
	@IdProductTransfer	BIGINT,
	@IsInternacional	INT
)
AS
BEGIN
	
	DECLARE @CorporativeLenguage	INT = 1,
			@CustomerLenguage		INT = 2,
			@Prefix					VARCHAR(200) = 'BPReceipt',
			@IdAgent				INT,
			@AgentState				VARCHAR(20)


	IF @IsInternacional = 1
		SELECT @IdAgent = t.IdAgent FROM Regalii.TransferR t WHERE t.IdTransferR = @IdProductTransfer
	ELSE
		SELECT @IdAgent = t.IdAgent FROM BillPayment.TransferR t WHERE t.IdTransferR = @IdProductTransfer
		
	SELECT @AgentState = a.AgentState FROM Agent a WHERE a.IdAgent = @IdAgent

	--IF @IsInternacional = 1
	--	IF EXISTS(SELECT 1 FROM Regalii.TransferR t WHERE t.IdTransferR = @IdProductTransfer AND t.IdCountry = 3)
	--		SET @CustomerLenguage = 3
	--ELSE
	--	IF EXISTS(SELECT 1 FROM BillPayment.TransferR t WHERE t.IdTransferR = @IdProductTransfer AND t.IdCountry = 3)
	--		SET @CustomerLenguage = 3

	DECLARE @Labels TABLE(Id INT IDENTITY, [Key] VARCHAR(200), [Message] VARCHAR(MAX))

	INSERT INTO @Labels([Key])
	VALUES
	('Folio'),
	('BillerInformation'),
	('Tracking'),
	('Customer'),
	('ReceiveTextMessages'),
	('AmountRequested'),
	('TransferFee'),
	('TotalAmountPaid'),
	('TotalBiller'),
	('Account'),
	('DateAvailable'),
	('ExRate'),
	('TotalBillerMN')


	DECLARE @I				INT = 1

	WHILE (@I <= (SELECT COUNT(1) FROM @Labels))
	BEGIN
		DECLARE @CurrentKey			VARCHAR(200) = NULL,
				@CorportativeText	VARCHAR(200) = NULL,
				@CustomerText		VARCHAR(200) = NULL,
				@LabelText			VARCHAR(200) = NULL


		SELECT 
			@CurrentKey = l.[Key] 
		FROM @Labels l WHERE l.Id = @I


		IF @IsInternacional = 1 
		BEGIN
			SELECT
				@CorportativeText = lr.Message
			FROM LenguageResource lr
			WHERE lr.IdLenguage = @CorporativeLenguage
			AND lr.MessageKey = CONCAT(@Prefix, '.', 'Internacional', '.', @CurrentKey)

			SELECT
				@CustomerText = lr.Message
			FROM LenguageResource lr
			WHERE lr.IdLenguage = @CustomerLenguage
			AND lr.MessageKey = CONCAT(@Prefix, '.', 'Internacional', '.', @CurrentKey)
		END

		IF ISNULL(@CorportativeText, '') = ''
			SELECT
				@CorportativeText = lr.Message
			FROM LenguageResource lr
			WHERE lr.IdLenguage = @CorporativeLenguage
			AND lr.MessageKey = CONCAT(@Prefix, '.', @CurrentKey)
		
		IF ISNULL(@CustomerText, '') = ''
			SELECT
				@CustomerText = lr.Message
			FROM LenguageResource lr
			WHERE lr.IdLenguage = @CustomerLenguage
			AND lr.MessageKey = CONCAT(@Prefix, '.', @CurrentKey)

		IF (@IsInternacional = 0 AND @CustomerLenguage = 2 AND @CurrentKey = 'AmountRequested')
		BEGIN
			SET @CorportativeText = IIF(@AgentState = 'CA', 'Amount requested', 'Amount Requested')
			SET @CustomerText = IIF(@AgentState = 'CA', 'Quantidade solicitada', 'Quantidade Solicitada')
		END

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
		MAX(CASE WHEN l.[Key] = 'Folio' THEN l.Message END) Folio,
		MAX(CASE WHEN l.[Key] = 'BillerInformation' THEN l.Message END) BillerInformation,
		MAX(CASE WHEN l.[Key] = 'Tracking' THEN l.Message END) Tracking,
		MAX(CASE WHEN l.[Key] = 'Customer' THEN l.Message END) Customer,
		MAX(CASE WHEN l.[Key] = 'ReceiveTextMessages' THEN l.Message END) ReceiveTextMessages,
		MAX(CASE WHEN l.[Key] = 'AmountRequested' THEN l.Message END) AmountRequested,
		MAX(CASE WHEN l.[Key] = 'TransferFee' THEN l.Message END) TransferFee,
		MAX(CASE WHEN l.[Key] = 'TotalAmountPaid' THEN l.Message END) TotalAmountPaid,
		MAX(CASE WHEN l.[Key] = 'TotalBiller' THEN l.Message END) TotalBiller,
		MAX(CASE WHEN l.[Key] = 'Account' THEN l.Message END) Account,
		MAX(CASE WHEN l.[Key] = 'DateAvailable' THEN l.Message END) DateAvailable,
		MAX(CASE WHEN l.[Key] = 'ExRate' THEN l.Message END) ExRate,
		MAX(CASE WHEN l.[Key] = 'TotalBillerMN' THEN l.Message END) TotalBillerMN
	FROM @Labels l

END
