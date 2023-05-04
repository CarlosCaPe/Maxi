
CREATE PROCEDURE [dbo].[st_MoveTransferReturn]
(
	@IdTransfer int,
    @EnterByIdUser int,
    @IsSpanishLanguage bit,
    @Note nvarchar(max),
    @HasError bit out,
    @Message nvarchar(max) out
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
 
 declare @TransferDetail XML              
 declare @HasErrorNote bit
 declare @MessageNote varchar(max) 

Begin Try
	if (Exists(select IdTransferHold from TransferHolds with(nolock) where IdTransfer = @IdTransfer and (IsReleased is null or IsReleased=0))) -- tiene algun hold pendiente
	begin -- se cambia a status 41
		Update [Transfer] Set IdStatus = 41, DateStatusChange = GETDATE() Where IdTransfer = @IdTransfer;
		
		if (Exists(select IdTransferHold from TransferHolds with(nolock) where IdTransfer = @IdTransfer and IdStatus = 3 and IsReleased is null)) 
		BEGIN
			Update TransferHolds set IsReleased=1, DateOfLastChange=GetDate(),EnterByIdUser=@EnterByIdUser where IdTransfer = @IdTransfer and IdStatus=3 and  IsReleased is null;
			exec st_SimpleAddNoteToTransfer @IdTransfer, @Note;
		END
	end
	else
	begin -- se cambia a status 20 Stand by
		Update [Transfer] Set IdStatus = 20, DateStatusChange = GETDATE() Where IdTransfer = @IdTransfer ;
	end
	exec st_AddNoteToTransfer @IdTransfer, @EnterByIdUser, @Note, @IsSpanishLanguage, @TransferDetail out, @HasErrorNote out, @MessageNote out;
	Select @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,30)
	Set @HasError=0
End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_MoveTransferReturn',Getdate(),@ErrorMessage)
End Catch
