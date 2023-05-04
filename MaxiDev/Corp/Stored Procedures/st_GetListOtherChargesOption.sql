CREATE PROCEDURE [Corp].[st_GetListOtherChargesOption]
AS  

Set nocount on;
Begin try
	Select IdOtherChargesOption, OptionName from OtherChargesOption with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetListOtherChargesOption]',Getdate(),@ErrorMessage);
End catch
