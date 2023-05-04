Create Procedure st_FillDashboard
as

declare @BeginDate datetime
declare @EndDate datetime
declare @TmpDate datetime
declare @MonthAgoSD datetime
declare @MonthAgoED datetime
declare @id int

set @BeginDate='2004-02-01 00:00:00.000'
set @EndDate=[dbo].[RemoveTimeFromDatetime](getdate())

declare @dates table
(
    id int identity(1,1),
    BeginDate datetime,
    EndDate datetime
)

truncate table Dashboard

while (@BeginDate <@EndDate)
begin
    set @TmpDate=DATEADD(month, 1,@BeginDate)

    if @TmpDate>@EndDate 
        set @TmpDate = @EndDate

    insert into @dates
    values
    (@BeginDate,@TmpDate)

    set @BeginDate=@TmpDate
end

--delete from @dates where id!=1

while exists (select top 1 1 from @dates)
begin
    select @id=id, @MonthAgoSD=BeginDate, @MonthAgoED=EndDate from @dates order by id desc    
    
    insert into Dashboard    
    Select idagent, AgentState, SUM(NumTran) as NumTran,sum(AmountInDollars) TotalAmountInDollars, @MonthAgoSD 'Date'
	from(		
        select t.idagent, A.AgentState, SUM(1) as NumTran,sum(Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @MonthAgoSD and T.DateOfTransfer<@MonthAgoED				
		group by t.idagent, A.AgentState
			
		union all
		select t.idagent, A.AgentState, SUM(1) as NumTran,sum(Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars from TransferClosed T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @MonthAgoSD and T.DateOfTransfer<@MonthAgoED				
		group by t.idagent, A.AgentState
			
		union all
		select t.idagent, A.AgentState, SUM(1)*-1 as NumTran,(-1)*sum(Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
		left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer  
		where T.DateStatusChange>= @MonthAgoSD and T.DateStatusChange<@MonthAgoED and T.IdStatus in (22,31)				
		group by t.idagent, A.AgentState
			
		union all
		select t.idagent, A.AgentState,SUM(1)*-1 as NumTran,(-1)*sum(Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars from TransferClosed T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
		left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer  
		where T.DateStatusChange>= @MonthAgoSD and T.DateStatusChange<@MonthAgoED and T.IdStatus in (22,31)				
		group by t.idagent, A.AgentState
    ) LT
    group by idagent, AgentState
    order by AgentState,idagent

    delete from @dates where id=@id
end
