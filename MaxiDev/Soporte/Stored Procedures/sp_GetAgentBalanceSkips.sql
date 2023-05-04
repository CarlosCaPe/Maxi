
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <24 de julio de 2017>
-- Description:	<Procedimiento almacenado que identifica descuadres en balance de agente, identificados del día anterior.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_GetAgentBalanceSkips]
@BeginDate dateTime=null
AS            
BEGIN 

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


		SELECT IdAgentBalance, IdAgent, DateOfMovement, Balance,
			   CASE WHEN DebitOrCredit = 'Debit'  THEN Amount ELSE 0	END DebitAmount,
			   CASE WHEN DebitOrCredit = 'Credit' THEN Amount ELSE 0	END CreditAmount,				 
			ROW_NUMBER()  OVER (PARTITION BY IdAgent ORDER BY IdAgentBalance desc) rw
			INTO #cteData  
		FROM agentbalance bl with (nolock,Index(ix2_agentbalance))
		WHERE DateOfMovement >= @BeginDate 
			
		
		SELECT
			   ag.idAgent as IdAgent,ag.AgentCode as AgentCode,c1.IdAgentBalance as IdAgentBalance,
			   c2.Balance + (c1.DebitAmount - c1.CreditAmount) as Calculado,c1.Balance as Registrado,c1.DateOfMovement as DateOfMovement
		 from #cteData c1
		 INNER JOIN #cteData c2 ON c1.IdAgent = c2.IdAgent AND c1.rw = c2.rw-1
		 INNER JOIN Agent ag ON c1.IdAgent = ag.IdAgent
		 WHERE (c2.Balance + (c1.DebitAmount - c1.CreditAmount) ) != c1.Balance
			and c1.IdAgentBalance not in(16057404,16057405,16057951)--AgentCode:2848-TX; Acomodo por fecha
			and c1.IdAgentBalance not in(16085879,16085882,16085980)--AgentCode:3128-FL; Acomodo por fecha
			and c1.IdAgentBalance not in(16636971,16636973,16636991)--AgentCode:2657-GA; Acomodo por fecha  
	 	 --order by c1.IdAgentBalance
		 order by c1.IdAgent


END


