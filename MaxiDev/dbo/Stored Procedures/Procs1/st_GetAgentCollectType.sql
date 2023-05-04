-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-06-13
-- Description:	Returns AgentCollectType for CollectionPlanView and Agent Detail
-- =============================================
CREATE PROCEDURE [dbo].[st_GetAgentCollectType]
	-- Add the parameters for the stored procedure here
	
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
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[IdAgentCollectType]
		, [Name]
	FROM [dbo].[AgentCollectType] with(nolock)
	WHERE [IdAgentCollectType] NOT IN (9)

END
