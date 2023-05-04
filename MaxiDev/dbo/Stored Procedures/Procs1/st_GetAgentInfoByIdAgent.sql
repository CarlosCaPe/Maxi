
CREATE procedure [dbo].[st_GetAgentInfoByIdAgent]
(
       @IdAgent int
)
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

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT        
       idowner [IdOwner],
       ' ' [Name]
      ,' '[LastName]           
      ,agentname
      ,agentAddress [Address]
      ,agentcity [City]
      ,agentstate [State]
      ,agentzipcode [Zipcode]
      ,agentphone  [Phone]
      ,' '[Cel]
      ,AgentEmail [Email]
         ,' ' AccountNumber
         ,' ' RoutingNumber                
      
  FROM dbo.agent with(nolock) 
  where idAgent = @IdAgent
