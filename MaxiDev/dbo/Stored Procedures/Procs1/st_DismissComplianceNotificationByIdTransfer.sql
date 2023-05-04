
CREATE procedure [dbo].[st_DismissComplianceNotificationByIdTransfer](
	 @IdTransfer Int, 
	 @IsSpanishLanguage bit, 
	 @HasError bit out, 
	 @MessageOut varchar(max) out 
)as

declare @IdMessages table (IdMessage int)
declare @totalMessages int
declare @totalErrors int

set @totalErrors = 0
set @totalMessages = 0

If exists(Select 1 From [Transfer] with(nolock) where IdTransfer=@IdTransfer)
Begin

	insert into @IdMessages
	select TNN.IdMessage from TransferNoteNotification TNN with(nolock)
	inner join TransferNote TN with(nolock) on TNN.IdTransferNote = TN.IdTransferNote
	inner join TransferDetail TD with(nolock) on TN.IdTransferDetail = TD.IdTransferDetail and TD.IdTransfer = @IdTransfer
	where TNN.IdGenericStatus = 1

End Else Begin
	
	insert into @IdMessages
	select TCNN.IdMessage from TransferClosedNoteNotification TCNN with(nolock)
	inner join TransferClosedNote TCN with(nolock) on TCNN.IdTransferClosedNote = TCN.IdTransferClosedNote
	inner join TransferClosedDetail TCD with(nolock) on TCN.IdTransferClosedDetail = TCD.IdTransferClosedDetail and TCD.IdTransferClosed = @IdTransfer
	where TCNN.IdGenericStatus = 1

End

declare @CurrentIdMessage int
declare @CurrentHasError bit
declare @CurrertErrorMessage varchar(max)
while exists (select 1 from @IdMessages)
begin 
	select top 1 @CurrentIdMessage= IdMessage from @IdMessages
	exec st_DismissComplianceNotification @CurrentIdMessage, @IsSpanishLanguage, @CurrentHasError out, @CurrertErrorMessage out
	set @totalErrors = @totalErrors+@CurrentHasError
	set @totalMessages = @totalMessages+1
	delete @IdMessages where IdMessage = @CurrentIdMessage
end 

set @HasError = CASE WHEN @totalErrors > 0 THEN 1 ELSE 0 END
select @MessageOut=cast(@totalErrors AS VARCHAR(10))+' / '+cast(@totalMessages AS VARCHAR(10))+' '+ dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 


