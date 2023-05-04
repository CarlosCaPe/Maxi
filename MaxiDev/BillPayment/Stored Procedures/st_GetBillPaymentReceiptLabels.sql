﻿CREATE PROCEDURE BillPayment.st_GetBillPaymentReceiptLabels
(
	@IdTransfer INT
)
AS
BEGIN
	DECLARE @ReceiptPrefix VARCHAR(200) = 'Receipt.BP.'

	DECLARE @CorporativeLenguage	INT = 1,
			@CustomerLenguage		INT = 2

	DECLARE @Labels TABLE (LabelName VARCHAR(300), CorporativeLabel VARCHAR(MAX), CustomerLabel VARCHAR(MAX))

	INSERT INTO @Labels(LabelName, CorporativeLabel, CustomerLabel)
	SELECT 
		REPLACE(lr.MessageKey, @ReceiptPrefix, '') LabelName, 
		MAX(CASE WHEN lr.IdLenguage = @CorporativeLenguage THEN lr.Message END) CorporativeLabel,
		MAX(CASE WHEN lr.IdLenguage = @CustomerLenguage THEN lr.Message END) CustomerLabel
	FROM LenguageResource lr WITH(NOLOCK)
	WHERE lr.MessageKey LIKE CONCAT(@ReceiptPrefix, '%')
	GROUP BY lr.MessageKey

	SELECT
		l.LabelName,
		CASE 
			WHEN l.CorporativeLabel IS NULL THEN l.CustomerLabel
			WHEN l.CustomerLabel IS NULL THEN l.CorporativeLabel
			ELSE CONCAT(l.CorporativeLabel, '/', l.CustomerLabel)
		END LabelValue
	FROM @Labels l
END
