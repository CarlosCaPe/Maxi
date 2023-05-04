CREATE PROCEDURE [Corp].[st_GetCallHistoryStatuses] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCallStatus], [Name], [Description], [DateOfLastChange], [EnterByIdUser], [VisibleToUser]  
	FROM [dbo].[CallStatus] WITH(NOLOCK)

END 
