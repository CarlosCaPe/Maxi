CREATE PROCEDURE [dbo].[st_MaxiAlertD_BillPaymentWithoutBalance]
@BeginDate dateTime=null
AS            
BEGIN 

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		SELECT 'BillPayment sin registro en Balance'  NameValidation, 
			   'AgentId:'+ISNULL(CAST(a.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(a.AgentCode AS  VARCHAR), '')+'; IdBillPayment:'+ISNULL(CAST(BT.IdBillPayment AS  VARCHAR), '') MsgValidation,
			    'Verficacion manual' FixDescription,
				'' Fix
		  FROM [BillPaymentTransactions] BT
         INNER JOIN [Agent] A ON BT.IdAgent = A.IdAgent
		 left join agentbalance AB on AB.IdTransfer=BT.IdBillPayment and AB.IdAgent =BT.IdAgent and AB.typeofmovement ='bp'  and AB.DateOfMovement>=@BeginDate
	     WHERE BT.STATUS IN (1,2) 
		   AND BT.PaymentDate >= @BeginDate
		   AND AB.IdAgentBalance is null
		 

END







