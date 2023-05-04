CREATE PROCEDURE [dbo].[st_GetAgentSchemaDetailFeeLog]
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
<log Date="28/03/2017" Author="dalmeida">Delete "Top"</log>
</ChangeLog>
*********************************************************************/

	SELECT U.UserName ,C.DateOfLastChange, f.FeeName 
	FROM AgentSchemaDetailFeeLog C (NOLOCK)
		JOIN Users U (NOLOCK) ON C.EnterByIdUser =U.IdUser
		JOIN Fee f (NOLOCK) ON c.IdCurrentFee = f.IdFee
	WHERE IdAgentSchema=@IdAgentSchema
		AND IdPayerConfig=@IdPayerConfig
	ORDER BY C.DateOfLastChange DESC

