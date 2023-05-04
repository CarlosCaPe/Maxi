CREATE PROCEDURE [dbo].[st_GetActiveProducts] (@IdAgent INT) AS

--select * from AgentProducts where IdAgent  =  @IdAgent
SELECT [IdAgent], [IdGenericStatus], [IdOtherProducts] FROM [dbo].[AgentProducts] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent
