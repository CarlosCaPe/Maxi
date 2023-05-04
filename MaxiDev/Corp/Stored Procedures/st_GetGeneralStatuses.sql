CREATE PROCEDURE [Corp].[st_GetGeneralStatuses]
AS  
Set nocount on;
Begin try
	Select IdGenericStatus, GenericStatus from GenericStatus with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetGeneralStatuses',Getdate(),@ErrorMessage);
End catch
