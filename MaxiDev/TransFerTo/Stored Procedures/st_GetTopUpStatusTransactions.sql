
CREATE PROCEDURE [TransFerTo].[st_GetTopUpStatusTransactions]
@IdStatus INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @LastMonth INT = 2;

IF @IdStatus = 0 SET @IdStatus = 21

 --Recharged = 30
 --Pending = 21
 --Cancelled = 22

	SELECT
		IdTransferTTo,
		IdStatus,
		ReturnTimeStamp,
		IdTransactionTTo,
		OperatorReference,
		--Request,
		[key],
		cast(Request as xml).value('(/xml//md5/node())[1]', 'nvarchar(max)') as [Md5],
		IdProductTransfer
	FROM TransFerTo.TransferTTo WITH(NOLOCK)
		WHERE 
				IdStatus = @IdStatus
			AND 
				DATEDIFF(MONTH, ReturnTimeStamp, GETDATE()) < @LastMonth
			ORDER BY IdTransferTTo ASC;
			 
END