
create PROCEDURE [Soporte].[sp_FixAgentBalanceSkips1]
@BeginDate dateTime=null
AS 

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que corrige descuadres en balance de agente identificados del día anterior</Description>

<ChangeLog>
<log Date="25/07/2017" Author="jdarellano">Creación</log>
<log Date="18/05/2018" Author="jdarellano" Name="#1">Modificación de procedimiento para extraer agencias con descuadres</log>
<log Date="02/01/2020" Author="jdarellano" Name="#2">Se agregan mejoras para validar corrección. De existir error, se ajusta por proceso por fecha.</log>
<log Date="11/01/2021" Author="jdarellano" Name="#3">Se agregan mejoras para validar inserción de agencias a corregir.</log>
<log Date="03/02/2021" Author="jdarellano">Se agregan validaciones para crear y eliminar tablas temporales.</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN TRY

declare @IdAgent int

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)

/*
		SELECT IdAgentBalance, IdAgent, DateOfMovement, Balance,
			   CASE WHEN DebitOrCredit = 'Debit'  THEN Amount ELSE 0	END DebitAmount,
			   CASE WHEN DebitOrCredit = 'Credit' THEN Amount ELSE 0	END CreditAmount,				 
			ROW_NUMBER()  OVER (PARTITION BY IdAgent ORDER BY IdAgentBalance desc) rw
			INTO #cteData  
		FROM [dbo].[AgentBalance] bl with (nolock)
		WHERE DateOfMovement >= @BeginDate 
			
		
		
		SELECT
			   ag.idAgent as IdAgent,ag.AgentCode as AgentCode,c1.IdAgentBalance as IdAgentBalance,
			   c2.Balance + (c1.DebitAmount - c1.CreditAmount) as Calculado,c1.Balance as Registrado,c1.DateOfMovement as DateOfMovement
		 into #TmpTest
		 from #cteData c1 with(nolock)
		 INNER JOIN #cteData c2 ON c1.IdAgent = c2.IdAgent AND c1.rw = c2.rw-1
		 INNER JOIN Agent ag ON c1.IdAgent = ag.IdAgent
		 WHERE (c2.Balance + (c1.DebitAmount - c1.CreditAmount) ) != c1.Balance
			and c1.IdAgentBalance not in(16057404,16057405,16057951)--AgentCode:2848-TX; Acomodo por fecha
			and c1.IdAgentBalance not in(16085879,16085882,16085980)--AgentCode:3128-FL; Acomodo por fecha
			and c1.IdAgentBalance not in(16636971,16636973,16636991)--AgentCode:2657-GA; Acomodo por fecha  
	 	 order by c1.IdAgent


		select distinct IdAgent 
		into #Agent
		from #TmpTest
		--where IdAgent=4226
		order by IdAgent


		if exists(select 1 from #Agent)
		begin
			declare @idag int

			while exists (select 1 from #Agent)
			begin
	
				set @idag=(select top 1 IdAgent from #Agent)

				exec Soporte.sp_FixAgentBalanceByIdAgent @idag,@BeginDate

				delete from #Agent where IdAgent=@idag
			end

			drop table #Agent
			drop table #TmpTest
		end

		else
		begin
			drop table #Agent
			drop table #TmpTest
		end
*/
--{--#1
	IF OBJECT_ID('tempdb..#Agents') IS NOT NULL DROP TABLE #Agents
	select distinct idagent
	into #Agents
	from dbo.Agentbalance with (nolock)
	WHERE DateOfMovement >= @BeginDate 

	IF OBJECT_ID('tempdb..#tmpAgentBalanceVal') IS NOT NULL DROP TABLE #tmpAgentBalanceVal
	create table #tmpAgentBalanceVal
	(
	id			   int identity (1,1),--#1
	IdAgentBalance INT NOT NULL,
	IdAgent        INT NOT NULL,
	TypeOfMovement NVARCHAR (max) NOT NULL,
	DateOfMovement DATETIME NOT NULL,
	Amount         MONEY NOT NULL,
	Reference      NVARCHAR (max) NOT NULL,
	[Description]  NVARCHAR (max) NOT NULL,
	Country        NVARCHAR (max) NOT NULL,
	Commission     MONEY NOT NULL,
	DebitOrCredit  NVARCHAR (max) NOT NULL,
	Balance        MONEY NOT NULL,
	IdTransfer     INT NULL,
	FxFee          MONEY NOT NULL,
	IsMonthly      BIT DEFAULT ((0)) NULL
	)

		
	IF OBJECT_ID('tempdb..#TmpAgBalVal') IS NOT NULL DROP TABLE #TmpAgBalVal
	create table #TmpAgBalVal
	(
	Balance1	   money not null,
	id			   int,--#1
	IdAgentBalance INT NOT NULL,
	IdAgent        INT NOT NULL,
	TypeOfMovement NVARCHAR (max) NOT NULL,
	DateOfMovement DATETIME NOT NULL,
	Amount         MONEY NOT NULL,
	Reference      NVARCHAR (max) NOT NULL,
	[Description]  NVARCHAR (max) NOT NULL,
	Country        NVARCHAR (max) NOT NULL,
	Commission     MONEY NOT NULL,
	DebitOrCredit  NVARCHAR (max) NOT NULL,
	Balance        MONEY NOT NULL,
	IdTransfer     INT NULL,
	FxFee          MONEY NOT NULL,
	IsMonthly      BIT DEFAULT ((0)) NULL
	)

	declare @Max int
	declare @Ids int
	declare @Balance1 money
	declare @Balance money
	declare @Num1 int
	
	while exists (select 1 from #Agents)
	begin
		set @IdAgent=(select top 1 IdAgent from #Agents)

		INSERT INTO #tmpAgentBalanceVal
			SELECT * 
			FROM dbo.AgentBalance with (nolock)
			WHERE IdAgent=@IdAgent
				and DateOfMovement>=@BeginDate
			ORDER BY DateOfMovement

		set @Max=(select MAX(id) from #tmpAgentBalanceVal)--#1
		set @Ids=1

		while (@Ids<=@Max)
		begin
			if (@Ids=1)
			begin
				set @Balance1=0.00

				insert into #TmpAgBalVal
					SELECT Balance1=@Balance1,* 
					FROM #tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
					ORDER BY DateOfMovement

				set @Ids=@Ids+1
			end

			else
			begin
				insert into #TmpAgBalVal
					SELECT Balance1=(SELECT sum (Amount*CASE WHEN DebitOrCredit='Credit' THEN -1 ELSE 1 END) FROM #tmpAgentBalanceVal ab2 WHERE ab2.IdAgent =ab.idAgent AND ab2.IdAgentBalance = ab.idAgentBalance)+
						(select Balance FROM #tmpAgentBalanceVal ab where id=(@Ids-1)) ,* 
					FROM #tmpAgentBalanceVal ab WHERE IdAgent=@IdAgent and id=@Ids
					ORDER BY DateOfMovement

				set @Ids=@Ids+1
			end
		end 

		set @Num1=2

		while (@Num1<=@Max)
		begin
	
		set @Balance=(select Balance from #TmpAgBalVal where id=@Num1)

			if (@Balance != (select Balance1 from #TmpAgBalVal where id=@Num1))
			begin
				set @Num1=@Max

				if not exists (select 1 from Soporte.AgentToCorrect with (nolock) where IdAgent=@IdAgent)--{#3
				begin
					insert into Soporte.AgentToCorrect (IdAgent,[Begin]) values (@IdAgent,@BeginDate)
				end

				else
				begin
					if exists (select 1 from Soporte.AgentToCorrect with (nolock) where IdAgent=@IdAgent and @BeginDate<(select top 1 [Begin] from Soporte.AgentToCorrect with (nolock) where IdAgent=@IdAgent order by [Begin] desc))
					begin
						update Soporte.AgentToCorrect set [Begin]=@BeginDate where IdAgent=@IdAgent
					end
				end--}#3

				set @Num1=@Max
			end

			set @Num1=@Num1+1
		end

		truncate table #tmpAgentBalanceVal
		truncate table #TmpAgBalVal

		delete from #Agents where IdAgent=@IdAgent
	end

	IF OBJECT_ID('tempdb..#Agents') IS NOT NULL DROP TABLE #Agents

	IF OBJECT_ID('tempdb..#tmpAgentBalanceVal') IS NOT NULL DROP TABLE #tmpAgentBalanceVal
	IF OBJECT_ID('tempdb..#TmpAgBalVal') IS NOT NULL DROP TABLE #TmpAgBalVal


	declare @CorrectCorrection bit, @CorrectCorrection2 bit--#2

	declare @AgentCorrected table
	(
		IdAgent int,
		AgentCode varchar(20),
		BeginDate date
	)

	if exists(select 1 from Soporte.AgentToCorrect with (nolock))
	begin
		declare @idag int
		declare @Beg date
		declare @AgCode varchar(20)

		while exists (select 1 from Soporte.AgentToCorrect with (nolock))
		begin
	
			select top 1 @idag=IdAgent,@Beg=[Begin] from Soporte.AgentToCorrect with (nolock)

			exec Soporte.sp_FixAgentBalanceByIdAgent @idag,@Beg

			exec Soporte.sp_ValidateAgentBalanceByIdAgent_alt @idag,@Beg,@IsCorrect=@CorrectCorrection OUTPUT--#2

			if (@CorrectCorrection=0)
			begin
				exec Soporte.sp_FixAgentBalanceByIdAgent_Date @idag,@Beg,@Correct=@CorrectCorrection2 OUTPUT--#2
			end

			if (@CorrectCorrection=1 or @CorrectCorrection2=1)--#2
			begin
				set @AgCode=(select agentcode from dbo.Agent with (nolock) where idagent=@idag)

				insert into @AgentCorrected (IdAgent,AgentCode,BeginDate) values (@idag,@AgCode,@Beg)

				delete from Soporte.AgentToCorrect where IdAgent=@idag
			end--#2
		end

	end

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

	IF EXISTS(SELECT 1 FROM @AgentCorrected)
	BEGIN
		SELECT @XmlFormat = @XmlFormat + N'<h3>Resumen de ajustes de balance realizados</h3>'
		  + '<table id="agents"><theader><tr><th>IdAgent</th><th>AgentCode</th><th>BeginDate</th></tr></theader><tbody>' + 
		CAST((
				SELECT IdAgent AS 'td', '', AgentCode AS 'td', '', BeginDate AS 'td'
				FROM @AgentCorrected
				FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'

		IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
		BEGIN
			SET @Subject = 'Ajuste balance ' + @@SERVERNAME
			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name=@EmailProfile,
			@recipients='notif@maxi-ms.com;',
			--soportemaxi@boz.mx;bozservices@boz.mx;josesoto@boz.mx;mrodriguez@boz.mx;
			@subject=@Subject,
			@body=@XmlFormat,
			@body_format = 'HTML'           
		END
	END

--}--#1
END TRY
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixAgentBalanceSkips',Getdate(),@ErrorMessage+'.|Line: '+CAST(ERROR_LINE() as nvarchar(15)))

	SET @Subject = 'Error en Ajustes de balance ' + @@SERVERNAME
			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name=@EmailProfile,
			@recipients='notif@maxi-ms.com;',
			--soportemaxi@boz.mx;bozservices@boz.mx;josesoto@boz.mx;mrodriguez@boz.mx;
			@subject=@Subject,
			@body=@ErrorMessage

End catch


