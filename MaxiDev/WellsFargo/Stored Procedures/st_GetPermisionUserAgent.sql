--drop procedure [WellsFargo].stGetPermisionUserAgent

CREATE procedure [WellsFargo].st_GetPermisionUserAgent
(
    @IdAgent int,
    @IdUser int
)
as
declare @AgentP bit
declare @AgentPNOW bit
declare @UserP bit
declare @OptionUserP bit

select @UserP=1 from [WellsFargo].WFPIN where enterbyiduser=@IdUser and idgenericstatus=1

select @AgentP=usepin,@AgentPNOW=UsePayNow from agent where idagent=@IdAgent --and usepin=1

select @OptionUserP=1 from optionusers where  iduser=@IdUser and idoption=212 and action like '%P%'

select isnull(@UserP,0) UserP,isnull(@AgentP,0) AgentP,isnull(@OptionUserP,0) OptionUserP, isnull(@AgentPNOW,0) AgentPayNow