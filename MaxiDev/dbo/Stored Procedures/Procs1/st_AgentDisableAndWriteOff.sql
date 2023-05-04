/********************************************************************
<Author> UNKNOW </Author>
<app>SQL JOB</app>
<Description> Cambia el estatus de las agencias de forma automatica y le agrega una nota referente al cambio</Description>

<ChangeLog>
<log Date="14/05/2018" Author="jdarellano" Name="#1">Performance: se mejora proceso de búsqueda de agencias y se establecen tablas temporales.</log>
<log Date="31/08/2018" Author="jresendiz">Agregado de Razon de Cierre</log>
<log Date="08/10/2018" Author="azavala">Merge Cambio Operaciones vs DEV</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_AgentDisableAndWriteOff]
AS
BEGIN TRY
	DECLARE @TimeToWriteOffAndDisableAgent AS INT SELECT @TimeToWriteOffAndDisableAgent=CONVERT(INT,[dbo].[GetGlobalAttributeByName]('TimeToWriteOffAndDisableAgent'))
	DECLARE @Fecha AS DATE SET @Fecha = DATEADD(MONTH,-@TimeToWriteOffAndDisableAgent,GETDATE())
	DECLARE @SystemUser INT	SELECT @SystemUser=convert(INT,[dbo].[GetGlobalAttributeByName]('SystemUserID'))
	DECLARE @Note VARCHAR(MAX) 
	DECLARE @IdAgent INT
	DECLARE @IdStatus INT
	DECLARE @Text AS VARCHAR(40)
	DECLARE @DateOfLastMovement AS DATETIME
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--;WITH 
	--AgentsMovements
	--AS
	--(
	--	SELECT IdAgent, COUNT(DateOfMovement) AS NumMovements FROM AgentBalance 
	--	WHERE DateOfMovement > @Fecha
	--	GROUP BY IdAgent
	--), 
	--AgentsBalance
	--AS
	--(
	--	SELECT 
	--	ISNULL((Select TOP 1 Balance from AgentBalance where IdAgent= A.IdAgent Order by DateOfMovement DESC), 0.00) AS Balance,
	--	ISNULL((Select TOP 1 DateOfMovement from AgentBalance where IdAgent= A.IdAgent Order by DateOfMovement DESC), A.OpenDate) AS DateOfLastMovement,
	--	A.* 
	--	FROM 
	--	AGENT A LEFT JOIN AgentsMovements AS B ON A.IdAgent = B.IdAgent
	--	WHERE A.IdAgentStatus IN (1,4,7) AND NumMovements IS NULL
	--)
	
	SELECT 
	ISNULL((Select TOP 1 Balance from AgentBalance where IdAgent= A.IdAgent Order by DateOfMovement DESC), 0.00) AS Balance,
	ISNULL((Select TOP 1 DateOfMovement from AgentBalance where IdAgent= A.IdAgent Order by DateOfMovement DESC), A.OpenDate) AS DateOfLastMovement,
	A.* 
	into #AgentsBalance--#1
	FROM AGENT A with (nolock)
	WHERE NOT EXISTS (SELECT 1 
		FROM AgentBalance ab with (nolock)
		WHERE DateOfMovement >= @Fecha and a.IdAgent=ab.IdAgent
		GROUP BY IdAgent
		Having COUNT(DateOfMovement)>0)
		and A.IdAgentStatus IN (1,4,7)

	SELECT
	A.IdAgent, 
	CASE A.Balance WHEN 0.00 THEN 2 ELSE 6 END AS IdStatusToChange, 
	A.DateOfLastMovement
	INTO #AgentsToChangeStatus
	FROM #AgentsBalance A with (nolock) WHERE CAST(DateOfLastMovement AS DATE) <= @Fecha

	declare @CategoryClose varchar(35)
	declare @ReasonClose varchar(35)
	SET @CategoryClose = (SELECT Description FROM AgentCategoryClose WHERE IdAgentCategoryClose = 2)
	SET @ReasonClose = (SELECT Description FROM AgentReasonClose WHERE IdReasonClose = 2)


	WHILE (EXISTS (SELECT TOP 1 IdAgent  FROM #AgentsToChangeStatus))
	BEGIN
		SET @IdAgent = (SELECT TOP 1 IdAgent FROM #AgentsToChangeStatus)  
		SELECT TOP 1 @IdStatus = IdStatusToChange, @DateOfLastMovement = DateOfLastMovement FROM #AgentsToChangeStatus WHERE @IdAgent = IdAgent
		IF (@IdStatus = 2)
			SET @Text = @CategoryClose + ' | ' + @ReasonClose + ' | Disable Agent, Last transaction '
		IF (@IdStatus = 6)
			SET @Text = @CategoryClose + ' | ' + @ReasonClose + ' | Write Off Agent, Last transaction '
		SET @Note = @Text + CONVERT(varchar, @DateOfLastMovement,101) + '  ' + CONVERT(varchar, @DateOfLastMovement,108) 
		EXEC [dbo].[st_AgentStatusChange] @IdAgent, @IdStatus, @SystemUser, @Note
		DELETE FROM #AgentsToChangeStatus WHERE IdAgent = @IdAgent
	END

	drop table #AgentsBalance
	drop table #AgentsToChangeStatus

END TRY
BEGIN CATCH
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_AgentDisableAndWriteOff',Getdate(),@ErrorMessage)
END CATCH