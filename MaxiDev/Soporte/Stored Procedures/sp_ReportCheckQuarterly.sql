 CREATE PROCEDURE [Soporte].[sp_ReportCheckQuarterly]
 (
	@Agents varchar(MAX),
	@BeginDate date,
	@EndDate date
 )
AS    
/********************************************************************
<Author>Juan Diego Arellano Vitela</Author>
<app>---</app>
<Description>Procedimiento almacenado que permite crear el reporte trimestral de determinadas agencias.</Description>

<ChangeLog>
<log Date="27/02/2018" Author="jdarellano">Creación</log>
</ChangeLog>
*********************************************************************/        
BEGIN 

SET NOCOUNT ON;   
	Begin try

		Declare @DocHandle int

		EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Agents

		declare @AgentCodes table
		(
			AgentCode varchar(20)
		)

		insert into @AgentCodes
			select *
			from openxml(@DocHandle,'/Agent/AgentC',1)
			with (AgentCode varchar(20))


		declare @Agent table
		(
			IdAgent int,
			AgentCode varchar(20)
		)

		insert into @Agent
			select a.IdAgent,ac.AgentCode
			from @AgentCodes ac
				join [dbo].[Agent] a with(nolock) on ac.AgentCode=a.AgentCode


		select c.IdAgent,ag.AgentCode,Amount= sum(Amount), COUNT(Amount) Consolidated
		from [dbo].[Checks] c with(nolock)
			join @Agent ag on c.IdAgent=ag.IdAgent
		where DateOfMovement BETWEEN @BeginDate and @EndDate
			and IdStatus = 30
		group by c.IdAgent,ag.AgentCode 


		select AgentCode,CheckNumber,Amount,DateOfMovement 
		from [dbo].[Checks] c with(nolock)
			join @Agent a on c.IdAgent=a.IdAgent
		where c.IdAgent in (select IdAgent from @Agent)
		  and DateOfMovement BETWEEN @BeginDate and @EndDate
		  and IdStatus = 30
		order by AgentCode

	end try
	begin catch
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage=ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Soporte.sp_ReportCheckQuarterly',GETDATE(),'Error in line: '+CONVERT(VARCHAR,ERROR_LINE())+' | '+@ErrorMessage)
	END CATCH		

END