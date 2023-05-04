CREATE PROCEDURE [Corp].[st_GetKYCActor]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdActor], [Name], [Display]
	FROM [dbo].[KYCActor] WITH(NOLOCK)

END

