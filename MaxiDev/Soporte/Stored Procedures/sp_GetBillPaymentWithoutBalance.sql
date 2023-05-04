
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <28 de julio de 2017>
-- Description:	<Procedimiento almacenado que identifica pagos de "Bill's" (BillPayment) que no afectaron balance.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_GetBillPaymentWithoutBalance]
@BeginDate dateTime=null
AS            
BEGIN 

	if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


	SET NOCOUNT ON;   
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		
		SELECT a.idAgent,a.AgentCode,BT.IdBillPayment
		FROM [BillPaymentTransactions] BT with(nolock)
		INNER JOIN [Agent] A with(nolock) ON BT.IdAgent = A.IdAgent
		left join agentbalance AB(nolock) on AB.IdTransfer=BT.IdBillPayment and AB.IdAgent =BT.IdAgent and AB.typeofmovement ='bp'  and AB.DateOfMovement>=@BeginDate
	    WHERE BT.[Status] IN (1,2) 
		  AND BT.PaymentDate >= @BeginDate
		  AND AB.IdAgentBalance is null
 

END







