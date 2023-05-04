CREATE procedure [dbo].[st_ReportOtherChargesV2]
(
        @StartDate datetime,
		@EndDate datetime,
        @IdAgent int,
        @IsExcel bit,
        @PageIndex INT = 1,
	    @PageSize INT = 10,    
	    @columOrdering NVARCHAR(MAX)= NULL,
	    @order NVARCHAR(MAX) = NULL,
	    @PageCount INT OUTPUT
)
AS
--DECLARE @StartDate datetime = '20161002'
--DECLARE @EndDate datetime = '20161102'
--DECLARE @IdAgent int = NULL
--DECLARE @IsExcel bit = 1
--DECLARE @PageIndex INT = 1
--DECLARE @PageSize INT = 100
--DECLARE @columOrdering NVARCHAR(MAX)= ''
--DECLARE @order NVARCHAR(MAX) = 'AGENTCODE'
--DECLARE @PageCount INT

SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
SELECT @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
SET  @PageIndex=@PageIndex-1

CREATE TABLE #result1
(
    Id INT IDENTITY (1,1),
    AgentCode NVARCHAR(MAX),
	AgentState NVARCHAR(MAX),
	ItemNumber NVARCHAR(MAX),
	Notes NVARCHAR(MAX), 
	Memo NVARCHAR(MAX),
    Amount MONEY,
	ItemName NVARCHAR(MAX),
	DateOfLastChange  DATETIME,
	UserName NVARCHAR(MAX),
    ChargeDate DATETIME,
    DebitOrCredit NVARCHAR(MAX)
)

