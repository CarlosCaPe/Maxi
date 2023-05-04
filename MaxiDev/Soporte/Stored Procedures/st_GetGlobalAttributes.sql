


-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-07
-- Description:	Returns global attributes all or filtered by name
-- =============================================
CREATE PROCEDURE [Soporte].[st_GetGlobalAttributes]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		[Name]
		, [Value]
		, [Description]
	FROM [dbo].[GlobalAttributes] WITH (NOLOCK)
	

END

