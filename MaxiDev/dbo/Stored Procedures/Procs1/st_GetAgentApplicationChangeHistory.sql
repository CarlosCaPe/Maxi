

CREATE PROCEDURE [dbo].[st_GetAgentApplicationChangeHistory]
	@idAgentApplication INT,
	@fieldType NVARCHAR(25)
AS
	/********************************************************************
	<Author>mdelgado</Author>
	<app>MaxiCorp</app>
	<Description>Get History of Agent changes to specific fields.</Description>

	<ChangeLog>
	<log Date="20170630" Author="mDelgado">Creacion del Store</log>
	<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
	</ChangeLog>
	*********************************************************************/
	SET NOCOUNT ON;
BEGIN

	SELECT DateOfChange,ah.FieldData,u.UserName UserLogin
	FROM AgentApplicationsChangeHistory ah with(nolock)
		LEFT JOIN users u with(nolock) ON u.idUser = ah.EnterByIdUser   
	WHERE ah.idAgentApplication = @idAgentApplication
		AND ah.FieldType = @fieldType
	ORDER BY ah.DateOfChange desc

END