CREATE PROCEDURE [Corp].[st_GetAllCommissions]

AS  

Set nocount on;
Begin try
	Select IdCommission, CommissionName
	from Commission with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAllCommissions]',Getdate(),@ErrorMessage);
End catch
