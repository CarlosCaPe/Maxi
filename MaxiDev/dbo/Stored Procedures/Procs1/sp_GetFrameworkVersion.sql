-- =============================================
-- Author:		<bortega>
-- Create date: <04/07/2019>
-- Description:	<Shows the versions of the operating system and the equipment framework>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetFrameworkVersion] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Release, [Version] FROM FrameworkVersion with(nolock)
	

END
