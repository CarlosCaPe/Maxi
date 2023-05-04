CREATE PROCEDURE [dbo].[st_MaxiAlertD_AgentBalanceSkips]
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
		FROM agentbalance bl			
		WHERE DateOfMovement >= @BeginDate 
			

		SELECT
			   'Salto en balance'  NameValidation, 
			    'AgentId:'+ISNULL(CAST(ag.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(ag.AgentCode AS  VARCHAR), '')+ '; IdAgentBalance:'+ISNULL(CAST(c1.IdAgentBalance AS  VARCHAR), '') 
					+ '; Calculado:'+ISNULL(CAST( (c2.Balance + (c1.DebitAmount - c1.CreditAmount) ) AS  VARCHAR), '') + '; Registrado:'+ISNULL(CAST( c1.Balance AS  VARCHAR), '') 	
					+ '; DateOfMovement:'+ISNULL(CAST( c1.DateOfMovement AS  VARCHAR), '') 	MsgValidation,
				'Verificacion manual' FixDescription,
				'' Fix	
		  from #cteData c1
		 INNER JOIN #cteData c2 ON c1.IdAgent = c2.IdAgent AND c1.rw = c2.rw-1
		 INNER JOIN Agent ag ON c1.IdAgent = ag.IdAgent
		 WHERE (c2.Balance + (c1.DebitAmount - c1.CreditAmount) ) != c1.Balance  
			and c1.IdAgentBalance not in(16057404,16057405,16057951)--AgentCode:2848-TX; Acomodo por fecha
			and c1.IdAgentBalance not in(16085879,16085882,16085980)--AgentCode:3128-FL; Acomodo por fecha
			and c1.IdAgentBalance not in(16636971,16636973,16636991)--AgentCode:2657-GA; Acomodo por fecha
	 	
		 order by c1.IdAgentBalance


END


