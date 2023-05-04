
CREATE PROCEDURE [BillPayment].[st_GetAgentSchemaDetailFeeOtherProductsLog]

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

	SELECT  U.UserName ,C.DateOfLastChange, f.FeeName

	FROM AgentSchemaDetailFeeLog C (NOLOCK)

		JOIN Users U (NOLOCK) ON C.EnterByIdUser =U.IdUser

		JOIN FeeByOtherProducts f (NOLOCK) ON c.IdCurrentFee = f.IdFeeByOtherProducts

	WHERE IdAgentSchema=@IdAgentSchema

		AND IdPayerConfig=@IdBiller

		AND IdAgent = @IdAgent

	ORDER BY C.DateOfLastChange DESC
