CREATE procedure st_TempUnclaim (@claimcode varchar(100), @test bit)

as
declare @idTransfer int = (select idtransfer from Transfer where ClaimCode=@claimcode); 
if(@idTransfer is null)
Begin
	select 'Error; no existe ' +@claimcode
	return
End

if(@test=1)
	Begin
		select T.IdTransfer, T.ClaimCode, S.StatusName from Transfer T inner join Status S on S.IdStatus =T.IdStatus where IdTransfer=@idTransfer
	End
Else
	Begin

		update Transfer set IdStatus =28 where IdTransfer=@idTransfer

		INSERT INTO [dbo].[TransferDetail]([IdStatus],[IdTransfer],[DateOfMovement])
			 VALUES(28,@idTransfer, getDate())

		declare @idTransferDatail int =scope_identity()

		INSERT INTO [dbo].[TransferNote]([IdTransferDetail],[IdTransferNoteType],[IdUser] ,[Note],[EnterDate])
			 VALUES (@idTransferDatail,1,37,'Unclaimed Completed by System', GETDATE())
	END










