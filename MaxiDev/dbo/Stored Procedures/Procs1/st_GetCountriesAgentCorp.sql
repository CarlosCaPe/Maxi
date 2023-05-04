-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-28
-- Description:	Get Countries, this stored is used in agent and corporate
-- =============================================
CREATE PROCEDURE [dbo].[st_GetCountriesAgentCorp]
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[C].[IdCountry]
		, [C].[CountryName]
		--, [C].[CountryCode]
	FROM [dbo].[Country] C WITH (NOLOCK)
	ORDER BY CountryName ASC
END
