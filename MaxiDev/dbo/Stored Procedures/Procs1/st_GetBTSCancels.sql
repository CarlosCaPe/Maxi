CREATE procedure [dbo].[st_GetBTSCancels]                      
As                      
--Set Nocount on                  
Select                 
'CNLI' AS AGENT_TRANS_TYPE_CODE,                
'  ' as AGENT_CD,                
A.Claimcode as CONFIRMATION_NM,                
'RBC' as PROCESS_REASON_CD,                
Convert(varchar(1),'0') as WHOLESALE_FX,                
Convert(varchar(20),'') as FEE_AM,                 
Convert(varchar(20),'') as DISCOUNT_AM,                
Convert(varchar(3),'') as DISCOUNT_REASON_CD,                
A.Folio as Agent_ORDER_NM,                
substring(B.Agentcity,1,15)  as Agent_REGION_SD,                
substring(B.AgentName,1,15) as Agent_BRANCH_SD,                
B.AgentState as Agent_STATE_CD,                
'USA' as Agent_COUNTRY_CD,                
Convert(varchar(8),C.UserName) as Agent_USER_NAME,                
Convert(varchar(8),C.UserName) as Agent_SUP_USER_NAME,                
'1' as TERMINAL,                
Replace (convert(char(10),Getdate(),20),'-','') as AGENT_DT,                
REPLACE ( convert(char(8),Getdate(),108),':','') as AGENT_TM,                
Convert(varchar(3),'') as TYPE_CD,                
Convert(varchar(3),'') as ISSUER_CD,                
Convert(varchar(3),'') as ISSUER_STATE_CD,                
Convert(varchar(3),'') as ISSUER_COUNTRY_CD,                
Convert(varchar(20),'') as IDENTIF_NM,                
Convert(varchar(8),'') as EXPIRATION_DT                
From Transfer A                
Join Agent B on (A.IdAgent=B.IdAgent)                
Join Users C on (C.IdUser=A.EnterbyIdUser)                
Where A.IdGateway=4 and A.IdStatus=25      
    
