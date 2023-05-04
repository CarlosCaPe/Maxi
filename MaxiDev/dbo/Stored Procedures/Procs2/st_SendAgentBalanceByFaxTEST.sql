CREATE Procedure [dbo].[st_SendAgentBalanceByFaxTEST]      
AS      
Set nocount on      
Begin Try      
      
Declare @Today int,@DateForReport datetime,@DateStr varchar(12),@MonthStr varchar(2),@DayStr varchar(2),@YearStr varchar(4)      
Select @Today= datepart(dw,getdate())   
Set @Today=@Today-1  
  
If  @Today=0  
 Set @Today=7 
 
 Set @Today=1 
   
Select @DateForReport=dbo.RemoveTimeFromDatetime(GETDATE()-1)      
      
Set @MonthStr=Convert(varchar,DATEPART(MONTH,@DateForReport))      
If LEN(@MonthStr)=1       
 Set @MonthStr='0'+@MonthStr      
       
Set @DayStr=Convert(varchar,DATEPART(DAY,@DateForReport))      
If LEN(@DayStr)=1      
 Set @DayStr='0'+@DayStr      
       
Set @YearStr=Convert(varchar,DATEPART(YEAR,@DateForReport))       
Set @DateStr=@MonthStr+'-'+@DayStr+'-'+@YearStr      
      
      
Select A.IdAgent,      
'<Parameters><Parameter name="IdAgent" value="'+CONVERT(Varchar,A.IdAgent)+'" /><Parameter name="DateFrom" value="'+@DateStr+'" /><Parameter name="DateTo" value="'+@DateStr+'" /></Parameters>' as Parameters,      
'AgentBalance' as ReportName,      
3 as Priority,      
1 as IdQueueFaxStatus      
From Agent A      
Join AgentCurrentBalance B on (A.IdAgent=B.IdAgent)      
Where      
(       
DoneOnSundayPayOn=@Today or      
DoneOnMondayPayOn=@Today or      
DoneOnTuesdayPayOn=@Today or      
DoneOnWednesdayPayOn=@Today or      
DoneOnThursdayPayOn=@Today or      
DoneOnFridayPayOn=@Today or      
DoneOnSaturdayPayOn=@Today      
)      
And       
(A.IdAgentStatus=1 or A.IdAgentStatus=3 or A.IdAgentStatus=4)       
And      
(B.Balance>0)    
And A.IdAgentCommunication in (2,3)     
      
End try        
Begin Catch        
  Declare @ErrorMessage nvarchar(max)                 
  Select @ErrorMessage=ERROR_MESSAGE()                
  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SendAgentBalanceByFax',Getdate(),@ErrorMessage)         
End catch 

