CREATE PROCEDURE [Corp].[st_SaveChangesToProductTransferLog_Operation]          
(          
@IdProductTransfer bigint,          
@IdStatus int,          
@Note nvarchar(max),        
@IdUser int ,
@CreateNote bit = 0         
)          
As      
        
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add ;</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin Try          
Declare @IdValue int,@IdSystemUser int          
Insert into operation.ProductTransferDetail (IdStatus,IdProductTransfer,DateOfMovement) values (@IdStatus,@IdProductTransfer,GETDATE());          
Select @IdValue=SCOPE_IDENTITY ();    
          
If @IdUser=0    
Begin    
 Select  @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')     
 Insert into operation.ProductTransferNote (IdProductTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,1,@IdSystemUser,@Note,getdate());       
End     
Else      
begin    
 Insert into operation.ProductTransferNote (IdProductTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdValue,2,@IdUser,@Note,getdate());           
end            
      
End Try                  
Begin Catch                  
 Declare @ErrorMessage nvarchar(max)                   
 Select @ErrorMessage=ERROR_MESSAGE()                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveChangesToProductTransferLog_Operation',Getdate(),@ErrorMessage);                  
End Catch  


