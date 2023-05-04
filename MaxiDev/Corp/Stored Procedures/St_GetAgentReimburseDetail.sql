CREATE PROCEDURE [Corp].[St_GetAgentReimburseDetail]
       @Idagent Int
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

/*
  Historico:
 
 Cambio Developer Fecha  		Nota 
  >1    Jmoreno   21042017  Creación 

 Ejemplo: 
 
 execute St_GetAgentReimburseDetail
  @IdAgent =1277
  
  
*/

		select 
		
		  Config.Goal
		 , Config.DateOfLastChange
		 , Config.StatusActive
		 , [UserName] =  
		 					 		(select 
		 					 		  usr.UserName
		 					 		 from 
		 					 		  Users usr with(nolock)
		 					 		 where
		 					 		   usr.IdUser =  Config.UserChange
		 					 		)
		from
		 AgentReimburseConfig as Config with(nolock)
		where 
		  IdAgent = @IdAgent
		  order by Config.DateOfLastChange desc 

