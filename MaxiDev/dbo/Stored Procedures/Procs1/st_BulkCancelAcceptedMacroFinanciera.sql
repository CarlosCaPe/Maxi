CREATE procedure [dbo].[st_BulkCancelAcceptedMacroFinanciera]        
(      
    @IdFile int,
    @FileName nvarchar(max)
)      
as      
Set nocount on       
Select A.IdTransfer,ClaimCode into #Temp from  [MAXILOG].[dbo].MacroFinancieraLogFileTXT A      
Join Transfer B on (A.IdTransfer=B.IdTransfer)      
where IdFileName=@IdFile and TypeOfTransfer='Cancel'      
      
Declare @IdTransfer int,@ClaimCode nvarchar(max)  
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Cancel In Process, FileName: '+@FileName    
      
While exists (Select top 1 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=ClaimCode From #Temp             
 
 Insert into  [Maxilog].[dbo].MacroFinancieraResponseLog values (getdate(),@Claimcode,'None','1',26,@MessageTransfer,'')                      
 Update Transfer set IdStatus=26,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                            
 Exec st_SaveChangesToTransferLog @IdTransfer,26,@MessageTransfer,0  --35 Cancel In Process          
       
 Delete #Temp where idtransfer=@IdTransfer      
End      