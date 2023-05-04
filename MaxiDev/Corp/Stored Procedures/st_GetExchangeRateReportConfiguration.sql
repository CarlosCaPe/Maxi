CREATE procedure [Corp].[st_GetExchangeRateReportConfiguration]
AS  
Set nocount on;
Begin try
	Select [Id_Report], [Description], [ValueIn] from ReportExRatesConfig with(nolock)
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetExchangeRateReportConfiguration',Getdate(),@ErrorMessage);
End catch
