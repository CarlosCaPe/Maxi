
CREATE procedure [dbo].[st_TransferProcessorOld]      
as      
/**
Store Log:
2012/11/7	Aldo Romo	Changes to support new MultiHold Logic
**/
Set nocount on     
------------------------------------- validation, not running ------------------    
Declare @TimesToReportFail int    
Declare @FailCounter Int    
Declare @IsRunning bit    
Declare @Error nvarchar(max)    
    
Set @Error='Error en st_TransferProcessor'+convert(varchar(30),getdate())    
      
Select @TimesToReportFail=TimesToReportFail,    
@FailCounter=FailCounter,    
@IsRunning=IsRunning    
From ProcessorInFail  Where Id=1    
      
If  @IsRunning=1     
Begin    
 Update ProcessorInFail Set FailCounter=FailCounter+1 Where Id=1    
 If @TimesToReportFail<=@FailCounter+1    
  Begin    
   EXEC st_SendMail 'Ciclado Transfer Processor',@Error    
  End    
End    
Else    
  Update  ProcessorInFail set FailCounter=0, IsRunning =1 Where Id=1    
      
------------------------temp table -------------------------------------------      
      
Create Table #Transfer                  
(                  
IdTransfer int,              
IdStatus int                  
)       
      
------ Fill the main table for the loop -----------------------------------------------------      
Insert into #Transfer      
Select IdTransfer,IdStatus from Transfer       
Where IdStatus in (1,41)
Order by DateOfTransfer asc      
             
Declare @IdTransfer int      
Declare @IdStatus int      
Declare @Priority int      
      
-------- Main loop ---------------------------------------------------------------------------      
While exists (Select top 1 1 from #Transfer)      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@IdStatus=IdStatus from #Transfer       
       
 --- Cargo al balance de la Agencia-----------      
  If @IdStatus=1       
	Begin      
		Exec st_DebitToAgentBalance @IdTransfer      
		Exec st_SaveChangesToTransferLog @IdTransfer,1,'Transfer Charge Added to Agent Balance',0,1    
	End    

  Exec st_TransferProcessorDetailOld @IdTransfer , @IdStatus
  Delete #Transfer where IdTransfer=@IdTransfer      
End      
      
      
------------ Aviso ha terminado el store -------------------------------------------------------------------      
 Update  ProcessorInFail set FailCounter=0, IsRunning =0 Where Id=1  

