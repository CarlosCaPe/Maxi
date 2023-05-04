CREATE procedure [Corp].[st_GetCustomerTransactionHistory]  
@IdTransfer int
, @BeginDate datetime  =null  
as  
/********************************************************************
<Author>Desconocido</Author>
<app>Corporate</app>
<Description>Historial del cliente</Description>

<ChangeLog>
<log Date="01/03/2017" Author="jmoreno">Se modifica de que la consulta se en vez de 1 mes 3 años.</log>
<log Date="27/06/2017" Author="jvelarde">modificacion</log>
<log Date="01/07/2017" Author="jdarellano" Name="#1">modificacion para que tome 30 días</log>

</ChangeLog>

*********************************************************************/  

/*
 
Example:

 execute  st_GetCustomerTransactionHistory
   @IdTransfer =9974560 


*/  
  
  
  
declare @IdStatusRejected int  
set @IdStatusRejected =31  
  
declare @IdStatusCancelled int  
set @IdStatusCancelled =22  
  
declare @IdCustomer int  
set @IdCustomer = ( select IdCustomer from Transfer where IdTransfer =@IdTransfer  
      union  
     select IdCustomer from TransferClosed where IdTransferClosed =@IdTransfer)  
  
declare @EndDate datetime  
select @EndDate = DateOfTransfer from transfer (nolock) where IdTransfer=@IdTransfer
--set @EndDate = dbo.RemoveTimeFromDatetime(DATEADD(DAY,1,GETDATE()))  
if (@EndDate is null)
	select @EndDate = DateOfTransfer from transferclosed (nolock) where IdTransferclosed=@IdTransfer
set @EndDate = dbo.RemoveTimeFromDatetime(DATEADD(DAY,1,@EndDate))  
  
  
--declare @BeginDate datetime  

--if (@BeginDate =null)
--	begin 
--	 set @BeginDate = DATEADD(year,-3,@EndDate)  --#1
--	end 
--

	--if @BeginDate is not null
	--begin
		--set @BeginDate = DATEADD(dd,-30+1,dbo.RemoveTimeFromDatetime(@EndDate))
		set @BeginDate = DATEADD(dd,-31+1,dbo.RemoveTimeFromDatetime(@EndDate))--#1
	--end


	 --set @BeginDate = isnull(@BeginDate, DATEADD(year,-3,@EndDate))

    

--select @IdCustomer, @BeginDate, @EndDate  
  
select  
 IdTransfer,  
 TypeOper,
 DateOfTransfer,  
 CustomerFullName,  
 AgentCode,  
 AmountInDollars,  
 Folio,
 ProviderId  
from (  
 select   
  t.IdTransfer, 'TRAN' TypeOper,
  t.DateOfTransfer,  
  t.CustomerName + ' '+ t.CustomerFirstLastName+ ' ' + t.CustomerSecondLastName CustomerFullName,  
  a.AgentCode,  
  t.AmountInDollars,  
  t.Folio,
  0 ProviderId
  from Transfer t  
   inner join Agent a on t.IdAgent= a.IdAgent  
  where t.IdCustomer = @IdCustomer and  
   t.IdStatus not in (@IdStatusRejected, @IdStatusCancelled) and  
   (t.DateOfTransfer>=@BeginDate and t.DateOfTransfer< @EndDate)  
 union all  
 select   
  t.IdTransferClosed IdTransfer,  'TRAN' TypeOper,
  t.DateOfTransfer,  
  t.CustomerName + ' '+ t.CustomerFirstLastName+ ' ' + t.CustomerSecondLastName CustomerFullName,  
  a.AgentCode,  
  t.AmountInDollars,  
  t.Folio,
  0 ProviderId
  from TransferClosed t  
   inner join Agent a on t.IdAgent= a.IdAgent  
  where t.IdCustomer = @IdCustomer and  
   t.IdStatus not in (@IdStatusRejected, @IdStatusCancelled) and  
   (t.DateOfTransfer>=@BeginDate and t.DateOfTransfer< @EndDate)  
  union all
  select
	IdBillPayment IdTransfer
	, 'BP' TypeOper
	,PaymentDate DateOfTransfer
	,CustomerFirstName+' '+CustomerLastName+' '+CustomerMiddleName CustomerFullName
	,AgentCode
	,ReceiptAmount AmountInDollar
	,IdBillPayment
	,1 ProviderId -- Softgate
  from BillPaymentTransactions b
  join agent a on a.idagent=b.idagent
  where customerid=@IdCustomer and status=1 and PaymentDate>=@BeginDate and PaymentDate<@EndDate

  UNION ALL

	SELECT
		[T].[IdProductTransfer] IdTransfer
		, 'BP' TypeOper
		, [T].[DateOfCreation] DateOfTransfer
		, [T].[CustomerName] + ' ' + [T].[CustomerFirstLastName] + ' ' + [T].[CustomerSecondLastName] CustomerFullName
		, [A].[AgentCode]
		, ([T].[Amount] + [T].[Fee]) AmountInDollar
		, [T].[IdProductTransfer] Folio
		, 14 ProviderId -- Regalii
	FROM [Regalii].[TransferR] [T] WITH (NOLOCK)
	JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [T].[IdAgent] = [A].[IdAgent]
	WHERE [T].[IdCustomer] = @IdCustomer
		AND [T].[IdStatus] = 30 -- PAID
		AND [T].[DateOfCreation] >= @BeginDate
		AND [T].[DateOfCreation] < @EndDate

 )T   
 order by T.DateOfTransfer desc






