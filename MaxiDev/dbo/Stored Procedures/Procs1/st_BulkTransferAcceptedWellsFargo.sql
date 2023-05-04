
CREATE procedure [dbo].[st_BulkTransferAcceptedWellsFargo]              
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
select * from [MAXILOG].[dbo].WellsFargoLogFile with(nolock)
Select A.IdTransfer,CheckNumber,b.idstatus into #Temp from  [MAXILOG].[dbo].WellsFargoLogFile A with(nolock)     
Join Checks B with(nolock) on (A.IdTransfer=B.IdCheck)      
where IdFileName=@IdFile  and TypeOfTransfer='Transfer' and [dbo].[RemoveTimeFromDatetime]( DateOfFileCreation)=[dbo].[RemoveTimeFromDatetime](getdate());
      
Declare @IdTransfer int,@ClaimCode nvarchar(max) ,@Idstatus int       
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Transfer Accepted, FileName: '+@FileName
      
While exists (Select 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=CheckNumber,@Idstatus=idstatus From #Temp   
 
 if  (@Idstatus  = 21) 
 begin    
	Insert into  WellsFargoRespoLog values (getdate(),@Claimcode,'None','1',40,@MessageTransfer,'') ;                     
	Update Checks set IdStatus=40,DateStatusChange=GETDATE() where IdCheck=@IdTransfer;                                            
	Exec st_SaveChangesToTransferLog @IdTransfer,40,@MessageTransfer,0;  --40 TransferAccepted            
 end
       
 Delete #Temp where idtransfer=@IdTransfer;      
End
