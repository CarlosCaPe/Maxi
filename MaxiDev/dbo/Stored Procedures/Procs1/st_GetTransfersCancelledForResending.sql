CREATE procedure [dbo].[st_GetTransfersCancelledForResending]  
@IdCustomer int,  
@IdAgent int  
as  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
declare @IdStatusCancelled int  
set @IdStatusCancelled=22  
  
  
select T.IdTransfer, T.ClaimCode  
from [Transfer] T  with(nolock)
 left join TransferResend TR with(nolock) on TR.IdTransfer =T.IdTransfer  
 left join TransferNotAllowedResend TN with(nolock) on TN.IdTransfer =T.IdTransfer  
 where T.IdAgent=@IdAgent and T.IdCustomer=@IdCustomer and T.IdStatus =@IdStatusCancelled and TR.IdTransfer is null  and TN.IdTransfer is null
   
union   
select T.IdTransferClosed, T.ClaimCode  
from TransferClosed T with(nolock)  
 left join TransferResend TR with(nolock) on TR.IdTransfer =T.IdTransferClosed  
 left join TransferNotAllowedResend TN with(nolock) on TN.IdTransfer =T.IdTransferClosed 
 where T.IdAgent=@IdAgent and T.IdCustomer=@IdCustomer and T.IdStatus =@IdStatusCancelled and TR.IdTransfer is null  and TN.IdTransfer is null
