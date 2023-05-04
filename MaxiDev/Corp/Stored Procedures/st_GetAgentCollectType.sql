CREATE PROCEDURE [Corp].[st_GetAgentCollectType]
	-- Add the parameters for the stored procedure here
(
@forcomission bit   
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="17/12/2019" Author="jzuniga">Add Id 5 in WHERE NOT IN</log>
<log Date="14/01/2020" Author="omurillo">Comparador para mostrar id 5</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @forcomission = 1
	begin
	SELECT
		[IdAgentCollectType]
		, [Name]
	FROM [dbo].[AgentCollectType] with(nolock)
	WHERE [IdAgentCollectType] NOT IN (9)
		AND IdStatus = 1
	end
	ELSE
	 begin
	 	SELECT
		[IdAgentCollectType]
		, [Name]
		FROM [dbo].[AgentCollectType] with(nolock)
		WHERE [IdAgentCollectType] NOT IN (9, 5)
			AND IdStatus = 1
	 end
END

