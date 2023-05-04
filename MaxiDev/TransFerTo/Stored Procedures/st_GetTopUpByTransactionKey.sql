
CREATE PROCEDURE [TransFerTo].[st_GetTopUpByTransactionKey]
	@TransactionKey Bigint
AS
BEGIN
	SET NOCOUNT ON;

	
SELECT
	IdTransferTTo
	, LocalInfoAmount
	, LocalInfoCurrency
	, LocalInfoValue
	, pinBased
	, pinValidity
	, pinCode
	, pinIvr
	, pinSerial
	, pinValue
	, pinOption1
	, pinOption2
	, pinOption3
	, IdStatus
	, ReturnTimeStamp
	, IdTransactionTTo
	, OperatorReference
	, IdProductTransfer /*28/Jul/2016*/
FROM  TransFerTo.TransferTTo WITH(NOLOCK)
	WHERE [key] = @TransactionKey;
	

END