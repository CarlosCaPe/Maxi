/********************************************************************
<Author> Unkwon </Author>
<app>Maxi Mobile</app>
<Description>Obtiene las agent application por id seller</Description>

<ChangeLog>
<log Date="18/09/2018" Author="azavala">Cambio de ordenamiento AgentCode -> IdAgentApplication </log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_GetAgentApplications]
(
    @IdUserSeller int = null,
    @StatusesPreselected XML
)
as
/*
set @StatusesPreselected=
'
<statuses>
    <status id="18"></status>
    <status id="7"></status> 
</statuses>
'
*/

Declare @tStatus table    
      (    
       id int    
      )    
    
Declare @DocHandle int    
Declare @hasStatus bit    

EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected      
    
insert into @tStatus(id)     
select id    
FROM OPENXML (@DocHandle, '/statuses/status',1)     
WITH (id int)   

EXEC sp_xml_removedocument @DocHandle   

select IdAgentApplication Id, AgentCode, AgentName, IdAgentApplicationStatus IdStatus from agentapplications with(nolock) where IdUserSeller=isnull(@IdUserSeller,IdUserSeller) and IdAgentApplicationStatus in (select id from @tStatus) order by IdAgentApplication