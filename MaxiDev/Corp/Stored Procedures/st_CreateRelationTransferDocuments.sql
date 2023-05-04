CREATE PROCEDURE [Corp].[st_CreateRelationTransferDocuments]
(
	@IdTransfer int,
	@IdUser int,
	@IsTransferReceipt bit
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
begin try
	if(exists(select t.IdTransfer, th.IdStatus from [Transfer] t with(nolock) join TransferHolds th with(nolock) on t.IdTransfer = th.IdTransfer where th.IdStatus in (15, 12, 9) and t.IdTransfer = @IdTransfer))
	begin 
		exec Corp.st_InsertUpdateRelationTransferDocumentTransferStatus @IdTransfer, 1, @IdUser, @IsTransferReceipt;
	end
end try
begin catch
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_CreateRelationTransferDocuments',Getdate(),@ErrorMessage);
end catch
