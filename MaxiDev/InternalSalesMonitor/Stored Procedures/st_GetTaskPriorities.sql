CREATE PROCEDURE [InternalSalesMonitor].[st_GetTaskPriorities] 
	-- Add the parameters for the stored procedure here
	@IdTaskPriority INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdTaskPriority = 0)
	BEGIN
		SET @IdTaskPriority = NULL;
	END
	
	SELECT [IdTaskPriority]
		  ,[TaskPriority]
	FROM [InternalSalesMonitor].[TaskPriorities] WITH(NOLOCK)
			WHERE IdTaskPriority = ISNULL(@IdTaskPriority,IdTaskPriority)
	ORDER BY IdTaskPriority DESC;

END


