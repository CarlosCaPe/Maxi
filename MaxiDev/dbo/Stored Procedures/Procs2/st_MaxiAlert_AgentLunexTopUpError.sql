CREATE PROCEDURE [dbo].[st_MaxiAlert_AgentLunexTopUpError]
AS            
BEGIN 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
	'Agencia con permiso de Lunex TopUp no se ve en "Top UP Agent Commissions" si no esta permiso de TopUP- TransferTo' NameValidation,
	'AgentId:'+ISNULL(CAST(A.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(A.AgentCode AS  VARCHAR), '')+'; CreationDate:'+convert(varchar,A.CreationDate)+'; ' MsgValidation,
	'Insert manual en AgentOtherProductInfo para idOtherProduct=9' FixDescription,
	'' Fix
from AgentProducts AP
	inner join Agent A on A.IdAgent=AP.IdAgent
	left join AgentOtherProductInfo AOP on AOP.IdAgent=AP.IdAgent and AOP.IdOtherProduct=AP.IdOtherProducts
where AP.IdGenericStatus=1 and AP.IdOtherProducts=9
	and AOP.IdAgentOtherProductInfo is null
	and A.IdAgent not in (
					select A.IdAgent
				from AgentProducts AP
					inner join Agent A on A.IdAgent=AP.IdAgent
					inner join AgentOtherProductInfo AOP on AOP.IdAgent=AP.IdAgent and AOP.IdOtherProduct=AP.IdOtherProducts
				where AP.IdGenericStatus=1 and AP.IdOtherProducts=7
		)

END




