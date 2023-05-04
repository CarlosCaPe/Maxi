CREATE PROCEDURE [dbo].[st_GetAgentSchemaDetailSpreadLog]
(
	@IdAgentSchema INT
	,@IdPayerConfig INT
)
AS
	/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="05/04/2017" Author="dalmeida">Se modifica join con IdSpread </log>
</ChangeLog>
*********************************************************************/

	SELECT U.UserName ,C.DateOfLastChange, SpreadName= isnull(s.SpreadName,Convert(VARCHAR,c.CurrentSpreadValue))
	FROM AgentSchemaDetailSpreadLog C (NOLOCK)
		JOIN Users U (NOLOCK) ON C.EnterByIdUser =U.IdUser
		LEFT JOIN Spread s (NOLOCK) ON ISNULL(C.IdCurrentSpreadValue,0) = ISNULL(s.IdSpread,0)
	WHERE IdAgentSchema=@IdAgentSchema
		AND IdPayerConfig=@IdPayerConfig
	ORDER BY C.DateOfLastChange DESC

