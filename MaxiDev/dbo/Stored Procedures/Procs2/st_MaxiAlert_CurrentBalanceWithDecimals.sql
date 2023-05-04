 CREATE PROCEDURE [dbo].[st_MaxiAlert_CurrentBalanceWithDecimals]
AS            
BEGIN 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		  SELECT 'Agencia con decimales en balance' NameValidation, 
				'AgentId:'+ISNULL(CAST(cte.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(cte.AgentCode AS  VARCHAR), '')+'; AgentStatus:'+cte.AgentStatus+'; Decimales:'+ISNULL(convert(varchar,cte.decimals,2), '') MsgValidation,				 
				 'Executar script' FixDescription,
				 cTe.Qry Fix
          FROM (
		  SELECT  A.IdAgent, A.AgentCode, A.AgentName, ASu.AgentStatus , AB.Balance - ROUND(AB.balance,2,2) decimals
				  , 'DECLARE @HasError bit, @Message nvarchar(max), @currentDate datetime=getDate(); '
				  + 'exec [dbo].[st_SaveOtherCharge] 1, '+convert(varchar,A.idAgent)+','
				  + convert(varchar,case when AB.Balance - ROUND(AB.balance,2,2)>0 then  AB.Balance - ROUND(AB.balance,2,2) else -1*( AB.Balance - ROUND(AB.balance,2,2)) end,2)+','
				  + convert(varchar,case when AB.Balance - ROUND(AB.balance,2,2)>0 then  0 else 1 end)+','
				  + '@currentDate,''Ajuste por Sistema'','''',37,@HasError OUTPUT,@Message OUTPUT,15, ''Ajuste por Sistema'',0,0; '
				  + 'select @HasError HasError, @Message Message'+ CHAR(13)+CHAR(10) 
				  + 'GO'+ CHAR(13)+CHAR(10) Qry
				  
			 FROM AgentCurrentBalance AB 
			INNER JOIN Agent A on A.IdAgent =AB.IdAgent
			INNER JOIN AgentStatus ASu on Asu.IdAgentStatus=A.IdAgentStatus
			WHERE AB.Balance != ROUND(AB.balance,2,2) and A.IdAgentStatus in (1,4,3,7)
				 ) cTe
            ORDER BY AgentCode

END




