/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="03/08/2023" Author="jfresendiz">Se crea SP</log>
</ChangeLog>
********************************************************************/
CREATE   PROCEDURE [MoneyOrder].[st_GetConfigurationAgentMoneyOrder]
(
	@IdAgent INT
)
AS
BEGIN
	SELECT IdAgent, PIN, TransactionFee, IdGenericStatus, TransactionFeeTop, TransactionFeeBottom, CommissionToAgent, VerifySequence 
	FROM MoneyOrder.AgentRegistration WITH(NOLOCK)
	WHERE IdAgent = @IdAgent
END