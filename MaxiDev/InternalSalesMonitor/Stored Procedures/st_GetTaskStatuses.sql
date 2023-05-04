CREATE PROCEDURE [InternalSalesMonitor].[st_GetTaskStatuses] 
	-- Add the parameters for the stored procedure here
	@IdTaskStatus INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdTaskStatus = 0)
	BEGIN
		SET @IdTaskStatus = NULL;
	END
	
	SELECT [IdTaskStatus]
		,[TaskStatus]
	FROM [InternalSalesMonitor].[TaskStatuses] WITH(NOLOCK)
			WHERE IdTaskStatus = ISNULL(@IdTaskStatus,IdTaskStatus)
	ORDER BY IdTaskStatus DESC;

END



