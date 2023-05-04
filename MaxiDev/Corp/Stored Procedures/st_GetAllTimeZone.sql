CREATE PROCEDURE [Corp].[st_GetAllTimeZone]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT IdTimeZone, TimeZone from dbo.TimeZone WITH(NOLOCK)

END
