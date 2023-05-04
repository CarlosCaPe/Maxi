/********************************************************************
<Author>smacias</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="20/11/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetAgentsToSearch]
as
begin try
    SELECT IdAgent, AgentCode, AgentName, AgentZipcode, AgentAddress, AgentCity, AgentState, AgentPhone, a.IdAgentStatus, AgentStatus
	FROM Agent a with (nolock) join AgentStatus aStatus with (nolock)  on a.IdAgentStatus=aStatus.IdAgentStatus
end try
begin catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentsToSearch',Getdate(),@ErrorMessage);
end catch
