-- =============================================
-- Author:		Eneas Salazar
-- Create date: 16/4/2018
-- Description:	Obtiene las rutas donde se guardan los fax por enviar con permisos( 1 con permiso/ 0 sin permiso)
-- =============================================
CREATE PROCEDURE [FAX].[st_GetFaxPathPerm] 
	
AS
BEGIN
	/********************************************************************
	<Author> esalazar </Author>
	<app>WinService InterFax</app>
	<Description> Obtiene los paths a los que tiene permitido acceder </Description>

	<ChangeLog>
	<log Date="02/05/2018" Author="esalazar">Creacion</log>
	</ChangeLog>
	*********************************************************************/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [Value]   
	FROM [dbo].[GlobalAttributes] as GA
   INNER JOIN [FAX].[FolderPermissions] as Inter ON GA.Name=Inter.TipoFax
   WHERE 1 = 1
	 AND Inter.PermisoInterfax=1
END
