-- =============================================
-- Author:		<esalazar>
-- Create date: <2020-09-24>
-- Description:	<Obtiene Sub Categorias de Ocupaciones>
-- =============================================
create PROCEDURE [Corp].[st_Get_AllSubOccupations]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [IdSubOccupation],[IdOccupation], [Name], [NameEs] FROM [dbo].[DictionarySubCategoryOccupation]  with(nolock)
END


