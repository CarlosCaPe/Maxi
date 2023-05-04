CREATE PROCEDURE [dbo].[st_GetAgentChangeHistory]
	@idAgent INT,
	@fieldType NVARCHAR(25)
AS
BEGIN
	/********************************************************************
	<Author>Francisco Lara</Author>
	<app>MaxiCorp</app>
	<Description>Get History of Agent changes to specific fields.</Description>

	<ChangeLog>
	<log Date="14/03/2017" Author="mDelgado">Creacion del Store</log>
	<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
	</ChangeLog>
	*********************************************************************/
	SET NOCOUNT ON;

	SELECT DateOfChange,ah.FieldData,u.UserName UserLogin,FromAgentApplication
	FROM AgentChangeHistory ah with(nolock)
		LEFT JOIN users u with(nolock) ON u.idUser = ah.EnterByIdUser   
	WHERE ah.idAgent = @idAgent
		AND ah.FieldType = @fieldType
	ORDER BY ah.DateOfChange desc

END
