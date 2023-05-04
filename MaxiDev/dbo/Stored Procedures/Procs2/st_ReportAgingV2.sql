CREATE procedure [dbo].[st_ReportAgingV2]      
    @StartDate   DateTime,    
    @DaysFirstLapse int,
    @PageIndex INT = 1,
	@PageSize INT = 10,
	@filter NVARCHAR(MAX) = NULL,
	@columOrdering NVARCHAR(MAX)= NULL,
	@order NVARCHAR(MAX) = NULL,
	@PageCount INT OUTPUT                                     
      
as   
SET ARITHABORT ON
Set nocount on      
      
Declare @FromDate10 DateTime   
Declare @FromDateLapse Datetime                                         
Declare @FromDate30 DateTime                                            
Declare @FromDate60 DateTime                                            
Declare @FromDate90 DateTime       
Declare @Days int 
declare @StartDate2 datetime
set @StartDate2=dbo.RemoveTimeFromDatetime(@StartDate)
if @StartDate2 = dbo.RemoveTimeFromDatetime(GETDATE())
begin
	set @StartDate2=@StartDate2 -1	
end
--print @startDate2

   
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate+1),
       @filter=upper(isnull(@filter,'')),
       @columOrdering=upper(isnull(@columOrdering,'AGENTCODE')),
       @order=upper(isnull(@order,'ASC')),
       @PageIndex=@PageIndex-1

  
set @FromDateLapse= @StartDate-@DaysFirstLapse
Set @FromDate10= @StartDate-10   
Select @Days=DAY(@FromDate10)  
  
If  @Days>1   
 Set @Days=(@Days-1)*-1  
Else   
 Set @Days=0  
      

Set @FromDate30= DATEADD(dd,@Days,@FromDate10)     
Set @FromDate60= DATEADD(MM,-1,@FromDate30)      
Set @FromDate90= DATEADD(MM,-1,@FromDate60)       
       
    
      
Create Table #temp      
(      
id int identity(1,1),      
IdAgent int,
IdAgentstatus int,    
AgentStatusName nvarchar(max),      
AgentName nvarchar(max),      
AgentCode nvarchar(max),      
CurrentBalance money,      
Last10 money,      
Last30 money,      
Last60 money,      
Last90 money,      
Older  money,
IdAgentCurrentStatus int,
AgentCurrentStatusName nvarchar(max)      
)      


/*     antes  
Insert into #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName)      
Select IdAgent,AgentName,AgentCode,a.IdAgentstatus,agentstatus from Agent a
join agentstatus s on a.IdAgentstatus=s.IdAgentstatus
where 
    a.IdAgentStatus!=2      
--AGREGADO PARA FILTRAR DESDE LA ENTRADA
AND (agentcode like '%'+@filter+'%' or AgentName like '%'+@filter+'%')
*/

--despues

Insert into #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName,IdAgentCurrentStatus,AgentCurrentStatusName)      
Select a.IdAgent,AgentName,AgentCode,f.IdAgentstatus,s.agentstatus,s2.IdAgentStatus,s2.AgentStatus
from Agent a
join agentfinalstatushistory f on DateOfAgentStatus=@StartDate2 and a.IdAgent=f.idagent
join agentstatus s on f.IdAgentstatus=s.IdAgentstatus
join agentstatus s2 on a.IdAgentStatus = s2.IdAgentStatus
where 
    f.IdAgentStatus!=2 AND      
--AGREGADO PARA FILTRAR DESDE LA ENTRADA
(agentcode like '%'+@filter+'%' or AgentName like '%'+@filter+'%')
      
Declare @TempId int,@TempIdAgent int,@TempBalance money,@SumDebit1 money,@SumCredit1 money      
Declare @SumDebit2 money,@SumCredit2 money      
Declare @SumDebit3 money,@SumCredit3 money      
Declare @SumDebit4 money,@SumCredit4 money   
declare @FCP money = 0   
      
Set @TempId=1      
      
      
      
