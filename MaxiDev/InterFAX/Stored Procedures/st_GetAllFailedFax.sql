-- =============================================
-- Author:		Eneas Salazar
-- Create date: 19/04/2018
-- Description:	Obtiene todos los fax con status de envio fallido
-- =============================================
CREATE PROCEDURE [InterFAX].[st_GetAllFailedFax]

AS
BEGIN
	/********************************************************************
	<Author> esalazar </Author>
	<app>WinService InterFax</app>
	<Description> Obtiene todos los archivos que no se pudieron enviar </Description>

	<ChangeLog>
	<log Date="02/05/2018" Author="esalazar">Creacion</log>
	</ChangeLog>
	*********************************************************************/
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
      [IdInterfax]
      ,[Path]
  FROM [FAX].[InterFaxNotConfirmed]
  WHERE [Status]>0
  AND [IsDel]=0
END
