

-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <22 de noviembre de 2017>
-- Description:	<Procedimiento almacenado que corrige agencias que no muestran ciudades en el agente nuevo.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_FixAgentLocationSearch]
AS

SET NOCOUNT ON; 

Begin try
	Declare @NoAgentLocationSearch table
	(
		IdAgent int,
		AgentCode varchar(15)
	)


	Insert into @NoAgentLocationSearch
		select IdAgent,AgentCode
		from dbo.Agent a with(nolock)
		where not exists(
			select distinct idAgent
			from Elastic.AgentLocationSearch e with(nolock)
			where a.IdAgent=e.idAgent)
		and CreationDate>=CONVERT(date,getdate()-5)

	if exists (select 1 from @NoAgentLocationSearch)
	begin
		select * from @NoAgentLocationSearch
		declare @CreationDate date
		declare @IdAgent int

		set @IdAgent=(select top 1 IdAgent from @NoAgentLocationSearch order by IdAgent)
		select @IdAgent as IdAgent

		set @CreationDate=(select CONVERT(date,CreationDate) from Agent with(nolock) where IdAgent=@IdAgent)
		select @CreationDate as CreationDate

		update GlobalAttributes 
		set Value = (select CONVERT(datetime,@CreationDate)) 
		where Name='AgentLocationElasticSearch'

		exec [Elastic].[st_ElasticLocation_RefreshData]

		----=====Correo de notificación=====--
		--DECLARE @ProcID VARCHAR(200)
		--declare @Body1 varchar(500)
		--SET @ProcID =OBJECT_NAME(@@PROCID)

		--set @Body1='A partir de la fecha de creación de la agencia '+convert(varchar,@IdAgent)+' ('+convert(varchar,(select agentcode from agent where idagent=@IdAgent))+')'+' se actualiza el ElasticSearch'

		--EXEC sp_MailQueue 
		--@Source   =  @ProcID,
		--@To 	  =  'soportemaxi@boz.mx',
		--@Subject  =  'Agencias con AgentLocationSearch',
		--@Body  	  =  @Body1


	end

End try
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixAgentLocationSearch',Getdate(),@ErrorMessage)
End catch
