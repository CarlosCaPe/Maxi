
CREATE PROCEDURE [Elastic].[st_ElasticLocation_Finish] 
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="08/01/2019" Author="jmolina">Add begin try</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY
	DECLARE @dateFinished DATETIME = dateadd(second,1,getDate())

	UPDATE GlobalAttributes 
	SET Value =Convert(VARCHAR,@dateFinished,111)+' '+Convert(VARCHAR,@dateFinished,108)
	WHERE Name ='AgentLocationElasticSearch'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_Finish', GETDATE(), @ErrorMessage)
END CATCH