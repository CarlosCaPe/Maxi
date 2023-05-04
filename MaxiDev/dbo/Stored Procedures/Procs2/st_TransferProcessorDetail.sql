
CREATE Procedure [dbo].[st_TransferProcessorDetail](@IdTransfer int, @IdTransferStatus int) AS  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ;</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;  
  
If not exists (select IdTransferHold from TransferHolds with(nolock) where IdTransfer = @IdTransfer and (IsReleased is null or IsReleased=0)) --Si no existe un Hold sin evaluar o Rejected cambiar Status a 20  
Begin  

 declare @idsUpdated table
 (
     IdStatus int    
 );
 
 Update [Transfer] Set IdStatus=20,DateStatusChange=GETDATE()
 OUTPUT    
        INSERTED.IdStatus
 INTO 
    @idsUpdated 
 Where 
    IdTransfer=@IdTransfer and idstatus=@IdTransferStatus;

 if exists (select top 1 IdStatus from @idsUpdated)
 begin
    Exec st_SaveChangesToTransferLog @IdTransfer,20,'Stand By',0; -- Log , En Ready to be taken by Gateway  
    declare @IsSpanishLanguage bit  
    declare @HasError bit  
    declare @Message nvarchar(max)  
    Exec st_DismissComplianceNotificationByIdTransfer @IdTransfer, @IsSpanishLanguage, @HasError out, @Message out;  
 end

End  
  
