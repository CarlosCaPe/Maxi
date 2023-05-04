CREATE PROCEDURE [Corp].[st_GetCallHistoryRegreats] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCallRegreats], [Name], [DateOfLastChange], [EnterByIdUser]
	FROM [dbo].[CallRegreats] WITH(NOLOCK)

END 
