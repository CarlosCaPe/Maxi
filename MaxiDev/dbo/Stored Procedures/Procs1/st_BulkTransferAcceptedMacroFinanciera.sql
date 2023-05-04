CREATE procedure [dbo].[st_BulkTransferAcceptedMacroFinanciera]        
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

Select A.IdTransfer,ClaimCode,idgateway, idpayer, exrate into #Temp from  [MAXILOG].[dbo].MacroFinancieraLogFileTXT A with(nolock)      
Join [Transfer] B with(nolock) on (A.IdTransfer=B.IdTransfer)      
where IdFileName=@IdFile;      
      
Declare @IdTransfer int,@ClaimCode nvarchar(max), @refexrate money , @idgateway int, @idpayer int, @exrate money      
declare @MessageTransfer nvarchar(max)

set @MessageTransfer = 'Transfer Accepted, FileName: '+@FileName
      
While exists (Select 1 from #Temp )      
Begin      
 Select top 1 @IdTransfer=IdTransfer,@ClaimCode=ClaimCode, @idgateway=idgateway, @idpayer = idpayer, @exrate = exrate From #Temp;   
       
 Insert into [Maxilog].[dbo].MacroFinancieraResponseLog values (getdate(),@Claimcode,'None','1',40,@MessageTransfer,'');
 Update Transfer set IdStatus=40,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer; 
 Exec st_SaveChangesToTransferLog @IdTransfer,40,@MessageTransfer,0;  --40 TransferAccepted

 select top 1 @refexrate = refexrate from refexrate with(nolock) where idgateway=@idgateway and isnull(@idpayer,0)=isnull(idpayer,0) and active=1 order by idrefexrate desc

 set @refexrate = isnull(@refexrate,0)

 insert into TransferExRates
 values
 (@IdTransfer,@ClaimCode,@idgateway,@idpayer,@refexrate,@exrate);
       
 Delete #Temp where idtransfer=@IdTransfer;      
End