create procedure [dbo].[st_UpdateReportExRatesConfig]
@Id_Report int,
@ValueIn int
as

update ReportExRatesConfig set ValueIn=@ValueIn where Id_Report=@Id_Report
