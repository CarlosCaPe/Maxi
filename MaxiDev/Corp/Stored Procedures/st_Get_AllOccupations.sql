-- =============================================
-- Author:		<esalazar>
-- Create date: <2020-09-24>
-- Description:	<Obtiene Ocupaciones>
-- =============================================
create PROCEDURE [Corp].[st_Get_AllOccupations]
	-- Add the parameters for the stored procedure here
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [IdOccupation], [Name], [NameEs] FROM [dbo].[DictionaryOccupation]  with(nolock)
END


