CREATE PROCEDURE [Corp].[st_GetNotesAgentException]
(
	@IdAgent int
	--,@IsException bit OUTPUT
)
AS
Set nocount on

Begin Try

	--SELECT @IsException = ISNULL((SELECT TOP 1 Exception FROM AgentException AS AE WITH(NOLOCK) WHERE IdAgent = @IdAgent ORDER BY IdAgentException DESC),0);

	SELECT 
		AE.IdAgentException,
		AE.IdAgent,
		AE.Exception,
		AE.IdUser,
		AE.Note,
		AE.EnterDate,
		U.UserName
		,CASE Exception WHEN 0 THEN 'Not Exception' ELSE 'Exception' END AS [Status]
	FROM AgentException AS AE WITH(NOLOCK)
		INNER JOIN Users AS U WITH(NOLOCK) ON AE.IdUser = U.IdUser
	WHERE IdAgent = @IdAgent
		ORDER BY IdAgentException DESC;

  End Try
Begin Catch
	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE();
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetNotesAgentException',Getdate(),@ErrorMessage);
End Catch 
   
