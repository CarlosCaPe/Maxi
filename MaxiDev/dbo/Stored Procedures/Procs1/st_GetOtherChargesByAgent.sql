CREATE procedure [dbo].[st_GetOtherChargesByAgent]
    @IdAgent int,
    @NumRecord int
AS

CREATE TABLE #OtherCharges
(
    IdOtherCharges INT IDENTITY (1,1),
    IdAgentOtherCharge INT,
    EntryDate DATETIME,
    ChargeDate DATETIME,
    Debit MONEY,
    Credit MONEY,
    notes NVARCHAR(MAX),
    OtherChargesMemo NVARCHAR(MAX),
    userlogin NVARCHAR(MAX),
    IsValidReverse BIT
)


INSERT INTO #OtherCharges
	SELECT 
		O.[IdAgentOtherCharge]
		,O.[dateoflastchange] EntryDate
		,O.[ChargeDate]
		,CASE WHEN B.[DebitOrCredit]='Debit' THEN O.[Amount] ELSE 0 END Debit
		,CASE WHEN B.[DebitOrCredit]='Credit' THEN O.[Amount] ELSE 0 END Credit
		,O.[Notes]
		,CASE WHEN O.[IsReverse] IS NULL OR O.[IsReverse] <> 1 THEN M.[Memo]
			ELSE M.[ReverseNote] END OtherChargesMemo
		--,CASE WHEN O.[IsReverse] IS NULL OR O.[IsReverse] <> 1 THEN (CASE WHEN O.[IdOtherChargesMemo]=15 THEN ISNULL(O.[OtherChargesMemoNote],'') ELSE M.[Memo] END)
		--	ELSE M.[ReverseNote] END OtherChargesMemo
		,U.[UserName]
		,CASE WHEN R.[IdReverseAgentOtherCharge] IS NULL AND M.[IsValidReverse]=1 THEN 1 ELSE 0 END IsValidReverse
	FROM [dbo].[AgentOtherCharge] O (NOLOCK)
	JOIN [dbo].[AgentBalance] B (NOLOCK) ON O.[IdAgent] = B.[IdAgent] AND O.[IdAgentBalance] = B.[IdAgentBalance]
	JOIN [dbo].[Users] U (NOLOCK) ON O.[EnterByIdUser] = U.[IdUser]
	JOIN [dbo].[OtherChargesMemo] M (NOLOCK) ON O.[IdOtherChargesMemo]=M.[IdOtherChargesMemo]
	LEFT JOIN [dbo].[ReverseAgentOtherCharge] R (NOLOCK) ON O.[IdAgentOtherCharge]=R.[IdAgentOtherCharge]
	WHERE O.[IdAgent]=@IdAgent
	ORDER BY O.[DateOfLastChange] DESC

SELECT [IdAgentOtherCharge],[EntryDate],[ChargeDate],[Debit],[Credit],[notes],[OtherChargesMemo],[userlogin],[IsValidReverse] FROM #OtherCharges WHERE [IdOtherCharges]<=@NumRecord