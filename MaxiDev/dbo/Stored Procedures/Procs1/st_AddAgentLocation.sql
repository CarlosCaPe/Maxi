
CREATE PROCEDURE st_AddAgentLocation
	@idAgent int,
	@lat nvarchar(max),
	@lng nvarchar(max),
	@address nvarchar(max)
AS
BEGIN
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="09/02/2017" Author="mdelgado">Add new AgentLocation to registered agent.</log>
</ChangeLog>
********************************************************************/
	SET NOCOUNT ON;
    INSERT INTO AGENTLOCATION (idAgent, latitude, length , addressFormatted   ) values (@idAgent, @lat,@lng,@address);

END
