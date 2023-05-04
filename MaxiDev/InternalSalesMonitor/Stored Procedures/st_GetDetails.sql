-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Abr-03
-- Description:	This stored gets Details
-- =============================================
CREATE PROCEDURE [InternalSalesMonitor].[st_GetDetails] 
	-- Add the parameters for the stored procedure here
	@IdAgent int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;WITH CTE_Calls AS 
(
	SELECT TOP 1 [IdDetail]
		  ,[IdAgent]
		  ,[ContacName]
		  ,[SendFax]
		  ,[SundayStart]
		  ,[SundayEnd]
		  ,[SundayClosed]
		  ,[MondayStart]
		  ,[MondayEnd]
		  ,[MondayClosed]
		  ,[TuesdayStart]
		  ,[TuesdayEnd]
		  ,[TuesdayClosed]
		  ,[WednesdayStart]
		  ,[WednesdayEnd]
		  ,[WednesdayClosed]
		  ,[ThursdayStart]
		  ,[ThursdayEnd]
		  ,[ThursdayClosed]
		  ,[FridayStart]
		  ,[FridayEnd]
		  ,[FridayClosed]
		  ,[SaturdayStart]
		  ,[SaturdayEnd]
		  ,[SaturdayClosed]

		  --,[EnterByIdUser]
		  --,[CreationDate]

		  --,[LastChangeByIdUser]
		  --,[DateOfLastChange]

		  ,ISNULL([LastChangeByIdUser],[EnterByIdUser]) AS EnterByIdUser
		  ,ISNULL([DateOfLastChange], [CreationDate]) AS DateOfLastChange

	  FROM [InternalSalesMonitor].[Details] WITH(NOLOCK)
				WHERE IdAgent = ISNULL(@IdAgent,IdAgent) ORDER BY [IdDetail] DESC
)SELECT 
	[IdDetail]
	,[IdAgent]
	,[ContacName]
	,[SendFax]
	,[SundayStart]
	,[SundayEnd]
	,[SundayClosed]
	,[MondayStart]
	,[MondayEnd]
	,[MondayClosed]
	,[TuesdayStart]
	,[TuesdayEnd]
	,[TuesdayClosed]
	,[WednesdayStart]
	,[WednesdayEnd]
	,[WednesdayClosed]
	,[ThursdayStart]
	,[ThursdayEnd]
	,[ThursdayClosed]
	,[FridayStart]
	,[FridayEnd]
	,[FridayClosed]
	,[SaturdayStart]
	,[SaturdayEnd]
	,[SaturdayClosed]

	,U.EnterByIdUser
	,U.UserLogin AS EnterByUser

	,CT.DateOfLastChange
FROM CTE_Calls AS CT
		INNER JOIN [dbo].[Users] AS U WITH(NOLOCK) ON CT.[EnterByIdUser]= U.[IdUser]
	ORDER BY CT.IdAgent,CT.DateOfLastChange ASC;

END

