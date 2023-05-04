CREATE procedure [Corp].[st_GetAllGateways]
AS  

Set nocount on;
Begin try
	Select IdGateway, GatewayName, Code from Gateway with(nolock)
	where [Status]=1 and Hide=1 order by GatewayName

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAllGateways]',Getdate(),@ErrorMessage);
End catch
