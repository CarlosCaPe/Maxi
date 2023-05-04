CREATE procedure [dbo].[st_ReportAging2]      
 @StartDate   DateTime,    
 @DaysFirstLapse int                                     
      
as      
Set nocount on      
      
Declare @FromDate10 DateTime   
Declare @FromDateLapse Datetime                                         
Declare @FromDate30 DateTime                                            
Declare @FromDate60 DateTime                                            
Declare @FromDate90 DateTime       
Declare @Days int  
   
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate+1)      
  
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
--Set @FromDate60= DATEADD(dd,-30,@FromDate30)     
--Set @FromDate90= DATEADD(dd,-30,@FromDate60)   
       
print  @FromDateLapse
--print  @FromDate10   
print  @FromDate30
print  @FromDate60   
print  @FromDate90
print  @StartDate

      
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
Older  money      
)      
      
Insert into #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName)      
Select IdAgent,AgentName,AgentCode,a.IdAgentstatus,agentstatus from Agent a
join agentstatus s on a.IdAgentstatus=s.IdAgentstatus
where a.IdAgentStatus!=2      
      
Declare @TempId int,@TempIdAgent int,@TempBalance money,@SumDebit1 money,@SumCredit1 money      
Declare @SumDebit2 money,@SumCredit2 money      
Declare @SumDebit3 money,@SumCredit3 money      
Declare @SumDebit4 money,@SumCredit4 money      
      
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
 DateOfMovement<@StartDate and DateOfMovement>@FromDateLapse and  TypeOfMovement <>'DEP'     
       
 Select @SumCredit1=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDateLapse and  TypeOfMovement <>'DEP'     
       
 ------- Segund0 Rango ------------------      
       
 Select @SumDebit2=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate30  and  TypeOfMovement <>'DEP'    
       
 Select @SumCredit2=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate30  and  TypeOfMovement <>'DEP'    
       
  ------- Tercero Rango ------------------      
       
 Select @SumDebit3=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate60  and  TypeOfMovement <>'DEP'    
       
 Select @SumCredit3=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate60  and  TypeOfMovement <>'DEP'    
       
  ------- Cuarto Rango ------------------      
       
 Select @SumDebit4=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Debit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate90  and  TypeOfMovement <>'DEP'    
       
 Select @SumCredit4=isnull(SUM(amount),0) from #temp2 where DebitOrCredit='Credit' and       
 DateOfMovement<@StartDate and DateOfMovement>@FromDate90  and  TypeOfMovement <>'DEP'    
       
      
       
 Update #temp set CurrentBalance=@TempBalance,      
 Last10=(@SumDebit1-@SumCredit1),      
 Last30=(@SumDebit2-@SumCredit2),      
 Last60=(@SumDebit3-@SumCredit3),      
 Last90=(@SumDebit4-@SumCredit4)      
 where id=@TempId      
         
 Drop table #temp2      
          
 Set @TempId=@TempId+1      
End      
      
      
    
Update #temp set AgentCode=REPLACE(agentcode,'-B','')  where AgentCode like '%-B'    
    
Declare @Older Money    
Set @Older=0    
    
Select AgentName,AgentCode,  idagentstatus, agentstatusname ,SUM(CurrentBalance) as CurrentBalance,SUM(Last10) as Last10,SUM(last30) as Last30,SUM(Last60) as Last60,SUM(Last90)  as Last90, @Older as Older   Into #result from #temp      
Group by AgentName, AgentCode  ,idagentstatus, agentstatusname  
order by AgentCode    
    
    
Update #result set Last10=case when Last10<CurrentBalance Then Last10 Else CurrentBalance End    
Update #result set Last30=case when Last30<CurrentBalance Then Last30 Else CurrentBalance End    
Update #result set Last60=case when Last60<CurrentBalance Then Last60 Else CurrentBalance End    
Update #result set Last90=case when Last90<CurrentBalance Then Last90 Else CurrentBalance End    
    
Update #result set Last30=Last30-Last10    
Update #result set Last60=Last60-Last30-Last10    
Update #result set Last90=Last90-Last60-Last30-Last10    
Update #result set Older=CurrentBalance-Last90-Last60-Last30-Last10    
    
    
Select AgentCode+' '+AgentName as AgentName,AgentCode, idagentstatus, agentstatusname ,Last10,Last30,Last60,Last90,Older,CurrentBalance from #result  order by AgentCode
