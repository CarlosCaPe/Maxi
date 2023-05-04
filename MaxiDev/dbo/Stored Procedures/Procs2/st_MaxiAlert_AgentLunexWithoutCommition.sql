CREATE PROCEDURE [dbo].[st_MaxiAlert_AgentLunexWithoutCommition]
AS            
BEGIN 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		SELECT 
		       'Agencia con permiso de Lunex sin comisiones' NameValidation,
			   'AgentId:'+ISNULL(CAST(cte.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(cte.AgentCode AS  VARCHAR), '')+'; AgentStatus:'+cte.AgentStatus+'; ' MsgValidation,
			   'Asignar en corporativo, ver log para detalle' FixDescription,
			   'select * from [AgentOtherProductInfoLog] where idAgent='+ ISNULL(CAST(cte.idAgent AS VARCHAR), '') Fix
		  FROM (			    
				SELECT DISTINCT A.idAgent, A.AgentCode, ast.AgentStatus, 
					   AP.IdGenericStatus, IdCommissionByOtherProducts
				  FROM [AgentProducts] AP
				 INNER JOIN Agent A on A.IdAgent=Ap.IdAgent  
				 INNER JOIN OtherProducts OP on OP.IdOtherProducts=AP.IdOtherProducts
				  LEFT JOIN [AgentOtherProductInfo] OPI on OPI.IdOtherProduct=Op.IdOtherProducts and AP.IdAgent=OPI.IdAgent
				 INNER JOIN AgentStatus ast on ast.IdAgentStatus = A.IdAgentStatus
				 WHERE OP.IdOtherProducts in (10,11,13)   
				   AND IdCommissionByOtherProducts is null 
				   AND AP.IdGenericStatus = 1
				   AND A.IdAgentStatus NOT IN (2,5,6)
		   ) cte
END






