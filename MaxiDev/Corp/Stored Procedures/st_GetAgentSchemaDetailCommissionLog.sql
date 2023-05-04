CREATE PROCEDURE [Corp].[st_GetAgentSchemaDetailCommissionLog]
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
	
	SELECT U.UserName ,C.DateOfLastChange, co.CommissionName 
	FROM  [dbo].AgentSchemaDetailCommissionLog C with (NOLOCK)
		JOIN Users U with (nolock) ON C.EnterByIdUser =U.IdUser
		JOIN Commission co with (nolock) ON C.IdCurrentCommission = co.IdCommission
	WHERE IdAgentSchema=@IdAgentSchema
		AND IdPayerConfig=@IdPayerConfig
	ORDER BY C.DateOfLastChange DESC
