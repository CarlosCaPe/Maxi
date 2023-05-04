CREATE Procedure [dbo].[st_GetAgentACH]
    @ACHDate DATETIME,
    @IdAgentCollectType int   
AS   

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

--Delaracion de variables
Declare @DayOfPayment int    
    
--Inicializacion de variables
Select   @DayOfPayment = dbo.[GetDayOfWeek](@ACHDate)
        ,@ACHDate = dbo.RemoveTimeFromDatetime(@ACHDate)

--Obtener adeudo por agencia de acuerdo al dia que pagan y si son de tipo ACH
SELECT g.IdAgent,AgentCode,Agent,ReferenceAmount, Amount - CASE (@IdAgentCollectType) WHEN 1 then 0 else ISNULL(OtherAmount,0) end amount,note FROM
(
SELECT IdAgent,AgentCode,Agent,SUM(Amount) ReferenceAmount,SUM(Amount) Amount,'' note
from
(
Select
 A.IdAgent,
 A.AgentCode,
 AgentName Agent,
 isnull((Select top 1 Balance from AgentBalance with(nolock) where DateOfMovement<dbo.funLastPaymentDate(A.IdAgent,@ACHDate)+1 and IdAgent=A.idAgent order by DateOfMovement desc),0) as Amount 
 from Agent A with(nolock)
 where     
		(  
		    DoneOnSundayPayOn=@DayOfPayment or    
		    DoneOnMondayPayOn=@DayOfPayment or    
		    DoneOnTuesdayPayOn=@DayOfPayment or    
		    DoneOnWednesdayPayOn=@DayOfPayment or    
		    DoneOnThursdayPayOn=@DayOfPayment or    
		    DoneOnFridayPayOn=@DayOfPayment or    
		    DoneOnSaturdayPayOn=@DayOfPayment  
		)
        AND A.IdAgentStatus=1 
        AND IdAgentCollectType=@IdAgentCollectType
--UNION ALL
--SELECT 
--    c.IdAgent,a.AgentCode, a.AgentName Agent, Amount FROM dbo.CalendarCollect c
--JOIN 
--    dbo.Agent a ON c.IdAgent=a.IdAgent and A.IdAgentStatus=1  AND a.IdAgentCollectType=@IdAgentCollectType
--WHERE 
--    dbo.RemoveTimeFromDatetime(c.PayDate)=dbo.RemoveTimeFromDatetime(@ACHDate) AND c.IdAgentCollectType=@IdAgentCollectType
)T
WHERE t.Amount>0
GROUP BY
    IdAgent,AgentCode, Agent
) G
LEFT JOIN(
SELECT Idagent,SUM(Amount) OtherAmount FROM dbo.AgentDeposit with(nolock) WHERE  DepositDate>=@ACHDate AND DepositDate<@ACHDate+1 GROUP BY IdAgent
) d
    ON g.IdAgent=d.Idagent
--ORDER BY t.Agent