CREATE PROCEDURE [Corp].[st_GetAgentSchemaDetailCommissionOtherProductsLog_BillPayment]

(

	@IdAgentSchema INT

	,@IdBiller INT

	,@IdAgent INT = NULL

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

	SELECT  U.UserName ,C.DateOfLastChange, f.CommissionName

	FROM [dbo].AgentSchemaDetailCommissionLog C (NOLOCK)

		JOIN Users U (NOLOCK) ON C.EnterByIdUser =U.IdUser

		JOIN CommissionByOtherProducts f (NOLOCK) ON c.IdCurrentCommission = f.IdCommissionByOtherProducts

	WHERE IdAgentSchema=@IdAgentSchema

		AND IdPayerConfig=@IdBiller

		and IdAgent = @IdAgent

	ORDER BY C.DateOfLastChange DESC
