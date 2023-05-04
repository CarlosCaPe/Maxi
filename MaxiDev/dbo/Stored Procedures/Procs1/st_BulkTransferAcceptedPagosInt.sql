
CREATE procedure [dbo].[st_BulkTransferAcceptedPagosInt]        
(      
    @IdFile int,
    @FileName nvarchar(max)
)      
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
Set nocount on       
Select A.IdTransfer,ClaimCode into #Temp from   PagosIntLogFileTXT A with(nolock)     
Join [Transfer] B with(nolock) on (A.IdTransfer=B.IdTransfer)      
where IdFileName=@IdFile;      
      
Declare @IdTransfer int,@ClaimCode nvarchar(max)
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Transfer Accepted, FileName: '+@FileName     
      
While exists (Select 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=ClaimCode From #Temp;      
       
 Insert into  [MAXILOG].[dbo].PagosIntResponseLog values (getdate(),@Claimcode,'None','1',40,@MessageTransfer,'');                      
 Update [Transfer] set IdStatus=40,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer;                                            
 Exec st_SaveChangesToTransferLog @IdTransfer,40,@MessageTransfer,0;  --40 TransferAccepted      
      
       
 Delete #Temp where idtransfer=@IdTransfer;      
End 
