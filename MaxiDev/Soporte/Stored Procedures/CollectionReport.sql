-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <27 de septiembre de 2017>
-- Description:	<Procedimiento almacenado que genera la información que alimenta "CollectionReport">
-- =============================================
CREATE Procedure [Soporte].[CollectionReport]      
 AS


insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage) values
	('Soporte.CollectionReport',GETDATE(),'Comienzo '+convert(varchar,convert(date,getdate()))+' '+CAST(GETDATE() as varchar))


declare @StartDate datetime
set @StartDate=getdate()

declare @EndDate datetime
set @EndDate=@StartDate+1

       
truncate table [Soporte].[CollectionReport_Depositos]
insert into [Soporte].[CollectionReport_Depositos]
	exec st_ReportDepositOtherCharge @StartDate,@EndDate


truncate table [Soporte].[CollectionReport_CP]
insert into [Soporte].[CollectionReport_CP]
	exec st_ReportDepositCollectPlan @StartDate,@EndDate


truncate table [Soporte].[CollectionReport_Checks]
insert into [Soporte].[CollectionReport_Checks]
	exec st_ReportDepositChecks @StartDate,@EndDate


truncate table [Soporte].[CollectionReport_Batches]
insert into [Soporte].[CollectionReport_Batches]
	exec st_ReportDepositBatchChecks @StartDate,@EndDate


truncate table [Soporte].[CollectionReport_PendingChecks]
insert into [Soporte].[CollectionReport_PendingChecks]
	exec st_ReportDepositPendingChecks @StartDate,@EndDate


insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage) values
	('Soporte.CollectionReport',GETDATE(),'Término '+convert(varchar,convert(date,getdate()))+' '+CAST(GETDATE() as varchar))
	
       
       


