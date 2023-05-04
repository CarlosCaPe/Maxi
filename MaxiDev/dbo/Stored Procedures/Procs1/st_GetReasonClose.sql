/********************************************************************
<Author>  </Author>
<app>Corporativo</app>
<Description> Obtiene el catalogo de razones de cierre  </Description>

<ChangeLog>
<log Date="08//10/2018" Author="jresendiz">Creacion</log>
</ChangeLog>
*********************************************************************/
create PROCEDURE [dbo].[st_GetReasonClose]
	--@Category tinyint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ARC.IdReasonClose, ARC.[Description]
	FROM AgentCategoryClose ACC WITH(NOLOCK)
	INNER JOIN AgentReasonClose ARC WITH(NOLOCK) ON ACC.IdAgentCategoryClose = ARC.IdAgentCategoryClose
END