CREATE PROCEDURE  [Corp].[st_GetOtherChargesByDateAgentMonitor] 
(@from datetime
,@to datetime
,@idAgent int
)
	as
BEGIN

	SET NOCOUNT ON;

SELECT 
	     AOC.[DateOfLastChange]
	    ,AOC.[Notes]
	    ,AOC.[ChargeDate]
		, Case 
         when AB.DebitOrCredit='Credit' Then AOC.Amount else '' end 
         as Credit,
		 Case 
        when AB.DebitOrCredit='Debit' Then AOC.Amount else '' end 
		as Debit
		,AOC.[IdAgentOtherCharge]
		,U.UserName
		,AOC.[IdOtherChargesMemo]
		,Case 
        when AOC.IdOtherChargesMemo = 15 Then AOC.OtherChargesMemoNote else OCM.Memo end 
		as MemoType


  FROM [dbo].[AgentOtherCharge] AOC with (nolock)
  INNER JOIN  dbo.AgentBalance AB with (nolock) ON AB.IdAgentBalance=AOC.IdAgentBalance
  INNER JOIN dbo.Users U with (nolock) ON  U.IdUser= AOC.EnterByIdUser
  INNER JOIN dbo.OtherChargesMemo OCM with (nolock) ON OCM.IdOtherChargesMemo= AOC.IdOtherChargesMemo
  WHERE AOC.DateOfLastChange<@to
  AND AOC.DateOfLastChange> @from
  AND AOC.IdAgent= @idAgent


END
