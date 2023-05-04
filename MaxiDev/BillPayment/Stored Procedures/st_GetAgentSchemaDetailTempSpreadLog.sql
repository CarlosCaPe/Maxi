	CREATE PROCEDURE [BillPayment].[st_GetAgentSchemaDetailTempSpreadLog]

(

	@IdAgentSchema INT

	,@IdBiller INT

)

AS

	/********************************************************************
<Author>Adominguez</Author>
<app>MaxiCorp</app>
<Description>Guarda y/o actualiza la tabla BillerSchemasAgent
</Description>

<ChangeLog>

<log Date="18/08/2018" Author="adominguez">Creation</log>
</ChangeLog>

--Exec [BillPayment].[st_BillPaymentSchemaSave] 1240,1,34,3,1,1,0,null,9168,0,''
*********************************************************************/

	SELECT  U.UserName ,C.DateOfLastChange, f.CurrentEndDateTempSpread

	FROM AgentSchemaDetailTempSpreadLog C (NOLOCK)

		JOIN Users U (NOLOCK) ON C.EnterByIdUser =U.IdUser

		JOIN AgentSchemaDetailTempSpreadLog f (NOLOCK) ON c.AgentSchemaDetailTempSpreadLogId = f.AgentSchemaDetailTempSpreadLogId

	WHERE c.IdAgentSchema=@IdAgentSchema

		AND c.IdPayerConfig=@IdBiller

	ORDER BY C.DateOfLastChange DESC