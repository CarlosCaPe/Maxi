  
create procedure [dbo].[st_SaveBulkAgentAppLogMobile]              
@Log XML,   
@HasError bit out
as             
Set Nocount on     
set @HasError=0    
    
    
Begin Try     
  
    
 Declare @Today Datetime  
 Set @Today=GETDATE()   
 
 Declare @DocHandle int              
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Log   
   
        
 Insert into LogMobileListener   
 (  
	LogPriority,
	Severity,
	ExceptionMessage,
	LogDate,
	ClientDatetime,
	DeviceId,
	LogTag,
	StackTrace,
	ErrorLocation  
  )        
 SELECT 
	LogPriority,
	Severity,
	ExceptionMessage,
	@Today,
	ClientDatetime,
	DeviceId,
	LogTag,
	StackTrace,
	ErrorLocation      
 FROM OPENXML (@DocHandle, 'root/log',2)  WITH 
 (
	LogPriority int,
	Severity int,
	ExceptionMessage nvarchar(max),
	ClientDatetime datetime,
	DeviceId nvarchar(max),
	LogTag nvarchar(max),
	StackTrace nvarchar(max),
	ErrorLocation  nvarchar(max)     
 )                     
 EXEC sp_xml_removedocument @DocHandle              
      
   
End Try                                    
Begin Catch                                    
 Set @HasError=1                           
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveBulkAgentAppLogMobile]',Getdate(),ERROR_MESSAGE()  )    
End Catch    