CREATE TABLE #OUTPUT
(
    Id INT IDENTITY (1,1),
    AgentCode NVARCHAR(MAX),
	AgentState NVARCHAR(MAX),
	ItemNumber NVARCHAR(MAX),
	Memo NVARCHAR(MAX),
    Amount MONEY,
	ItemName NVARCHAR(MAX),
	DateOfLastChange  DATETIME,
	UserName NVARCHAR(MAX),
    ChargeDate DATETIME,
    DebitOrCredit NVARCHAR(MAX)    
)

	INSERT INTO #result1
        SELECT
            A.[AgentCode],
			A.AgentState,                
			' ' as ItemNumber,
            O.[Notes],
			CASE WHEN 
				O.[IsReverse] IS NULL 
				OR O.[IsReverse] <> 1 
				THEN REPLACE(M.[Memo],' ','')
				ELSE ISNULL(M.[ReverseNote],'')
				END Memo,								
			O.[Amount], 
			' ' as ItemName,
            O.[DateOfLastChange],
			U.[UserName],
			O.[ChargeDate],                
            B.[DebitOrCredit]
        FROM            
            [dbo].[AgentOtherCharge] O (NOLOCK)
            JOIN [dbo].[Agent] A (NOLOCK) ON A.[IdAgent] = O.[IdAgent] AND O.[IdAgent]=ISNULL(@IdAgent,O.[IdAgent])
            JOIN [dbo].[Users] U (NOLOCK) ON O.[EnterByIdUser] = U.[IdUser]
            JOIN [dbo].[AgentBalance] B (NOLOCK) ON O.[IdAgent] = B.[IdAgent] AND O.[IdAgentBalance] = B.[IdAgentBalance]
            JOIN [dbo].[OtherChargesMemo] M (NOLOCK) ON O.[IdOtherChargesMemo]=M.[IdOtherChargesMemo]
            JOIN [dbo].[Quickbook] Q (NOLOCK) ON M.[IdQuickbook]=Q.[IdQuickbook]
        WHERE 
            O.DateOfLastChange >= @StartDate AND O.DateOfLastChange < @EndDate
			AND o.IdOtherChargesMemo not in (29)
        GROUP BY
            A.[AgentCode],
			A.AgentState,
            O.[Amount],
            O.[Notes],
            O.[ChargeDate],
            U.[UserName],
            O.[DateOfLastChange],
            B.[DebitOrCredit],
            O.[IdOtherChargesMemo],
            O.[OtherChargesMemoNote],
            M.[Memo],
			O.[IsReverse],
			M.[ReverseNote],
            Q.[QuickbookName]
			
	UPDATE a
	SET 
	a.ItemNumber = CASE WHEN ISNUMERIC(replace(Substring(LTRIM(RTRIM(a.memo)),0,CHARINDEX(' ',LTRIM(RTRIM(a.memo)),0)),'-','')) != 0 THEN replace(Substring(LTRIM(RTRIM(a.memo)),0,CHARINDEX(' ',memo,0)),'-','') ELSE '' END,
	a.ItemName = CASE WHEN ISNUMERIC(replace(Substring(LTRIM(RTRIM(a.memo)),0,CHARINDEX(' ',LTRIM(RTRIM(a.memo)),0)),'-','')) != 0 THEN Substring(LTRIM(RTRIM(a.memo)),CHARINDEX(' ',LTRIM(RTRIM(a.memo)),0)+1, LEN(LTRIM(RTRIM(a.memo)))) ELSE memo END
	FROM #result1 a
	
	UPDATE a
	SET 
	a.ItemNumber = CASE WHEN ISNUMERIC(replace(Substring(LTRIM(RTRIM(a.Notes)),0,CHARINDEX(' ',LTRIM(RTRIM(a.Notes)),0)),'-','')) != 0 THEN replace(Substring(LTRIM(RTRIM(a.Notes)),0,CHARINDEX(' ',Notes,0)),'-','') ELSE '' END,
	a.ItemName = CASE WHEN ISNUMERIC(replace(Substring(LTRIM(RTRIM(a.Notes)),0,CHARINDEX(' ',LTRIM(RTRIM(a.Notes)),0)),'-','')) != 0 THEN Substring(LTRIM(RTRIM(a.Notes)),CHARINDEX(' ',LTRIM(RTRIM(a.Notes)),0)+1, LEN(LTRIM(RTRIM(a.Notes)))) ELSE memo END
	FROM #result1 a
	Where ItemNumber = '';
	 
	IF (@IsExcel = 1)
	BEGIN
		SELECT @PageCount = COUNT(1) FROM #result1	   
		SELECT 
			AgentCode,
			AgentState,
			ItemNumber,
			CASE WHEN Notes <> '' THEN
				CASE WHEN (ItemName + '-' + Notes) <> '-' 
					THEN ItemName + '-' + Notes
					ELSE '' END
			ELSE 
				ItemName 
			END Memo,
			Amount,
			ItemName,
			DateOfLastChange,
			UserName,
			ChargeDate,
			DebitOrCredit,
			notes
		FROM #result1
		ORDER BY agentcode,DateOfLastChange
	END
	ELSE
	BEGIN

		;WITH cte AS
		(
		SELECT  
		  ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @columOrdering = 'AGENTCODE' THEN AGENTCODE END ,      
				CASE WHEN @columOrdering = 'AMOUNT' THEN AMOUNT END ,              
				CASE WHEN @columOrdering = 'NOTES' THEN NOTES END ,      
				CASE WHEN @columOrdering = 'CHARGEDATE' THEN CHARGEDATE END ,      
				CASE WHEN @columOrdering = 'USERNAME' THEN USERNAME END ,      
				CASE WHEN @columOrdering = 'DATEOFLASTCHANGE' THEN DATEOFLASTCHANGE END ,      
				CASE WHEN @columOrdering = 'DEBITORCREDIT' THEN DEBITORCREDIT END
		   )RowNumber,			
			AgentCode,
			AgentState,
			ItemNumber,
			ItemName + ' ' + Notes Memo,
			Amount,
			ItemName,
			DateOfLastChange,
			UserName,
			ChargeDate,
			DebitOrCredit,
			notes
		FROM
			#result1
		)

		INSERT INTO #output
		SELECT AgentCode, AgentState, ItemNumber, Memo, Amount, ItemName, DateOfLastChange, UserName, ChargeDate, DebitOrCredit
		FROM cte
		ORDER BY
		CASE WHEN @order='DESC' THEN -RowNumber ELSE RowNumber END

		SELECT @PageCount = COUNT(1) FROM #output
		
		SELECT AgentCode, AgentState, ItemNumber, Memo, Amount, ItemName, DateOfLastChange, UserName, ChargeDate, DebitOrCredit
		FROM #output
		WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize
	END

	DROP TABLE #result1;
	DROP TABLE #output;