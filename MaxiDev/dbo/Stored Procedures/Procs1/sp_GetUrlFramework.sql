-- =============================================
-- Author:		<Brenda Ortega>
-- Create date: <04/07/2019>
-- Description:	<Shows the versions of the operating system and the equipment framework>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetUrlFramework] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select Value AS UrlFramework from GlobalAttributes with(nolock) where name = 'urlFramework'
	

END