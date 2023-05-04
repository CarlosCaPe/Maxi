CREATE PROCEDURE Corp.st_BillPaymentsInOrigin_SearchBillPayment
	@Folio	INT
AS
BEGIN
	
	IF (EXISTS(SELECT 1 FROM BillPayment.TransferR R WHERE R.IdProductTransfer = @Folio))
	BEGIN
	
		--SELECT 'Es Fidelity/Fiserv'
		SELECT R.IdProductTransfer, A.AgentCode, A.AgentName, R.DateOfCreation AS 'DateOfTransfer', S.StatusName, P.ProviderName
		FROM BillPayment.TransferR R WITH(NOLOCK)
		INNER JOIN Operation.ProductTransfer PT WITH(NOLOCK) ON PT.IdProductTransfer = R.IdProductTransfer
		INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent = R.IdAgent 
		INNER JOIN Status S WITH(NOLOCK) ON S.IdStatus = R.IdStatus
		LEFT JOIN Providers P WITH(NOLOCK) ON P.IdProvider = PT.IdProvider
		WHERE R.IdProductTransfer = @Folio
			AND R.IdStatus = 1
	
	END
	ELSE IF (EXISTS(SELECT 1 FROM Regalii.TransferR R WHERE R.IdProductTransfer = @Folio))
	BEGIN
	
		--SELECT 'Es Regalii'
		SELECT R.IdProductTransfer, A.AgentCode, A.AgentName, R.DateOfCreation AS 'DateOfTransfer', PT.DateOfStatusChange AS 'DateStatusChange', S.StatusName, P.ProviderName
		FROM Regalii.TransferR R WITH(NOLOCK)
		INNER JOIN Operation.ProductTransfer PT WITH(NOLOCK) ON PT.IdProductTransfer = R.IdProductTransfer
		INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent = R.IdAgent 
		INNER JOIN Status S WITH(NOLOCK) ON S.IdStatus = R.IdStatus
		LEFT JOIN Providers P WITH(NOLOCK) ON P.IdProvider = PT.IdProvider
		WHERE R.IdProductTransfer = @Folio
			AND R.IdStatus = 1
		
	END

END