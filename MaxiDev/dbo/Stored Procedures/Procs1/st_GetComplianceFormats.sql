-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-14
-- Description:	Return Compliance Formats catalog
-- =============================================
CREATE PROCEDURE [dbo].[st_GetComplianceFormats]
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
	FROM [dbo].[ComplianceFormat]

END
