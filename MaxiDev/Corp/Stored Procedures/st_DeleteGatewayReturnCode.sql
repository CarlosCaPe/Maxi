CREATE PROCEDURE [Corp].[st_DeleteGatewayReturnCode]
(
	@idGatewayReturnCode int,
	@HasError bit out,
	@Message nvarchar(max) out
)
AS  
Set nocount on;
Begin try
	if exists(Select 1 from GatewayReturnCode with(nolock) where IdGatewayReturnCode = @idGatewayReturnCode)
	begin
		delete GatewayReturnCode where IdGatewayReturnCode = @idGatewayReturnCode
		Set @HasError = 0;
		Set @Message = 'Gateway return code was deleted successfully';
	end
	else
	begin
		Set @HasError = 1;
		Set @Message = 'The Return Code dont Exists';
	end
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DeleteGatewayReturnCode]',Getdate(),@ErrorMessage);
End catch
