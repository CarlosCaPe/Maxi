

create PROCEDURE [BillPayment].[st_CanValidateCancelBillPayment]
(
   @IdProductTransfer int
   , @CodeResponse nvarchar(50)
)
AS 
/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>Validate If Can called payment</Description>

<ChangeLog>
<log Date="29/10/2018" Author="Amoreno">Creacion del Store</log>

</ChangeLog>
*********************************************************************/
BEGIN
 

	declare 
   @IdStatusBill   int
   , @IdStatusMaxi int 
   , @CanCancel   bit


	
	
set  @IdStatusBill = (	select IdStatus from	 [BillPayment].[TransferR] [TR] WITH (NOLOCK)	where IdProductTransfer=@IdProductTransfer	)
set  @IdStatusMaxi = (	select IdStatusMaxi from  [BillPayment].ResPonseCodesAggregator  [TR] WITH (NOLOCK)	 where TypeMovent='Cancel Bill Payment' and  [ReturnCode] =@CodeResponse)
	
 if (@IdStatusBill=30 and  @IdStatusMaxi=22)
  begin
  set  @CanCancel=1
  end
 else
  begin
   set  @CanCancel=0	
  end
  
 select @CanCancel   as CanCancel
  
	 
end


