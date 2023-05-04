CREATE procedure [dbo].[st_ReportOtherCharges]
(
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IdAgent INT = NULL
)
AS

IF @IdAgent=0 
BEGIN
    SET @IdAgent=null
END

SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
SELECT @StartDate=dbo.RemoveTimeFromDatetime(@StartDate) 

SELECT
    A.[AgentCode],
    O.[Amount],
    O.[Notes],
    O.[ChargeDate],
    U.[UserName],
    O.[DateOfLastChange],
    B.[DebitOrCredit],
	CASE WHEN O.[IsReverse] IS NULL OR O.[IsReverse] <> 1 THEN (CASE WHEN O.[IdOtherChargesMemo]=15 THEN ISNULL(O.[OtherChargesMemoNote],'') ELSE M.[Memo] END)
		ELSE ISNULL(M.[ReverseNote],'')
		END OtherChargesMemo
FROM            
    AgentOtherCharge O (NOLOCK)
    JOIN [dbo].[Agent] A (NOLOCK) ON A.[IdAgent] = O.[IdAgent] AND O.[IdAgent]=ISNULL(@IdAgent,O.[IdAgent])
    JOIN [dbo].[Users] U (NOLOCK) ON O.[EnterByIdUser] = U.[IdUser]
    JOIN [dbo].[AgentBalance] B (NOLOCK) ON O.[IDAGENT] = B.IDAGENT AND O.[IdAgentBalance] = B.[IdAgentBalance]
    JOIN [dbo].[OtherChargesMemo] M (NOLOCK) ON O.[IdOtherChargesMemo]=M.[IdOtherChargesMemo]
	WHERE 
    O.[DateOfLastChange] >= @StartDate AND O.[DateOfLastChange] < @EndDate    
GROUP BY
    A.[AgentCode],
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
	M.[ReverseNote]
ORDER BY 
    O.[DateOfLastChange]