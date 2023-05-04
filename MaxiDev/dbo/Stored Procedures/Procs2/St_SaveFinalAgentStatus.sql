CREATE procedure [dbo].[St_SaveFinalAgentStatus]
as
declare @Date datetime

set @Date=[dbo].[RemoveTimeFromDatetime](getdate()-1)

insert into AgentFinalStatusHistory
(IdAgent,IdAgentStatus,DateOfAgentStatus,IdAgentCommissionPay)
select idagent,idagentstatus,@Date,IdAgentCommissionPay from agent

--select * from AgentFinalStatusHistory