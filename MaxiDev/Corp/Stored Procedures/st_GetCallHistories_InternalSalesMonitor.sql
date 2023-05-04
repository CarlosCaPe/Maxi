CREATE PROCEDURE [Corp].[st_GetCallHistories_InternalSalesMonitor]
	@IdAgent INT,
	@IdTaskStatus INT = NULL,
	@IdTaskPriority INT = NULL
AS
	/********************************************************************
	<Author>snevarez</Author>
	<app>MaxiCorp</app>
	<Description>Create Groups Agents</Description>

	<ChangeLog>
		<log Date="03/04/2017" Author="snevarez">s20_17 :: Create </log>
		<log Date="01/06/2017" Author="snevarez">s20_17 :: Ajuste para realizar busquedas globles</log>
		<log Date="02/06/2017" Author="snevarez">s20_17 :: Agregar campos AgentCode y AgentName</log>
	</ChangeLog>
	********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdTaskStatus = 0)
	BEGIN
		SET @IdTaskStatus = NULL;
	END

	IF(@IdTaskPriority = 0)
	BEGIN
		SET @IdTaskPriority = NULL;
	END
	
;WITH CTE_Calls AS 
(
	SELECT CH.[IdCallHistory]
		,CH.[IdAgent]

		,CH.[IdTaskStatus]
		,TS.[TaskStatus]		

		,CH.[IdTaskPriority]
		,TP.[TaskPriority]

		,CH.[Note]

		,ISNULL(CH.[LastChangeByIdUser],CH.[EnterByIdUser]) AS EnterByIdUser
		,ISNULL(CH.[DateOfLastChange], CH.[CreationDate]) AS DateOfLastChange

		,A.AgentCode
		,A.AgentName
	FROM [InternalSalesMonitor].[CallHistory] AS CH WITH(NOLOCK)
		INNER JOIN [InternalSalesMonitor].[TaskStatuses] AS TS WITH(NOLOCK) ON CH.[IdTaskStatus] = TS.[IdTaskStatus]
		INNER JOIN [InternalSalesMonitor].[TaskPriorities] AS TP WITH(NOLOCK) ON CH.[IdTaskPriority] = TP.[IdTaskPriority]
		INNER JOIN [dbo].[Agent] AS A WITH(NOLOCK) ON CH.[IdAgent] = A.[IdAgent]
	WHERE 
		CH.[IdAgent] = (CASE WHEN @IdAgent=0 THEN CH.[IdAgent] ELSE @IdAgent END) /*01/06/2017*/
		AND CH.IdTaskStatus = ISNULL(@IdTaskStatus,CH.IdTaskStatus)
		AND CH.IdTaskPriority = ISNULL(@IdTaskPriority,CH.IdTaskPriority)
)SELECT 
	CT.IdCallHistory
	,CT.IdAgent

	,CT.TaskStatus
	,CT.IdTaskStatus

	,CT.IdTaskPriority
	,CT.TaskPriority

	,CT.Note

	,U.IdUser AS EnterByIdUser
	,U.UserLogin AS EnterByUser

	,CT.DateOfLastChange

	,CT.AgentCode
	,CT.AgentName
FROM CTE_Calls AS CT
		INNER JOIN [dbo].[Users] AS U WITH(NOLOCK) ON CT.[EnterByIdUser]= U.[IdUser]
	ORDER BY CT.IdAgent,CT.DateOfLastChange ASC;

END
