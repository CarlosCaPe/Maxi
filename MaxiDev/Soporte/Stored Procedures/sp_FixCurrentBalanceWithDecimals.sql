
CREATE PROCEDURE [Soporte].[sp_FixCurrentBalanceWithDecimals]
AS 

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que elimina decimales en balance de agente identificados</Description>

<ChangeLog>
<log Date="07/01/2019" Author="jdarellano">Creación</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN TRY

	create table #AgentsWithdecimals
	(
		idAgent int,
		AgentCode nvarchar (50),
		AgentName nvarchar (500),
		AgentStatus nvarchar (500),
		Decimals float
	)
	
	create index IX_AgentsWithdecimals_IdAgent  on #AgentsWithdecimals(IdAgent)

	insert into #AgentsWithdecimals
		SELECT  A.IdAgent, A.AgentCode, A.AgentName, ASu.AgentStatus ,CONVERT(float ,AB.Balance - ROUND(AB.balance,2,2)) as Decimals
		FROM dbo.AgentCurrentBalance as AB with (nolock)
		INNER JOIN dbo.Agent as A with (nolock) on A.IdAgent =AB.IdAgent
		INNER JOIN dbo.AgentStatus as ASu with (nolock) on Asu.IdAgentStatus=A.IdAgentStatus
		WHERE AB.Balance != ROUND(AB.balance,2,2) and A.IdAgentStatus in (1,4,3,7)


	declare @IdAgent int, 
		@Amount money, 
		@TypeOfMovement nvarchar(max), 
		@IsDebit bit, 
		@IdOtherCharges int, 
		@Decimals varchar(max), 
		@AgentCode nvarchar(max), 
		@AgentName nvarchar(max),
		@AgentStatus nvarchar(max)

	declare @AgentsWithDecimalsErased table
	(
		AgentCode nvarchar(max),
		AgentName nvarchar(max),
		AgentStatus nvarchar(max),
		Decimals varchar(max),
		TypeOfMovement nvarchar(max)
	)

	while exists (select 1 from #AgentsWithdecimals with (nolock))
	Begin
		select top 1 @IdAgent=IdAgent,@AgentCode=AgentCode,@AgentStatus=AgentStatus,@AgentName=AgentName,@Amount=CAST(Decimals as money),@Decimals=CONVERT(varchar,Decimals)  from #AgentsWithdecimals with (nolock)

		if (@Amount>=0)
		begin 
			set @TypeOfMovement='Other Credit'
			set @IsDebit=0
			set @IdOtherCharges=15
		end

		else
		begin
			set @TypeOfMovement='Other Debit'
			set @IsDebit=1
			set @IdOtherCharges=18
		end

		Declare @Notes nvarchar(max) 

		set @Notes=''+@TypeOfMovement+' por sistema para eliminar decimales en balance de agencia ('+CAST(@Decimals as nvarchar(max))+')'


		declare @Getdate datetime=getdate()
		declare @HasError BIT                                   
		declare @Message NVARCHAR(MAX) 

		exec [dbo].[st_SaveOtherCharge]
			@IdLenguage=1,
			@IdAgent =@IdAgent,            
			@Amount =@Amount,    
			@IsDebit =@IsDebit,--0 para crédito (creditos quitan registros positivos)
			@ChargeDate =@Getdate,            
			@Notes =@Notes,
			@Reference ='',            
			@EnterByIdUser =37, 
			@HasError =@HasError,                                  
			@Message =@Message,
			@IdOtherChargesMemo =@IdOtherCharges,--15 para Other Credit y 18 para Other Debit
			@OtherChargesMemoNote  ='',
			@ComesFromStoredReverse = 0,
			@IsReverse = 0;

		insert into @AgentsWithDecimalsErased (AgentCode,AgentName,AgentStatus,Decimals,TypeOfMovement) VALUES (@AgentCode,@AgentName,@AgentStatus,@Decimals,@TypeOfMovement);

		delete from #AgentsWithdecimals where IdAgent=@IdAgent;
		
	end

	drop table #AgentsWithdecimals

	--=====Correo de notificación=====--
	DECLARE @XmlFormat nvarchar(max)
	DECLARE @Subject varchar(150)
	DECLARE @EmailProfile nvarchar(max)
	SELECT @EmailProfile = [Value] FROM GLOBALATTRIBUTES WITH(NOLOCK) WHERE [Name]='EmailProfiler'  

	SELECT @XmlFormat = N'
		<style>
		table {
			font-family: arial, sans-serif;
			border-collapse: collapse;
			border: 1px solid #0101DF;
			width: 100%;
		}

		th {
			background-color: #0101DF;
			color: #FFFFFF;
		}

		td, th {
			text-align: left;
			padding: 8px;
		}

		tr:nth-child(even) {
			background-color: #EFFBFB;
		}
		</style>'

	IF EXISTS(SELECT 1 FROM @AgentsWithDecimalsErased)
	BEGIN
		SELECT @XmlFormat = @XmlFormat + N'<h7>Les compartimos los movimientos aplicados en sistema para la eliminación de decimales en el balance de las siguientes agencias:</h7><br>'
			+ '<table id="agents"><theader><tr><th>AgentCode</th><th>AgentName</th><th>AgentStatus</th><th>Decimals</th><th>TypeOfMovement</th></tr></theader><tbody>' + 
		CAST((
				SELECT AgentCode AS 'td', '', AgentName AS 'td', '', AgentStatus AS 'td', '', Decimals AS 'td', '', TypeOfMovement AS 'td'
				FROM @AgentsWithDecimalsErased
				FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'

		IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
		BEGIN
			SET @Subject = 'Agencias con Decimales ' + @@SERVERNAME
			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name=@EmailProfile,
			@recipients='mmendoza@maxi-ms.com; cob@maxi-ms.com;soportemaxi@boz.mx; jmolina@boz.mx; josesoto@boz.mx;',
			@subject=@Subject,
			@body=@XmlFormat,
			@body_format = 'HTML'
		END
	END

END TRY
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixCurrentBalanceWithDecimals',Getdate(),@ErrorMessage)
End catch

