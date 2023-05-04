CREATE Procedure [dbo].[st_SendAgentBalanceByFax]    
AS    
Set nocount on    
Begin Try    
    
Declare @Today int,@DateStr varchar(12)   
DECLARE @SystemUser INT
set @Today= dbo.GetToday() 
set @DateStr=dbo.GetDateTo_SendAgentBalanceByFax() 
set @SystemUser = CONVERT(INT,dbo.GetGlobalAttributeByName('SystemUserID')) 
    
Insert into QueueFaxes(IdAgent,[Parameters],[ReportName],[Priority],IdQueueFaxStatus,EnterByIdUser)      
Select A.IdAgent,    
'<Parameters><Parameter name="IdAgent" value="'+CONVERT(Varchar,A.IdAgent)+'" /><Parameter name="DateFrom" value="'+dbo.GetDateFrom_SendAgentBalanceByFax(A.IdAgent)+'" /><Parameter name="DateTo" value="'+@DateStr+'" /><Parameter name="QR_Base64_Image" value="'+[dbo].[GetGlobalAttributeByName]('QRHandler')+'?id='+[dbo].[GetGlobalAttributeByName]('QRAgentPrefix')+convert(varchar,a.idagent)+'"></Parameter></Parameters>' as Parameters,    
'AgentBalance' as ReportName,    
3 as Priority,    
1 as IdQueueFaxStatus ,
@SystemUser   
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
(A.IdAgentStatus=1 or A.IdAgentStatus=3 or A.IdAgentStatus=4 or A.IdAgentStatus=7)     
And    
(B.Balance>0)  
And A.IdAgentCommunication in (2,3)   
    
End try      
Begin Catch      
  Declare @ErrorMessage nvarchar(max)               
  Select @ErrorMessage=ERROR_MESSAGE()              
  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SendAgentBalanceByFax',Getdate(),@ErrorMessage)       
End catch