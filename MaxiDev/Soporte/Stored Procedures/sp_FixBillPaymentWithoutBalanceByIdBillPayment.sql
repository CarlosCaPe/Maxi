
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <28 de julio de 2017>
-- Description:	<Procedimiento almacenado que inserta pagos de "Bill's" (BillPayment) que no afectaron balance.>
-- =============================================
create PROCEDURE [Soporte].[sp_FixBillPaymentWithoutBalanceByIdBillPayment]
	@IdBillPayment int
AS            
BEGIN TRY

	declare @IdAgent int
	declare @Amount money
	declare @Description varchar(100)
	declare @AgentCommission money
	declare @TypeOfMovement varchar(10)
	declare @Operation varchar(15)
	declare @Cogs money
	declare @Fee money
	declare @BillPaymentProviderFee money
	declare @CorpCommission money


	select	@IdAgent=b.idagent,
			@Amount=ReceiptAmount+fee,
			@Description=BillerPaymentProviderVendorId,
			@AgentCommission=AgentCommission,
			@TypeOfMovement='BP',
			@Operation='Debit',
			@Cogs=ReceiptAmount,
			@Fee=Fee,
			@BillPaymentProviderFee=BillPaymentProviderFee,
			@CorpCommission=CorpCommission 
	from BillPaymentTransactions b 
	join agent a on b.idagent=a.idagent 
	where IdBillPayment=@IdBillPayment

	--select	@IdAgent,
	--		@Amount,
	--		@IdBillPayment,
	--		@IdBillPayment,
	--		@Description,
	--		@AgentCommission,
	--		@TypeOfMovement,
	--		@Operation,
	--		@Cogs,
	--		@Fee,
	--		@BillPaymentProviderFee,
	--		@CorpCommission
	
	/*---Afecta balance---*/
	exec [dbo].[st_OPDebitCreditToAgentBalance] @IdAgent, @Amount, @IdBillPayment, @IdBillPayment, @Description, @AgentCommission, @TypeOfMovement, @Operation, @Cogs, @Fee, @BillPaymentProviderFee, @CorpCommission

	--select * from AgentBalance(nolock)
	--where Reference=@IdBillPayment
	--and TypeOfMovement='BP'

 

END TRY
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixBillPaymentWithoutBalanceByIdBillPayment',Getdate(),@ErrorMessage)
End catch







