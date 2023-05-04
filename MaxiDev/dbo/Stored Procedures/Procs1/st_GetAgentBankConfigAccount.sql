
CREATE Procedure [dbo].[st_GetAgentBankConfigAccount]    
(     
	@IdAgent 	Int    
)    
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Get Configuración de Agent - Bank </Description>

<ChangeLog>
<log Date="11/28/2018" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/
 		 select 
		   Ab.IdConfagentbank
		  , Ab.IdAgent
			, Ab.IdBank
			, Ab.Account
			, Ab.Aba 		
			, Ab.IdUser
			, Ab.DateOfLastChange
			from 
		   dbo.AgentBankConfigAccount as Ab with (nolock) 
		  where 
		   Ab.IdAgent= @IdAgent
       and Ab.idStatus = 1
	    	

