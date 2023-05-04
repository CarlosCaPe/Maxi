create  Procedure [dbo].[st_SaveChangesToTransferLogDay]          
(          
@IdTransfer int,          
@IdStatus int,          
@Note nvarchar(max),        
@IdUser int ,
@CreateNote bit = 0,
@Date datetime         
)          
As      
/*
CHANGES CONTROLS
1/FEb/2012  by hmg  added insert additional note if is different than empty or null


 */          
Set nocount on          
Begin Try          
Declare @IdValue int,@IdSystemUser int          
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement) values (@IdStatus,@IdTransfer,@Date)          
Select @IdValue=SCOPE_IDENTITY ()    

declare @NoteAdditional nvarchar(max)
select @NoteAdditional = COALESCE(NoteAdditional,'') from TRansfer      
where IdTransfer = @IDTransfer
          
If @IdUser=0    
Begin    
 Select  @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')    
 
 Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,1,@IdSystemUser,@Note,@Date)  
 if (@NoteAdditional<> '' and @CreateNote = 1)
 Begin     
	Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,1,@IdSystemUser,@NoteAdditional,@Date)  
 END        
End     
Else      
begin    
 Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,2,@IdUser,@Note,@Date)     
 if (@NoteAdditional<> '' and @CreateNote = 1)
 Begin     
	Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,2,@IdUser,@NoteAdditional,@Date)          
 END
     
end    
---------------- Mensaje a celular ------------------------------        
        
Declare @IdPaymentType Int,@ClaimCode nvarchar(max)      
Select  @IdPaymentType=IdPaymentType from Transfer where IdTransfer=@IdTransfer      
        
If exists (Select 1 from StatusToSendCellularMsg Where IdStatus=@IdStatus And IdPaymentType=@IdPaymentType) And        
exists(Select 1 from Transfer where CustomerIdCarrier<>0 and IdTransfer=@IdTransfer)        
Begin        
        
  Declare @FullEmail nvarchar(max)        
          
  Select @FullEmail= Replace (Replace (Replace (Replace(A.CustomerCelullarNumber,'-',''),' ',''),'(',''),')','')+B.Email,@ClaimCode=A.ClaimCode  from Transfer A        
  Join Carriers B on (A.CustomerIdCarrier=IdCarrier)        
  Where IdTransfer=@IdTransfer         
         
  exec st_SendMailToCellular @FullEmail,@IdStatus,@IdPaymentType,@ClaimCode        
         
End        
End Try                  
Begin Catch                  
 Declare @ErrorMessage nvarchar(max)                   
 Select @ErrorMessage=ERROR_MESSAGE()                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveChangesToTransferLog',Getdate(),@ErrorMessage)                  
End Catch  
