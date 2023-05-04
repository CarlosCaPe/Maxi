-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Jun-12
-- Description:	This stored gets Tags
-- =============================================
CREATE PROCEDURE [Teleprompter].[st_GetTags] 
	-- Add the parameters for the stored procedure here
	@IdTag INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdTag = 0)
	BEGIN
		SET @IdTag = NULL;
	END
	
	SELECT 
		[IdTag]
		,[Tag]
		--,[IdGenericStatus]
	FROM [Teleprompter].[FormatTags] WITH(NOLOCK)
			WHERE [IdGenericStatus] = 1 
				AND IdTag = ISNULL(@IdTag,IdTag)
	ORDER BY [Tag] ASC;

END
