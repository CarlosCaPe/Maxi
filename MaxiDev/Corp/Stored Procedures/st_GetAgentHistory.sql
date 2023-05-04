CREATE PROCEDURE [Corp].[st_GetAgentHistory]
(
	@IdAgent	INT,
	@Page		INT = 1,
	@PageSize	INT,
	@TotalRows	INT OUTPUT
)
AS  
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="17/01/2018" Author="jdarellano" Name="#1">Performance: se agregan with(nolock) y se mejora método de búsqueda.</log>
</ChangeLog>
*********************************************************************/
Set nocount on;
BEGIN TRY

	DECLARE @fromRow INT
	SET @fromRow = @PageSize * (@Page - 1)

	Select DateOfchange, IdAgent, AgentStatus, UserName, Note
	from AgentStatusHistory agsh WITH(NOLOCK)
	join AgentStatus ags WITH(NOLOCK) on agsh.IdAgentStatus = ags.IdAgentStatus
	join Users u WITH(NOLOCK) on agsh.IdUser = u.IdUser
	where IdAgent = @IdAgent
	ORDER BY agsh.DateOfchange DESC
	OFFSET (@fromRow) ROWS
	FETCH NEXT 50 ROWS ONLY
	
	
	Select @TotalRows = count(1)
	from AgentStatusHistory agsh WITH(NOLOCK)
	join AgentStatus ags WITH(NOLOCK) on agsh.IdAgentStatus = ags.IdAgentStatus
	join Users u WITH(NOLOCK) on agsh.IdUser = u.IdUser
	where IdAgent = @IdAgent
	
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetAgentHistory',Getdate(),@ErrorMessage);
End catch

