CREATE PROCEDURE [Corp].[st_GetAgentStatusHistory]
	@IdAgent INT
AS
/********************************************************************
<Author>?</Author>
<app>?</app>
<Description></Description>

<ChangeLog>
<log Date="05/11/19" Author="jzuniga">Se elimina columna [idReasonClose] ya que no se utiliza</log>
</ChangeLog>
********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgentStatusHistory], [IdUser], [IdAgent], [IdAgentStatus], [DateOfchange], [Note]
	FROM [dbo].[AgentStatusHistory] WITH(NOLOCK)
	WHERE IdAgent = @IdAgent

END 
