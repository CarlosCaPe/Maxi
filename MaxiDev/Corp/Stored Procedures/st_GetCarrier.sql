CREATE PROCEDURE [Corp].[st_GetCarrier] 
	@IdCarrier int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCarrier], [Name], [Email]
	FROM [dbo].[Carriers] WITH(NOLOCK)
	WHERE IdCarrier = @IdCarrier

END
