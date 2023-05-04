CREATE PROCEDURE [Corp].[st_GetTransfersHoldWithFileReference]  
(  
@IdStatus int
, @IdUser int = null
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

SET NOCOUNT ON;
SET ARITHABORT ON;

	Declare @IdTransactionReceiptType int 
	Set @IdTransactionReceiptType=55
	    
declare
 @TiempoAsginado int


    select 
	 @TiempoAsginado = cast(Value as int)
	from 
	 GlobalAttributes with(nolock)
	where Name ='PhoneHoldExpress' 
 
   delete
    TransferByHoldReserved
   where      
     IdUser=@IdUser
        	

		select 
		T.IdAgent,
		A.AgentCode, 
		T.ClaimCode,
		T.CustomerName, 
		T.CustomerFirstLastName, 
		T.CustomerSecondLastName,
		A.AgentName,
		T.DateOfTransfer,
		T.IdTransfer,
		T.Folio,
		P.PayerName,
		T.AmountInDollars,
		T.IdStatus,
		S.StatusName,
		C.PhysicalIdCopy,
		C.IdCustomer--, 
		--UC.IdUploadFile,
		--UC.FileGuid + UC.Extension as FilePath,
		--0 
        into #temp1
		 from [transfer] T with(nolock)
		 join Agent A with(nolock) on T.IdAgent=A.IdAgent
		 join Payer P with(nolock) on T.IdPayer=P.IdPayer
		 join [Status] S with(nolock) on T.IdStatus=S.IdStatus
		 join Customer C with(nolock) on T.IdCustomer=C.IdCustomer
		 join TransferHolds H with(nolock) on T.IdTransfer=H.IdTransfer and H.IdStatus=3 and H.IsReleased is null
		 left join UploadFiles UC with(nolock) on UC.IdUploadFile=(select MAX(IdUploadFile) from UploadFiles with(nolock) where IdDocumentType=@IdTransactionReceiptType and T.IdTransfer = IdReference and IdStatus = 1)
		 --OUTER APPLY
			--(
			--	SELECT  TOP 1 U.IdReference, U.FileGuid, U.Extension,U.IdUploadFile
			--	FROM   UploadFiles U
			--	Where U.IdDocumentType=@IdTransactionReceiptType and T.IdTransfer = U.IdReference and U.IdStatus = 1
			--	ORDER BY
			--	U.LastChange_LastDateChange desc 
			--) UC 
		  where 
		   T.IdStatus=41 		   		   
		   and T.idtransfer not in
		                   ( select
		                       rese.idtransfer
		                     from 
		                      TransferByHoldReserved rese with(nolock)
--		                     where 
--		                      	(select 
--								     datediff (minute 
--								              , rese.DateOfReserved 
--								              , getdate() 
--								             )      
--								    ) <= @TiempoAsginado 
		                   ) 
		     


    select distinct IdReference, max(IdUploadFile) over(partition by IdReference) IdUploadFile into #temp2 from UploadFiles with(nolock) where IdDocumentType=@IdTransactionReceiptType and IdReference in (select idtransfer from #temp1) and IdStatus = 1 

    select t1.*,UC.IdUploadFile,UC.FileGuid + UC.Extension as FilePath,0  
    from #temp1 t1
    left join #temp2 t2 on t1.idtransfer=t2.IdReference
    left join UploadFiles UC with(nolock) on UC.IdUploadFile=t2.IdUploadFile
    order by t1.DateOfTransfer asc