While exists(Select  1 from #temp  where Id=@TempId)      
Begin      
 Select @TempIdAgent=IdAgent from #temp where id=@TempId      
       
 Set @TempBalance=0       
     
 Set @TempBalance=Isnull((Select top 1 Balance from AgentBalance  where IdAgent=@TempIdAgent and DateOfMovement<@StartDate order by DateOfMovement  desc),0)    
       
 Select IdAgent,Amount,DebitOrCredit,DateOfMovement,Balance,TypeOfMovement into #temp2 from AgentBalance      
    where IdAgent=@TempIdAgent and      
 DateOfMovement<@StartDate and        
 DateOfMovement>@FromDate90      
 order by  DateOfMovement desc       
       
 ------ Primer Rango  ---------------      
 Select @SumDebit1=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDateLapse and  TypeOfMovement not in ('DEP','CH','CHRTN')     
       
 Select @SumCredit1=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDateLapse and  TypeOfMovement not in ('DEP','CH','CHRTN')     
       
 ------- Segund0 Rango ------------------      
       
 Select @SumDebit2=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate30  and  TypeOfMovement not in ('DEP','CH','CHRTN')    
       
 Select @SumCredit2=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate30  and  TypeOfMovement not in ('DEP','CH','CHRTN')    
       
  ------- Tercero Rango ------------------      
       
 Select @SumDebit3=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate60  and  TypeOfMovement not in ('DEP','CH','CHRTN')    
       
 Select @SumCredit3=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate60  and  TypeOfMovement not in ('DEP','CH','CHRTN')    
       
  ------- Cuarto Rango ------------------      
       
 Select @SumDebit4=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate90  and  TypeOfMovement not in ('DEP','CH','CHRTN')    
       
 Select @SumCredit4=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate90  and  TypeOfMovement not in ('DEP','CH','CHRTN')    

   ------- Planes de financiamiento ------------------    

set @FCP=0

select    
    top 1 @FCP=d.ActualAmountToPay
from 
    agentcollectiondetail d
join 
    AgentCollection AC on d.idagentcollection=ac.IdAgentCollection and ac.idagent=@TempIdAgent
where D.DateofLastChange<@StartDate
order by IdAgentCollectionDetail desc   

set @FCP=isnull(@FCP,0)
       
 Update #temp set CurrentBalance=@TempBalance+@FCP,      
 Last10=(@SumDebit1-@SumCredit1)+@FCP,      
 Last30=(@SumDebit2-@SumCredit2)+@FCP,      
 Last60=(@SumDebit3-@SumCredit3)+@FCP,      
 Last90=(@SumDebit4-@SumCredit4)+@FCP      
 where id=@TempId      
         
 Drop table #temp2      
          
 Set @TempId=@TempId+1      
End      
    
Update #temp set AgentCode=REPLACE(agentcode,'-B','')  where AgentCode like '%-B'    
    
Declare @Older Money    
Set @Older=0    
    
Select AgentName,AgentCode,  idagentstatus, agentstatusname,IdAgentCurrentStatus,AgentCurrentStatusName ,SUM(CurrentBalance) as CurrentBalance,SUM(Last10) as Last10,SUM(last30) as Last30,SUM(Last60) as Last60,SUM(Last90)  as Last90, @Older as Older   Into #result from #temp      
Group by AgentName, AgentCode  ,idagentstatus, agentstatusname,IdAgentCurrentStatus,AgentCurrentStatusName  
order by AgentCode    
    
Update #result set Last10=case when Last10<CurrentBalance Then Last10 Else CurrentBalance End    
Update #result set Last30=case when Last30<CurrentBalance Then Last30 Else CurrentBalance End    
Update #result set Last60=case when Last60<CurrentBalance Then Last60 Else CurrentBalance End    
Update #result set Last90=case when Last90<CurrentBalance Then Last90 Else CurrentBalance End    
    
Update #result set Last30=Last30-Last10    
Update #result set Last60=Last60-Last30-Last10    
Update #result set Last90=Last90-Last60-Last30-Last10    
Update #result set Older=CurrentBalance-Last90-Last60-Last30-Last10 


create table #output
(
    Id int IDENTITY (1,1),
    AgentName nvarchar(max),
    AgentCode nvarchar(max),
    IdAgentStatus int, 
    AgentStatusName nvarchar(max),
    Last10 money,
    Last30 money,
    Last60 money,
    Last90 money,
    Older money,
    CurrentBalance money,
	IdAgentCurrentStatus int,
	AgentCurrentStatusName nvarchar(max)   
)

;WITH cte AS
(
SELECT  
  ROW_NUMBER() OVER(
    ORDER BY 
        CASE WHEN @columOrdering = 'AGENTNAME' THEN AGENTNAME END ,      
        CASE WHEN @columOrdering = 'AGENTCODE' THEN AGENTCODE END ,      
        CASE WHEN @columOrdering = 'AGENTSTATUSNAME' THEN AGENTSTATUSNAME END ,      
        CASE WHEN @columOrdering = 'LAST10' THEN LAST10 END ,      
        CASE WHEN @columOrdering = 'LAST30' THEN LAST30 END ,      
        CASE WHEN @columOrdering = 'LAST60' THEN LAST60 END ,      
        CASE WHEN @columOrdering = 'LAST90' THEN LAST90 END ,      
        CASE WHEN @columOrdering = 'OLDER' THEN OLDER END ,      
        CASE WHEN @columOrdering = 'CURRENTBALANCE' THEN CURRENTBALANCE END,
		CASE WHEN @columOrdering = 'IDAGENTCURRENTSTATUS' THEN IDAGENTCURRENTSTATUS END,
		CASE WHEN @columOrdering = 'AGENTCURRENTSTATUSNAME' THEN AGENTCURRENTSTATUSNAME END	
   )RowNumber,
    AgentName,AgentCode, IdAgentStatus, AgentStatusName ,Last10,Last30,Last60,Last90,Older,CurrentBalance,IdAgentCurrentStatus,AgentCurrentStatusName 
from 
    #result
)
INSERT INTO #output
SELECT  AgentName,AgentCode, IdAgentStatus, AgentStatusName ,Round(Last10,2),Round(Last30,2),Round(Last60,2),Round(Last90,2),Round(Older,2),Round(CurrentBalance,2),IdAgentCurrentStatus,AgentCurrentStatusName
FROM    cte
ORDER BY
CASE WHEN @order='DESC' THEN -RowNumber ELSE RowNumber END

-- removing agents with no movements, by ARR 28/08/2014
/*
delete from #output where (IdAgentStatus=2 or IdAgentCurrentStatus=2)
and Last10=0
and Last30=0
and Last60=0
and Last90=0
and Older=0
and CurrentBalance=0
*/


SELECT @PageCount = COUNT(*) FROM #output


--SALIDA
SELECT AgentName,AgentCode, IdAgentStatus, AgentStatusName ,Last10,Last30,Last60,Last90,Older,CurrentBalance,IdAgentCurrentStatus,AgentCurrentStatusName FROM #output
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize

--Select '' AgentName,'' AgentCode,1 IdAgentStatus,'' AgentStatusName ,1.0 Last10, 1.0 Last30,1.0 Last60,1.0 Last90,1.0 Older,1.0 CurrentBalance

--select @StartDate, 
--@FromDate10    ,
-- @FromDateLapse                                          ,
-- @FromDate30                                             ,
-- @FromDate60                                             ,
-- @FromDate90    


/*
select
	sum(Last10) as Last10,
    sum(Last30) as Last30,
    sum(Last60) as Last60,
    sum(Last90) as Last90,
    sum(Older) as Older,
    sum(CurrentBalance) as CurrentBalance 
	from #result
	*/



	
select
	isnull(sum(Round(Last10, 2)),0) as Last10,
    isnull(sum(Round(Last30,2)),0) as Last30,
    isnull(sum(Round(Last60,2)),0) as Last60,
    isnull(sum(Round(Last90,2)),0) as Last90,
    isnull(sum(Round(Older,2)),0) as Older,
    isnull(sum(Round(CurrentBalance,2)),0) as CurrentBalance 
	from #result
	
	/*
	select 
	Last10 ,
    Last30 ,
    Last60 ,
    Last90 ,
    Older ,
    CurrentBalance 
	from #result

	*/