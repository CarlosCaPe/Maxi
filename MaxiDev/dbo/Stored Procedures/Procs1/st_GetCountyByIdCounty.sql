CREATE PROCEDURE [dbo].[st_GetCountyByIdCounty] 
	@IdCounty INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdCounty], [IdState], [CountyName], [DateOfLastChange], [EnterByIdUser]
	FROM [dbo].[County] WITH(NOLOCK)
	WHERE IdCounty = @IdCounty

END 

