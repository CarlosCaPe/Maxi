create procedure st_SystemStatusChange
(
    @IdNewStatus int,
    @ActualStatus int,
    @message varchar(max),
    @ClaimCode varchar(max)
)
as
Declare @IdTransfer int

Select @IdTransfer=idtransfer from Transfer where ClaimCode=@ClaimCode and idstatus=@ActualStatus

if (isnull(@IdTransfer,0)>0)
begin
    Update Transfer set IdStatus = @IdNewStatus, DateStatusChange= GETDATE() Where IdStatus=@ActualStatus and IdTransfer= @IdTransfer
    Exec st_SaveChangesToTransferLog @IdTransfer,@IdNewStatus,@message,0
    if exists(select top 1 1 from transfer where IdTransfer= @IdTransfer and IdStatus=@IdNewStatus)
    print 'Transfer Update OK: ' + @ClaimCode
    return
end
print 'Error Transfer Update Claimcode: ' + @ClaimCode