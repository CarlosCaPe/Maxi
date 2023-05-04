create procedure [dbo].[st_GetCollectByCommissionMoneyRetain]

as
Set nocount on 
declare 
        @ApplyDate datetime,
        @BeginDate datetime,
        @EndDate datetime,
        @IdAgent int,
        @agentcommission money,
        @IdUser int ,
        @HasError bit,
        @Message varchar(max)


--select DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) --First day of previous month
--select DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) --Last Day of previous month

set @BeginDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
set @ApplyDate = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)
set @EndDate   =  @ApplyDate +1
select @IdUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))


create table #AgentComm
(
    IdAgent int,
    agentcommission money
)

insert into #AgentComm
select t.idagent,sum(agentcommission)
from
(
    --select idagent,agentcommission from transfer where DateOfTransfer>= @BeginDate and DateOfTransfer <= @EndDate

	--union all 
    
    --select idagent,agentcommission from transferclosed where DateOfTransfer>= @BeginDate and DateOfTransfer <= @EndDate

    select idagent,case when DebitOrCredit='Debit' then commission else commission*(-1) end agentcommission from agentbalance where DateOfMovement>= @BeginDate and DateOfMovement <= @EndDate

    union all
    
    select idagent,commission*(-1) agentcommission from AgentCommisionCollection where DateOfCollection>= @BeginDate and DateOfCollection <= @EndDate
) t
join agent a on a.idagent=t.idagent and retainmoneycommission=1 and IdAgentPaymentSchema=1
where agentcommission>0
group by t.idagent


While exists (Select top 1 1 from #AgentComm)      
Begin      
  Select top 1 @IdAgent=IdAgent,@agentcommission=agentcommission from #AgentComm              

  if exists (select  top 1 1 from AgentCommisionCollection where idagent=@IdAgent and dbo.RemoveTimeFromDatetime(dateofcollection)=@ApplyDate and IdCommisionCollectionConcept=3) 
        begin
            Delete #AgentComm where IdAgent=@IdAgent
            continue;
        end

   exec [dbo].[st_SaveDeposit] 
            1,
            @IdAgent,
            'Commission''s Money Retain',
            @agentcommission,
            @ApplyDate,
            'By Commission''s Money Retain',
            @IdUser,
            3,
            @HasError out,
            @Message out
        --Insertar registro en pagos
        insert into AgentCommisionCollection
        (IdAgent,Commission,DateOfCollection,EnterByIdUser,Note,IdCommisionCollectionConcept)
        values
        (@IdAgent,@agentcommission,@ApplyDate,@IdUser,'By Commission''s Money Retain',3)
 
  Delete #AgentComm where IdAgent=@IdAgent
End