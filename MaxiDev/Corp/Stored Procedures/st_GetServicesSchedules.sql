CREATE PROCEDURE Corp.st_GetServicesSchedules
	@DayOfWeek 	INT,
	@IdBank		INT /*	2.-'Southside',	3.-'Bank of Texas',	4.-'First Midwest Bank'	*/
AS
BEGIN

	
	
	IF OBJECT_ID('tempdb..#tmpServiceSchedules') IS NOT NULL
    DROP TABLE #tmpServiceSchedules


	DECLARE @BankCode NVARCHAR(128), @BankCodeNV NVARCHAR(128)
	
	SELECT @BankCode = CASE WHEN @IdBank = 2 THEN 'SOUTHSIDESEND'
							WHEN @IdBank = 3 THEN 'BANKOFTEXASSEND'
							WHEN @IdBank = 4 THEN 'FIRSTMIDWESTSEND'
							ELSE '' END,
			@BankCodeNV = CASE WHEN @IdBank = 2 THEN 'SOUTHSIDENVSEND'
							WHEN @IdBank = 3 THEN 'BANKOFTEXASNVSEND'
							WHEN @IdBank = 4 THEN 'FIRSTMIDWESTSEND'
							ELSE '' END


	SELECT @IdBank AS IdBank, S.Code, S.Time
	INTO #tmpServiceSchedules
	FROM Services.ServiceSchedules AS S WITH(NOLOCK) 
	WHERE DayOfWeek = @DayOfWeek
 		AND Code IN (@BankCode, @BankCodeNV )
 		
-- 	SELECT @IdBank AS IdBank, S.Code, S.Time
--	--INTO #tmpServiceSchedules
--	FROM Services.ServiceSchedules AS S WITH(NOLOCK) 
--	WHERE DayOfWeek = @DayOfWeek
-- 		AND Code IN (@BankCode, @BankCodeNV )
 		
 	
 	SELECT S.IdBank,
 		Times = STUFF( (SELECT DISTINCT ', ' + TIME
 						FROM #tmpServiceSchedules
 						WHERE IdBank = S.IdBank
 						FOR XML PATH('')), 1, 1, '')
 	FROM #tmpServiceSchedules S
 	GROUP BY S.IdBank
	 		
 		
-- 	SELECT t.IdTransferClosed,
--	       Statuses = STUFF( (SELECT DISTINCT ', '+StatusName 
--	                      FROM #tmpTransferHoldStatus 
--	                      WHERE IdTransferClosed = t.IdTransferClosed 
--	                      FOR XML PATH('')
--	                     ), 1, 1, ''
--	                   )
--	INTO #tmpTransferHoldStatusComma                   
--	FROM #tmpTransferHoldStatus t
--	GROUP BY t.IdTransferClosed

END
