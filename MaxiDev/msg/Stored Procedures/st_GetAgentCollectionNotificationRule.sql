CREATE procedure [msg].[st_GetAgentCollectionNotificationRule]
(
    @Idagent int,
    @IdCollectionNotificationRuleType int,
    @Condition int out,
    @JSONMessage [nvarchar](max) out,
    @TEXTMessage [nvarchar](max) out,
    @ShowNotification bit OUT,
    @SendFax bit OUT
)
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
--Declaracion de variables
Declare @IdAgentClass int
Declare @IdOwner int

create table #CollectionNotification
(    
    [Condition] int,
    [JSONMessage] [nvarchar](max),
    [TEXTMessage] [nvarchar](max),
    [ShowNotification] BIT,
    [SendFax] bit
)

--Inicializacion de variables
select @IdAgentClass=IdAgentClass,@IdOwner=IdOwner from agent WITH(NOLOCK) where idagent=@Idagent

If exists (select 1 from CollectionNotificationRule with(nolock) where idagent=@Idagent and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1)
begin
    insert into #CollectionNotification
    select [Condition],[JSONMessage],[TEXTMessage],[ShowNotification],[SendFax] from CollectionNotificationRule WITH(NOLOCK) where idagent=@Idagent and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1;
end
else
begin
    if exists (select 1 from CollectionNotificationRule with(nolock) where idowner=@IdOwner and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1)
    begin
        insert into #CollectionNotification
        select [Condition],[JSONMessage],[TEXTMessage],[ShowNotification],[SendFax] from CollectionNotificationRule WITH(NOLOCK) where idowner=@IdOwner and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1;
    end
    else
    begin
        If exists (select 1 from CollectionNotificationRule with(nolock) where IdAgentClass=@IdAgentClass and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1)
        begin
            insert into #CollectionNotification
            select [Condition],[JSONMessage],[TEXTMessage],[ShowNotification],[SendFax] from CollectionNotificationRule WITH(NOLOCK) where IdAgentClass=@IdAgentClass and IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1;
        end
        else
        begin
            insert into #CollectionNotification
            select [Condition],[JSONMessage],[TEXTMessage],[ShowNotification],[SendFax] from CollectionNotificationRule WITH(NOLOCK) where IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and idstatus=1 and idagent is null and idagentclass is null and idowner is null;
        end
    end
END

select @Condition = ISNULL([Condition],0), @JSONMessage = ISNULL([JSONMessage],''), @TEXTMessage = ISNULL([TEXTMessage],''), @ShowNotification = ISNULL([ShowNotification],0), @SendFax = ISNULL([SendFax],0) from #CollectionNotification

