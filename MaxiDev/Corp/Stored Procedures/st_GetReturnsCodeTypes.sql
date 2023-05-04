CREATE PROCEDURE [Corp].[st_GetReturnsCodeTypes]

AS  

Set nocount on;
Begin try
	Select IdGatewayReturnCodeType, ReturnCodeType from GatewayReturnCodeType with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetReturnsCodeTypes',Getdate(),@ErrorMessage);
End catch
