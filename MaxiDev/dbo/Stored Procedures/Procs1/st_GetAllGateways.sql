/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="05/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetAllGateways]
AS  

Set nocount on;
Begin try
	Select IdGateway, GatewayName, Code from Gateway with(nolock)
	where [Status]=1 and Hide=1 order by GatewayName

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAllGateways',Getdate(),@ErrorMessage);
End catch
