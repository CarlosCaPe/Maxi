
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <28 de julio de 2017>
-- Description:	<Procedimiento almacenado que realiza la afección en balance de los "Bill's" (BillPayment) que no afectaron balance del día anterior.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_FixBillPaymentWithoutBalance]
	@BeginDate dateTime=null,
	@IsVisible bit=0
AS     

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN TRY

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


		SELECT a.idAgent,a.AgentCode,BT.IdBillPayment
		into #TmpTest
		FROM [BillPaymentTransactions] BT with(nolock,index(PK__BillPaym__40482663162F4418))
        INNER JOIN [Agent] A ON BT.IdAgent = A.IdAgent
		left join agentbalance AB on AB.IdTransfer=BT.IdBillPayment and AB.IdAgent =BT.IdAgent and AB.typeofmovement ='bp'  and AB.DateOfMovement>=@BeginDate
	    WHERE BT.STATUS IN (1,2) 
		  AND BT.PaymentDate >= @BeginDate
		  AND AB.IdAgentBalance is null 
			
		if (@IsVisible=1)
		begin
			select * from #TmpTest
		end
		
		select distinct IdBillPayment 
		into #BillPayment
		from #TmpTest
		order by IdBillPayment


		if exists(select 1 from #BillPayment)
		begin
			declare @idbp int

			while exists (select 1 from #BillPayment)
			begin
	
				set @idbp=(select top 1 IdBillPayment from #BillPayment)

				exec Soporte.sp_FixBillPaymentWithoutBalanceByIdBillPayment @idbp

				if (@IsVisible=1)
				begin
					select * from AgentBalance(nolock)
					where Reference=@idbp
					and TypeOfMovement='BP'
				end

				delete from #BillPayment where IdBillPayment=@idbp
			end

			drop table #BillPayment
			drop table #TmpTest
		end

		else
		begin
			drop table #BillPayment
			drop table #TmpTest
		end


END TRY
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixBillPaymentWithoutBalance',Getdate(),@ErrorMessage)
End catch


