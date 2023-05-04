﻿CREATE PROCEDURE [dbo].[st_GetAgentStatusV2] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdAgentStatus], [AgentStatus], [DateOfLastChange], [EnterByIdUser], [VisibleForUser]
	FROM [MaxiQA].[dbo].[AgentStatus] WITH(NOLOCK)
	WHERE VisibleForUser = 1

END 



