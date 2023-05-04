
create procedure [dbo].[st_UpdateVerifyHold_Backup29may2013]
 (
 @EnterByIdUser int,
 @IsSpanishLanguage bit,
 @IdTransfer int,
 @Note nvarchar(max),
 @StatusHold int,
 @IsReleased bit,
 @HasError bit out,
 @Message nvarchar(max) out
 )
 as
 Set nocount on
 Begin Try
	
	Declare @HoldsChanged int
	Declare @IdStatus int 
	select @IdStatus = IdStatus from Transfer where IdTransfer = @IdTransfer

	Update TransferHolds set IsReleased=@IsReleased, DateOfLastChange=GetDate() where IdTransfer = @IdTransfer and IdStatus=@StatusHold and  IsReleased is null
	set @HoldsChanged = @@rowcount
	If @IdStatus= 41
	Begin
		If @HoldsChanged = 1 
		Begin
			If @IsReleased = 1 --A Hold has been Released
			Begin
				Declare @HoldAcceptedStatus int
				Set @HoldAcceptedStatus = @StatusHold +1
				Exec st_SaveChangesToTransferLog @IdTransfer,@HoldAcceptedStatus,@Note,@EnterByIdUser
			End
			Else --A Hold has been Rejected
			Begin
				Update Transfer Set IdStatus=31,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer
				Exec st_RejectedCreditToAgentBalance @IdTransfer
				Exec st_SaveChangesToTransferLog @IdTransfer,31,@Note,@EnterByIdUser
				Exec st_DismissComplianceNotificationByIdTransfer @IdTransfer, @IsSpanishLanguage, @HasError out, @Message out
			End
		
			Select @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,30)
			Set @HasError=0
		End
		Else
		Begin --Invalid change due to someone else changed it before
			Select @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,31)
			Set @HasError=1
		End
	End
	Else
	Begin
		Declare @NewStatus int
		If @IsReleased = 1
		Begin
			Select @NewStatus =	
				Case @IdStatus	
				When 24 then 20 --Returned pass to StandBy
				When 27 then 28 --Unclaim pass to UnclaimCompleted
				End
		End
		Else
		Begin
			Set @NewStatus = 31
		End
		Exec st_UpdateComplianceStatus @EnterByIdUser, @IsSpanishLanguage, @IdTransfer, @Note, @IdStatus,@NewStatus,
		@HasError = @HasError OUTPUT,
		@Message = @Message OUTPUT
	End
End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHold',Getdate(),@ErrorMessage)
End Catch

