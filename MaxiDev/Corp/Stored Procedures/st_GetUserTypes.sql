CREATE procedure [Corp].[st_GetUserTypes]

AS  

Set nocount on;
Begin try
	Select IdUserType, [Name] from UsersType with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetUserTypes]',Getdate(),@ErrorMessage);
End catch
