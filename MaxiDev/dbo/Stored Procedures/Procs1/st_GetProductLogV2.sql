CREATE PROCEDURE [dbo].[st_GetProductLogV2] 
(
	@idAgent INT = NULL,
	@idProduct INT = NULL,
	@fromDate DATE = NULL,
	@toDate DATE = NULL
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@idAgent = 0)
		BEGIN
			SELECT A.AgentCode, A.AgentName, IdAgentStatus, A.IdAgent, PL.[idAgent], [id], [idProduct], [Description],
				   Visible, IdOtherProducts, [logDate], [Provider], [Operation], [Message], [Request], [Response]
			FROM [dbo].[ProductsLog] PL WITH(NOlOCK)
			INNER JOIN OtherProducts OP WITH(NOLOCK) ON PL.idProduct = OP.IdOtherProducts
			INNER JOIN Agent A WITH(NOLOCK) ON PL.idAgent = A.IdAgent
			WHERE ISNULL(idProduct, 0) = ISNULL(@idProduct, 0) AND
				  logDate >= ISNULL(@fromDate, logDate) AND logDate <= ISNULL(@toDate, logDate)
		END
	ELSE
		BEGIN
			SELECT A.AgentCode, A.AgentName, IdAgentStatus, A.IdAgent, PL.[idAgent], [id], [idProduct], [Description],
				   Visible, IdOtherProducts, [logDate], [Provider], [Operation], [Message], [Request], [Response]
			FROM [dbo].[ProductsLog] PL WITH(NOlOCK)
			INNER JOIN OtherProducts OP WITH(NOLOCK) ON PL.idProduct = OP.IdOtherProducts
			INNER JOIN Agent A WITH(NOLOCK) ON PL.idAgent = A.IdAgent
			WHERE ISNULL(PL.idAgent, 0) = ISNULL(@idAgent, PL.idAgent) AND
				  ISNULL(idProduct, 0) = ISNULL(@idProduct, 0) AND
				  logDate >= ISNULL(@fromDate, logDate) AND logDate <= ISNULL(@toDate, logDate)
		END
END
