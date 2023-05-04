CREATE PROCEDURE [Corp].[st_GetCountyClassNameByCounty] 
	@IdCounty INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT RCCC.[IdRelationCountyCountyClass], RCCC.[IdCounty], RCCC.[IdCountyClass], CC.[IdCountyClass], CC.[CountyClassName], CC.[DateOfLastChange], CC.[EnterByIdUser]
	FROM [dbo].[RelationCountyCountyClass] AS RCCC WITH(NOLOCK)
		LEFT JOIN [CountyClass] AS CC WITH(NOLOCK) ON RCCC.IdCountyClass = CC.IdCountyClass
	WHERE RCCC.IdCounty = @IdCounty
END
