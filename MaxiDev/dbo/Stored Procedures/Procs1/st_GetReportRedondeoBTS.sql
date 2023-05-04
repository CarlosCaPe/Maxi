CREATE PROCEDURE [dbo].[st_GetReportRedondeoBTS]

@BeginDate DATETIME = NULL

AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF(@BeginDate = '')
BEGIN
	SET @BeginDate = NULL
END

		SELECT T.DateOfTransfer, 
	       T.ClaimCode, 
		   T.Folio, 
		   a.AgentCode,
		   a.AgentName, 
		   T.AmountInDollars, 
		   T.ExRate, 
		   T.AmountInMN AS Redondeado, 
		   dbo.RoundBanker( T.AmountInDollars * T.ExRate,2) AS OriginalAmount, 
		   P.PayerName, 
		   S.StatusName,
		   T.IdStatus,
		   T.IdTransfer
		   
	FROM Transfer T WITH(NOLOCK) INNER JOIN Agent A  ON (T.IdAgent = A.IdAgent)
	INNER JOIN Payer P WITH(NOLOCK) ON (T.IdPayer = P.IdPayer)
	INNER JOIN [Status] S WITH(NOLOCK) ON (S.IdStatus = T.IdStatus)
	--- temporal mente se agrega 40 pero debe ser 21
	INNER JOIN TransferDetail TD WITH(NOLOCK) ON (TD.IdStatus = 21 AND T.IdTransfer = TD.IdTransfer)
	INNER JOIN Branch B WITH(NOLOCK) ON (B.IdBranch = T.IdBranch)
	INNER JOIN City C WITH(NOLOCK) ON (C.IdCity = B.IdCity)
	INNER JOIN State St WITH(NOLOCK) ON (St.IdState = C.IdState)
	INNER JOIN Country CO WITH(NOLOCK) ON (CO.IdCountry = St.IdCountry)
	WHERE IdGateway = 4  AND T.IdPaymentType in (1,4) AND  CO.IdCountry = 11 AND  
	 T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars * T.ExRate,2) 
	 	 AND
	(
	(T.DateOfTransfer < (select  CONVERT(CHAR(10),getdate(),111)) AND T.DateOfTransfer >= @BeginDate) 
	or 
	(@BeginDate IS NULL AND (T.DateOfTransfer >= (select  CONVERT(CHAR(10),getdate()-1,111))  AND T.DateOfTransfer < (select  CONVERT(CHAR(10),getdate(),111))   ))
	)

	UNION ALL 

		SELECT T.DateOfTransfer, 
	       T.ClaimCode, 
		   T.Folio, 
		   a.AgentCode,
		   a.AgentName, 
		   T.AmountInDollars, 
		   T.ExRate, 
		   T.AmountInMN AS Redondeado, 
		   dbo.RoundBanker( T.AmountInDollars * T.ExRate,2) AS OriginalAmount, 
		   P.PayerName, 
		   S.StatusName,
		   T.IdStatus,
		   T.IdTransferClosed
		   
	FROM [dbo].[TransferClosed] T WITH(NOLOCK) INNER JOIN Agent A  ON (T.IdAgent = A.IdAgent)
	INNER JOIN Payer P WITH(NOLOCK) ON (T.IdPayer = P.IdPayer)
	INNER JOIN [Status] S WITH(NOLOCK) ON (S.IdStatus = T.IdStatus)
	--- temporal mente se agrega 40 pero debe ser 21
	INNER JOIN TransferClosedDetail TD WITH(NOLOCK) ON (TD.IdStatus = 21 AND T.IdTransferClosed = TD.IdTransferClosed)
	INNER JOIN Branch B WITH(NOLOCK) ON (B.IdBranch = T.IdBranch)
	INNER JOIN City C WITH(NOLOCK) ON (C.IdCity = B.IdCity)
	INNER JOIN State St WITH(NOLOCK) ON (St.IdState = C.IdState)
	INNER JOIN Country CO WITH(NOLOCK) ON (CO.IdCountry = St.IdCountry)
	WHERE IdGateway = 4  AND T.IdPaymentType in (1,4) AND  CO.IdCountry = 11 AND  
	 T.AmountInMN <> dbo.RoundBanker( T.AmountInDollars * T.ExRate,2) 
		 AND
	(
	(T.DateOfTransfer < (select  CONVERT(CHAR(10),getdate(),111)) AND T.DateOfTransfer >= @BeginDate) 
	or 
	(@BeginDate IS NULL AND (T.DateOfTransfer >= (select  CONVERT(CHAR(10),getdate()-1,111))  AND T.DateOfTransfer < (select  CONVERT(CHAR(10),getdate(),111))   ))
	)

	