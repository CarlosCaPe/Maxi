
CREATE procedure [dbo].[st_TransferProcessor]      
as      
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ;</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
------------------------------------- validation, not running ------------------    
Declare @TimesToReportFail int    
Declare @FailCounter Int    
Declare @IsRunning bit    
Declare @Error nvarchar(max)    
    
Set @Error='Error en st_TransferProcessor'+convert(varchar(30),getdate())    
      
Select @TimesToReportFail=TimesToReportFail,    
@FailCounter=FailCounter,    
@IsRunning=IsRunning    
From ProcessorInFail with(nolock)  Where Id=1    
      
If  @IsRunning=1     
Begin    
 Update ProcessorInFail Set FailCounter=FailCounter+1 Where Id=1;    
 If @TimesToReportFail<=@FailCounter+1    
  Begin    
   EXEC st_SendMail 'Ciclado Transfer Processor',@Error;    
  End    
End    
Else    
  Update  ProcessorInFail set FailCounter=0, IsRunning =1 Where Id=1;    
      
------------------------temp table -------------------------------------------      
      
Create Table #Transfer                  
(                  
    IdTransfer int,
    IdStatus int
);       

------ Fill the main table for the loop -----------------------------------------------------      
Insert into #Transfer      
Select IdTransfer,IdStatus from [Transfer] with(nolock)
Where IdStatus in (41)
Order by DateOfTransfer asc;      

Declare @IdTransfer int      
Declare @IdStatus int      
Declare @Priority int      

-------- Main loop ---------------------------------------------------------------------------      
While exists (Select 1 from #Transfer)
Begin
  Select top 1 @IdTransfer=IdTransfer,@IdStatus=IdStatus from #Transfer;
  Exec st_TransferProcessorDetail @IdTransfer , @IdStatus;
  Delete #Transfer where IdTransfer=@IdTransfer;
End


------------ Aviso ha terminado el store -------------------------------------------------------------------      
 Update  ProcessorInFail set FailCounter=0, IsRunning =0 Where Id=1 ; 