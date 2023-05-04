CREATE procedure [Corp].[st_GetNewsToEdit]
	@IdGenericStatus int = null
AS  
Set nocount on;
Begin try
	Select BeginDate, EndDate, IdGenericStatus, IdNews, NewsSpanish, News, Title from News with(nolock)
	where IdGenericStatus = ISNULL(@IdGenericStatus, IdGenericStatus)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetNewsToEdit',Getdate(),@ErrorMessage);
End catch
