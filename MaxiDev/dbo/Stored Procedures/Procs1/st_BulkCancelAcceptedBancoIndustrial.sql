
CREATE procedure [dbo].[st_BulkCancelAcceptedBancoIndustrial]        
(      
    @IdFile int,
    @FileName nvarchar(max)      
)      
as      
Set nocount on       

Select A.IdTransfer,ClaimCode into #Temp from   BancoIndustrialLogFileTXT A      
Join Transfer B on (A.IdTransfer=B.IdTransfer)      
where IdFileName=@IdFile and TypeOfTransfer='Cancel'  and [dbo].[RemoveTimeFromDatetime]( DateOfFileCreation)=   [dbo].[RemoveTimeFromDatetime](getdate())  
      
Declare @IdTransfer int,@ClaimCode nvarchar(max)
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Cancel Accepted, FileName: '+@FileName      
      
While exists (Select top 1 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=ClaimCode From #Temp             
  
 Insert into  BancoIndustrialResponseLog values (getdate(),@Claimcode,'None','1',35,@MessageTransfer,'')                      
 Update Transfer set IdStatus=35,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer                                            
 Exec st_SaveChangesToTransferLog @IdTransfer,35,@MessageTransfer,0  --35 CancelAccepted            
       
 Delete #Temp where idtransfer=@IdTransfer      
End