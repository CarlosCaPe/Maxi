CREATE PROCEDURE [InternalSalesMonitor].[st_GetNoteTypes] 
	-- Add the parameters for the stored procedure here
	@IdNoteType INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdNoteType = 0)
	BEGIN
		SET @IdNoteType = NULL;
	END
	
	SELECT 
		[IdNoteType]
		,[NoteType]
	FROM [InternalSalesMonitor].[NoteTypes] WITH(NOLOCK)
			WHERE IdNoteType = ISNULL(@IdNoteType,IdNoteType)
	ORDER BY IdNoteType;

END


