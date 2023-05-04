CREATE procedure [dbo].[st_BulkTransferAcceptedBancoUnion]        
(      
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

Select A.IdTransfer,ClaimCode,b.idstatus into #Temp from  BancoUnionLogFileTXT A with(nolock)      
	Join [Transfer] B with(nolock) on (A.IdTransfer=B.IdTransfer)      
where [FileName]=@FileName  and TypeOfTransfer='Transfer' and [dbo].[RemoveTimeFromDatetime]( DateOfFileCreation)=[dbo].[RemoveTimeFromDatetime](getdate())
      
Declare @IdTransfer int,@ClaimCode nvarchar(max) ,@Idstatus int       
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Transfer Accepted, FileName: '+@FileName
      
While exists (Select 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=ClaimCode,@Idstatus=idstatus From #Temp   
 
 if  (@Idstatus  = 21) 
 begin        
	Insert into  BancoUnionResponseLog values (getdate(),@Claimcode,'None','1',40,@MessageTransfer,'');                      
	Update Transfer set IdStatus=40,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer;                                            
	Exec st_SaveChangesToTransferLog @IdTransfer,40,@MessageTransfer,0 ; --40 TransferAccepted            
 end
       
 Delete #Temp where idtransfer=@IdTransfer ;     
End



