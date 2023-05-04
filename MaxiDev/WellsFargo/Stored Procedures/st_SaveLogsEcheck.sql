/********************************************************************
<Author> azavala </Author>
<app>Agent</app>
<Description>Guarda Logs de la peticion a WellsFargo Echeck</Description>

<ChangeLog>
<log Date="21/06/2018" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [WellsFargo].[st_SaveLogsEcheck]
	@IdAgent int,
	@Request varchar(MAX),
	@RequestDate DateTime,
	@Response varchar(MAX),
	@ResponseDate DateTime,
	@endpoint varchar(MAX),
	@TransID nvarchar(MAX),
	@Folio nvarchar(MAX),
	@ReasonCode nvarchar(MAX)
AS
BEGIN try
	SET NOCOUNT ON;

	INSERT INTO [MAXILOG].[WellsFargo].[TransferWFEcheckLogs]
           ([IdAgent]
           ,[Request]
           ,[RequestDate]
           ,[Response]
           ,[ResponseDate]
           ,[ReasonCode]
           ,[TransID]
           ,[Folio]
		   ,[Endpoint]
           )
     VALUES
           (@IdAgent
           ,@Request
           ,@RequestDate
           ,@Response
           ,@ResponseDate
           ,@ReasonCode
           ,@TransID
           ,@Folio
		   ,@endpoint
           )
END try
BEGIN CATCH
	
END CATCH
