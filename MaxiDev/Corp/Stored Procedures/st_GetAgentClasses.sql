﻿CREATE PROCEDURE [Corp].[st_GetAgentClasses]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT [IdAgentClass], [Name], [Description]
    FROM [dbo].[AgentClass] WITH(NOLOCK)

END 



