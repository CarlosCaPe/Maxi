CREATE   PROCEDURE [dbo].[st_GetAgentDocumentsNotSync]
AS
/********************************************************************
<Author>Miguel Prado</Author>
<date>30/01/2023</date>
<app>CorporativeServices.Agents</app>
<Description>Sp para obtener listado de Documentos no sincronizados de Aws S3 </Description>

<ChangeLog>
<log Date="XX/XX/XXXX" Author=""></log>
</ChangeLog>
*********************************************************************/
BEGIN

	SELECT AD.IdDocumentType,
		AD.IdAgent AS IdReference,
		AD.FileName,
		AD.Extension,
		AD.Url
	FROM AgentDocument AD WITH (NOLOCK)
	WHERE IsUpload = 0
	AND IdGenericStatus = 1

END
