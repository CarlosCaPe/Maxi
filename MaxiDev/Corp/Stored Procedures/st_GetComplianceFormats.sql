CREATE PROCEDURE [Corp].[st_GetComplianceFormats]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[ComplianceFormatId]
		,[DisplayName]
		,[FileOfName]
	FROM [dbo].[ComplianceFormat] WITH(NOLOCK)

END

