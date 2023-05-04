CREATE PROCEDURE [Corp].[st_GetGroupByFiltersProfit]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FiltersTable AS TABLE(Id INT, Name NVARCHAR(MAX))

	INSERT INTO @FiltersTable VALUES (1,'--No Group By--')
	INSERT INTO @FiltersTable VALUES (2,'Group By Country')
	INSERT INTO @FiltersTable VALUES (3,'Group By Country/Currency')

	SELECT [Id], [Name] FROM @FiltersTable

END
