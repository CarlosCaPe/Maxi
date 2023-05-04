CREATE procedure [dbo].[st_GetAgentApplicationsV2]
(
    @IdUserSeller int = null,
    @StatusesPreselected XML
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

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

select ap.IdAgentApplication Id, ap.AgentCode, ap.AgentName, ap.IdAgentApplicationStatus IdStatus, ap.DateOfCreation, ap.DateOfLastChange, isnull(ua.HasNewImg, 0) HasNewImg
from agentapplications ap with(nolock)
left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
where DateOfCreation >= DATEADD(day, -7, GETDATE()) and IdUserSeller = isnull(@IdUserSeller, IdUserSeller) and IdAgentApplicationStatus in (select id from @tStatus) order by DateOfLastChange desc

select ap.IdAgentApplication Id, ap.AgentCode, ap.AgentName, ap.IdAgentApplicationStatus IdStatus, ap.DateOfCreation, ap.DateOfLastChange, isnull(ua.HasNewImg, 0) HasNewImg
from agentapplications ap with(nolock)
left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
where DateOfCreation >= DATEADD(day, -14, GETDATE()) AND DateOfCreation < DATEADD(day, -7, GETDATE()) and IdUserSeller=isnull(@IdUserSeller,IdUserSeller) and IdAgentApplicationStatus in (select id from @tStatus) order by DateOfLastChange desc

select ap.IdAgentApplication Id, ap.AgentCode, ap.AgentName, ap.IdAgentApplicationStatus IdStatus, ap.DateOfCreation, ap.DateOfLastChange, isnull(ua.HasNewImg, 0) HasNewImg
from agentapplications ap with(nolock)
left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
 where DateOfCreation < DATEADD(day, -14, GETDATE()) and IdUserSeller=isnull(@IdUserSeller,IdUserSeller) and IdAgentApplicationStatus in (select id from @tStatus) order by DateOfLastChange desc