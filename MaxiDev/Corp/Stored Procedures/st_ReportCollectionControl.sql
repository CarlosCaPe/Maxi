/********************************************************************
<Author></Author>
<app></app>
<Description>Reporte Agent A/R</Description>

<ChangeLog>
<log Date="30/03/2023" Author="jfresendiz">BM-518 Se agrega nueva columna Advance Credit </log>
</ChangeLog>
*********************************************************************/
CREATE procedure [Corp].[st_ReportCollectionControl]  
@BeginDate datetime,                        
@EndDate datetime                        
as                        
                        
/*SET NOCOUNT ON          
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
@BeginDate datetime='2020-06-01',                        
@EndDate datetime='2020-06-30' */                       
            
                SET NOCOUNT ON          
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) Values('st_ReportCollectionControl -> @BeginDate: ' + Convert(varchar(max),@BeginDate) + ', @EndDate: ' + Convert(varchar(max),@EndDate), Getdate(),'INFO')
 --Select                 
 --  1 as IdAgent ,     
 --  '' as Agent ,  
 --  '' as AgentPhone,  
 --  '' as ACH,  
 --  '' as BankName,   
 --  '' as AgentStatus ,    
 --  1 as IdAgentStatus,                      
 --  GETDATE() as DateOfLastDeposit ,                        
 --  GETDATE() as DateOfLastMovement ,                        
 --  1.2 as LastBalance ,                        
 --  5 as NumberTransactions ,                        
 --  2.3 as TransfersAmount ,                        
 --  1.2 as CommissionTransfersAmount ,                        
 --  1.2 as DepositAmount ,                        
 --  1.2 as RejectedAmount ,                        
 --  1.2 as CancelledAmount ,                        
 --  1.2 as OtherChargeAmount,        
 --  3 as OPNum,        
 --  3.1  as OPAmount,        
 --  1.2 as OPComm,        
 --  1.2 as OPCancelled,                        
 --  1.2 as CurrentBalance    ,  
 --  1.2 as InitialCP,  
 --  1.2 as CPMovements,  
 --  1.2 as FinalCP,  
 --  1.2 as  ConsolidatedDebt ,
 --   1 as  IdAgentCurrentStatus,
	--'' AgentCurrentStatusName ,
 --  1.2 as  SpecialCommission                
                        
declare @IAgentStatusDisable int                        
set @IAgentStatusDisable = 2          
  
--declare @IAgentStatusWriteOff int                        
--set @IAgentStatusWriteOff = 6    
        
Declare @Money as Money         
Set @Money=0         

                      
set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                        
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  

declare @EndDate2 datetime
set @EndDate2 = @EndDate
if @EndDate = dbo.RemoveTimeFromDatetime(GETDATE()+1) --es hoy la fecha final?
BEGIN
	set @EndDate2 = @EndDate2 -2
END
else
BEGIN
	set @EndDate2 = @EndDate2 -1 
END
print @EndDate2

/*antes  
Select                         
 A.IdAgent,                        
 A.AgentCode+ ' - '+AgentName Agent,  
 A.IdAgentStatus,                        
 S.AgentStatus,  
 A.AgentPhone,  
 --A.ACHWellsFargo,  
 A.IdAgentCollectType,  
 case (IdAgentCollectType)   
    when 1 then ''   
    when 2 then ''   
    else isnull(D.BankName,'')  
 end BankName,   
 case (A.IdAgentStatus)   
 when 1 then 1  
 when 3 then 3  
 when 4 then 2   
 end  
 AgentOrder,
 A.idAgentPaymentSchema  
 into #agentTemp                        
 from Agent A                      
 inner join AgentStatus S on S.IdAgentStatus = A.IdAgentStatus                        
 left join AgentBankDeposit D on A.IdAgentBankdeposit=D.IdAgentBankdeposit  
 where A.IdAgentStatus!= @IAgentStatusDisable  --and  A.IdAgentStatus!= @IAgentStatusWriteOff        
 */



 --despues
 Select                         
 A.IdAgent,                        
 A.AgentCode+ ' - '+AgentName Agent,  
 f.IdAgentStatus,                        
 S.AgentStatus,  
 A.AgentPhone,  
 --A.ACHWellsFargo,  
 A.IdAgentCollectType,
 case (IdAgentCollectType)   
    when 1 then ''   
    when 2 then ''   
    else isnull(D.BankName,'')  
 end BankName,   
 case (A.IdAgentStatus)   
 when 1 then 1  
 when 3 then 3  
 when 4 then 2   
 end  
 AgentOrder,
 A.idAgentPaymentSchema,
 s2.IdAgentStatus as IdAgentCurrentStatus,
 s2.AgentStatus as AgentCurrentStatusName  
 into #agentTemp   
 from Agent A                        
 join agentfinalstatushistory f on DateOfAgentStatus=@EndDate2 and f.idagent=a.idagent
 inner join AgentStatus S on S.IdAgentStatus = f.IdAgentStatus
 left join AgentBankDeposit D on A.IdAgentBankdeposit=D.IdAgentBankdeposit
 join agentstatus s2 on a.IdAgentStatus = s2.IdAgentStatus
 --where f.IdAgentStatus!= @IAgentStatusDisable  --and  A.IdAgentStatus!= @IAgentStatusWriteOff     
                 
--select @EndDate-2

 Create clustered index idxTemp on  #agentTemp (IdAgent)                       
                 
                        
declare @tResult table                        
(                        
 IdAgent int,                        
 Agent varchar(200),                        
 AgentStatus varchar(20),   
 IdAgentStatus int,  
 AgentPhone varchar(max),  
 AgentOrder int,  
 ACHWellsFargo varchar(20),  
 BankName varchar(max),  
 DateOfLastDeposit datetime,                        
 DateOfLastMovement datetime,                        
 LastBalance money,                        
 NumberTransactions int,                        
 TransfersAmount money,                        
 CommissionTransfersAmount money,                        
 DepositAmount money,    
 RejectedAmount money,                        
 CancelledAmount money,                        
 OtherChargeAmount money,                        
 CurrentBalance money,                        
 DebitOrCredit varchar(50),
 IdAgentPaymentSchema int,
 IdAgentCurrentStatus int,
 AgentCurrentStatusName nvarchar(max),
 FeeCanRFinal		MONEY,
 CashDiscountFinal	MONEY,
 NetFeeFinal		MONEY,
 DCTranFinal		INT,
 MerchantFeeFinal	MONEY,
 TotalFeeFinal		MONEY,
 AdvanceCreditAmount money
)                        
          
 DELETE FROM #agentTemp WHERE IdAgentStatus = @IAgentStatusDisable AND IdAgent NOT IN (SELECT DISTINCT IdAgent FROM AgentBalance where DateOfMovement >= @BeginDate and DateOfMovement < @EndDate)          
		          
 Insert into  @tResult (IdAgent,Agent,AgentStatus,IdAgentStatus,AgentPhone,ACHWellsFargo,BankName,AgentOrder,IdAgentPaymentSchema,IdAgentCurrentStatus,AgentCurrentStatusName)                
 Select IdAgent,Agent,AgentStatus,IdAgentStatus,AgentPhone,case (IdAgentCollectType) when 1 then 'ACH' when 2 then 'ACH with Scanner' else 'Deposit' end,
 BankName,AgentOrder,IdAgentPaymentSchema,IdAgentCurrentStatus,AgentCurrentStatusName 
 from #agentTemp                
      
      
      
--Select A.IdAgent,count(1) as CPNum,SUM(A.Price) as CPAmount, SUM( case when ismonthly=1 then A.Fee else A.CorpCommission end) as CPCommission        
--into #tempCP  from CellularPurchaseTransactions A Join AgentBalance B on (A.Id=B.IdTransfer)        
--join #agentTemp C on (C.IdAgent=A.IdAgent)        
--Where  B.DateOfMovement>=@BeginDate and B.DateOfMovement<@EndDate  and B.TypeOfMovement='CP'        
--Group by A.IdAgent        
      
        
--Select A.IdAgent,count(1) as BPNum,SUM(A.ReceiptAmount) as BPAmount, SUM( case when ismonthly=1 then A.Fee else A.CorpCommission end) as BPCommission        
-- into #tempBP  from BillPaymentTransactions A Join AgentBalance B on (A.IdBillPayment=B.IdTransfer)        
--join #agentTemp C on (C.IdAgent=A.IdAgent)        
--Where  B.DateOfMovement>=@BeginDate and B.DateOfMovement<@EndDate  and B.TypeOfMovement='BP'        
--Group by A.IdAgent        
        
        
--Select A.IdAgent,count(1) as BPNumCancel,SUM(A.ReceiptAmount) as BPAmountCancel, SUM( case when ismonthly=1 then A.Fee else A.CorpCommission end) as BPCommissionCancel        
-- into #tempCBP from BillPaymentTransactions A Join AgentBalance B on (A.IdBillPayment=B.IdTransfer)        
--join #agentTemp C on (C.IdAgent=A.IdAgent)        
--Where  B.DateOfMovement>=@BeginDate and B.DateOfMovement<@EndDate and B.TypeOfMovement='CBP'        
--Group by A.IdAgent        
      
select t0.IdAgent,      
sum (case when t3.IsDebit = 1 then 1 else 0 end) as OPNumTrans,      
sum (case when t3.IsDebit = 0 then 1 else 0 end) as OPNumCancels,      
sum (case when t3.IsDebit = 1 then t2.TotalAmount else 0 end) as OPAmount,      
sum (case when t3.IsDebit = 0 then t2.TotalAmount else 0 end) as OPAmountCancel,      
sum (case when t1.IsMonthly = 1 then t2.Fee else t1.Commission end) as OPCommission      
into #tempOP
from #agentTemp t0
join  AgentBalance t1 with(nolock) on t0.idAgent = t1.idAgent
join AgentBalanceDetail t2 with(nolock) on t1.IdAgentBalance = t2.IdAgentBalance
join AgentBalanceHelper t3 with(nolock) on (t1.typeofMovement = t3.typeofmovement)
inner join operation.ProductTransfer as op with (nolock) on t1.IdTransfer=op.IdProductTransfer and t3.IdOtherProduct=op.IdOtherProduct--#2
where (t1.DateOfMovement >= @BeginDate and t1.DateOfMovement < @EndDate) AND T3.[IdOtherProduct] != 15 -- Checks view like Deposits       
group by t0.idAgent      
        
                 
 Select Count(1) as TransferNum,isNull(Sum(AmountInDollars),0) as TransferAmount,A.IdAgent,isnull(Sum(TotalAmountToCorporate-AmountInDollars),0) as Commission,
 	isnull(sum(A.OperationFee - A.Discount), 0) MerchantFee, isnull(sum(A.Fee - A.Discount), 0) AS NetFee, isnull(sum(A.Discount), 0) AS CashDiscount,
 	sum(CASE WHEN A.IdPaymentMethod = 2 THEN 1 ELSE 0 END) AS DCTr, isnull(sum(A.Fee), 0) AS Fee                 
 into #temp1                
 from Transfer A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateOfTransfer>=@BeginDate and DateOfTransfer<@EndDate                  
 Group by A.IdAgent 
 
               
                
               
 Select Count(1) as TransferNumRejected,isNull(Sum(TotalAmountToCorporate),0) as TransferAmountRejected,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionRej,
 	isnull(sum(A.Fee), 0) AS FeeRej
 into #temp21                
 from Transfer A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate              
 and IdStatus in (31)                  
 Group by A.IdAgent 
                
               
               
 Select Count(1) as TransferNumCancelled,isNull(Sum(AmountInDollars),0) as TransferAmountCancelled,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionCan,
 	isnull(sum(A.Fee), 0) AS FeeCan            
 into #temp22                
 from Transfer A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate              
 and IdStatus in (22)                  
 Group by A.IdAgent 
                
               
               
                 
 Select Count(1) as TransferNumClosed,isnull(Sum(AmountInDollars),0) as TransferAmountClosed,A.IdAgent,isnull(Sum(TotalAmountToCorporate-AmountInDollars),0) as CommissionClosed,
 	isnull(sum(A.OperationFee - A.Discount), 0) MerchantFeeClosed, isnull(sum(A.Fee - A.Discount), 0) AS NetFeeClosed, isnull(sum(A.Discount), 0) AS CashDiscountClosed,
 	sum(CASE WHEN A.IdPaymentMethod = 2 THEN 1 ELSE 0 END) AS DCTrClosed, isnull(sum(A.Fee), 0) AS FeeClosed                
 into #temp2                
 from TransferClosed A with(nolock) Join  #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateOfTransfer>=@BeginDate and DateOfTransfer<@EndDate                  
 Group by A.IdAgent 
               
               
               
 Select Count(1) as TransferNumClosedRejected,isNull(Sum(TotalAmountToCorporate),0) as TransferAmountClosedRejected,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionClosedRej,
 	isnull(sum(A.Fee), 0) AS FeeClosedRejected
 into #temp23                
 from TransferClosed A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)       
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate              
 and IdStatus in (31)                  
 Group by A.IdAgent 
               
               
               
 Select Count(1) as TransferNumClosedCancelled,isNull(Sum(AmountInDollars),0) as TransferAmountClosedCancelled,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionClosedCan,
 	isnull(sum(A.Fee), 0) AS FeeClosedCancelled
 into #temp24                
 from TransferClosed A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate              
 and IdStatus in (22)                  
 Group by A.IdAgent 
 
                 
               
      
Select isNull(Sum(Case when DebitOrCredit='Debit' Then A.Amount Else A.Amount*-1 End),0) as TransferAmountCancelledBalance,A.IdAgent    
 into #temp25      
 from AgentBalance A with(nolock) Join #agentTemp B on (A.IdAgent=B.IdAgent)                
 where A.DateOfMovement>=@BeginDate and A.DateOfMovement<@EndDate              
 and A.TypeOfMovement='CANC'              
 Group by A.IdAgent                
    
    
                 
 Select isnull(Sum(Amount),0) as Deposit,A.IdAgent                 
 into #temp9                
 from AgentDeposit A with(nolock) Join  #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateOfLastChange>=@BeginDate and DateOfLastChange<@EndDate                
 Group by A.IdAgent  
 
 Select isnull(Sum(Amount),0) as AdvanceCredit,A.IdAgent                 
 into #temp91                
 from AgentDeposit A with(nolock) Join  #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateOfLastChange>=@BeginDate and DateOfLastChange<@EndDate                
 Group by A.IdAgent  
                 
                
 Select isnull(Sum(case when DebitOrCredit='Credit' Then Amount else Amount*-1 end),0) as OtherCharge,A.IdAgent                 
 into #temp10                
 from AgentBalance A with(nolock) Join  #agentTemp B on (A.IdAgent=B.IdAgent)                
 where DateOfMovement>=@BeginDate and DateOfMovement<@EndDate and (TypeOfMovement='CGO' OR [TypeOfMovement] = 'CHNFS')
 Group by A.IdAgent                 
                 
--   @AgentcommissionRetain=isnull( SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end),0),                                 
-- Select top 1 * from AgentBalance            
--SELECT DISTINCT TYPEOFMOVEMENT FROM AgentBalance                 
                  
                  
   Select Max(DateOfMovement) as DateOfMovement, IdAgent                
   Into #temp15                
   from AgentBalance with(nolock)            
   Where DateOfMovement<@EndDate  
   Group by IdAgent                
                   
   Select Balance,A.IdAgent,a.IdAgentBalance--                 
   Into #temp11                
   from AgentBalance A with(nolock)               
   Join #temp15 B on (A.DateOfMovement=B.DateOfMovement and A.IdAgent=B.IdAgent)                
    --where not (A.TypeOfMovement='CGO' and ( A.Description like '% Retransfer Credit - Folio:%' or  A.Description like '% Oklahoma State Fee - Folio:%' ) ) --#3    
	
	/************************************************************/--#3
	SELECT IdAgentBalance into #TmpDelete
	  FROM (
			SELECT IdAgentBalance, Flag = ROW_NUMBER() OVER(PARTITION BY IdAgent ORDER BY IdAgentBalance DESC)
			  FROM #temp11
	       ) AS t
	 WHERE 1 = 1
	   AND Flag > 1

	  delete from #temp11 where 1 = 1 And IdAgentBalance in (select IdAgentBalance from #TmpDelete);
       /************************************************************/ --#3      
                
 Select Max(IdAgentDeposit) as IdAgentDeposit, IdAgent                
 Into #temp12                
 from Agentdeposit with(nolock)              
 Group by IDAgent                
                   
 Select DateOfLastChange as LastDeposit,A.IdAgent                 
 Into #temp13                
 from  Agentdeposit A  with(nolock)              
 Join #temp12 B on (A.IdAgentDeposit=B.IdAgentDeposit)                
                 
                   
 Select Max(DateOfMovement) as DateOfMovement, IdAgent                
 Into #temp14                
 from AgentBalance with(nolock)             
 Where TypeOfMovement='TRAN'                
 Group by IdAgent                
    

--Declare @BeginDateSpecialCommission datetime = DATEADD(day,(day(@BeginDate)*-1)+1,@BeginDate)

 Select  SC.IdAgent, SUM(SC.Commission) SpecialCommission        
 Into #tempSC                
 from [dbo].[SpecialCommissionBalance]  SC
 WHERE SC.[DateOfApplication]>= @BeginDate AND SC.[DateOfApplication]<@EndDate
 Group by SC.IdAgent 
 
 select idagent, count(1) totchecks,sum(amount) amountChecks  into #checks
 from  checks with(nolock)
 where idstatus in (20,21,30)  and DateOfMovement>= @BeginDate AND DateOfMovement<@EndDate--#1
 group by idagent		             
             
 Select A.*,B.TransferNum,B.TransferAmount,                 
 C.TransferNumClosed,C.TransferAmountClosed,                
 B.Commission,              
 O.CommissionRej,              
 P.CommissionCan,              
 C.CommissionClosed,              
 Q.CommissionClosedRej,              
 R.CommissionClosedCan,                
 O.TransferNumRejected,              
 O.TransferAmountRejected,              
 P.TransferNumCancelled,              
 P.TransferAmountCancelled,              
 Q.TransferNumClosedRejected,              
 Q.TransferAmountClosedRejected,              
 R.TransferNumClosedCancelled,              
 R.TransferAmountClosedCancelled,              
 J.Deposit,K.OtherCharge,                
 L.Balance,M.LastDeposit,N.DateOfMovement,        
 S.OPNumTrans,S.OPNumCancels,S.OPAmount,S.OPCommission, S.OPAmountCancel,W.TransferAmountCancelledBalance ,
 isnull(SC.SpecialCommission,0) SpecialCommission,
 isnull(ch.totchecks,0) totchecks,
 isnull(ch.amountChecks,0) amountChecks,
 --GETDATE() as DateOfStatusChange
 case 
 when (select COUNT(DateOfchange) from AgentStatusHistory with(nolock) where IdAgent=A.IdAgent) = 0
 then
	(select OpenDate from Agent with(nolock) where IdAgent=A.IdAgent)
 else
	(select top 1 DateOfchange from AgentStatusHistory with(nolock) where IdAgent=A.IdAgent order by DateOfchange desc) 
 end As DateOfStatusChange,
 B.Fee, B.MerchantFee, B.NetFee, B.CashDiscount, B.DCTr,
 C.FeeClosed, C.MerchantFeeClosed, C.NetFeeClosed, C.CashDiscountClosed, C.DCTrClosed,
 O.FeeRej, P.FeeCan, Q.FeeClosedRejected, R.FeeClosedCancelled, JJ.AdvanceCredit
 	
 Into #tempFinal                
 from @tResult A                
 Left Join #temp1 B on (A.IdAgent=B.IdAgent)                
 Left Join #temp2 C on (A.IdAgent=C.IdAgent)                
 Left Join #temp9 J on (A.IdAgent=J.IdAgent)     
 Left Join #temp10 K on (A.IdAgent=K.IdAgent)                
 Left Join #temp11 L on (A.IdAgent=L.IdAgent)                
 Left Join #temp13 M on (A.IdAgent=M.IdAgent)                
 Left Join #temp14 N on (A.IdAgent=N.IdAgent)                
 Left Join #temp21 O on (A.IdAgent=O.IdAgent)              
 Left Join #temp22 P on (A.IdAgent=P.IdAgent)              
 Left Join #temp23 Q on (A.IdAgent=Q.IdAgent)            
 Left Join #temp24 R on (A.IdAgent=R.IdAgent)        
 Left Join #tempOP S on (A.IdAgent=S.IdAgent)    
 Left Join #temp25 W on (A.IdAgent=W.IdAgent)
 Left Join #tempSC SC on (A.IdAgent=SC.IdAgent) 
 left join #checks ch on (A.IdAgent=ch.IdAgent)    
 left join #temp91 JJ on (A.IdAgent=JJ.IdAgent)  
  
 --Left Join #tempCBP T on (A.IdAgent=T.IdAgent)      
 --Left Join #tempCP V on (A.IdAgent=V.IdAgent)  
 
              
                  
 Update  #tempFinal set NumberTransactions=isNull(TransferNum,0)+isNull(TransferNumClosed,0)-isNull(TransferNumRejected,0)-isNull(TransferNumCancelled,0)-isNull(TransferNumClosedRejected,0)-isNull(TransferNumClosedCancelled,0)                
 Update  #tempFinal set TransfersAmount=isNull(TransferAmount,0)+isNull(TransferAmountClosed,0)                  
 Update  #tempFinal set CommissionTransfersAmount=isNull(Commission,0)+isNull(CommissionClosed,0)               
 Update  #tempFinal set RejectedAmount=(isNull(TransferAmountRejected,0)+isNull(TransferAmountClosedRejected,0))*-1             
 Update  #tempFinal set CancelledAmount=(isNull(TransferAmountCancelledBalance,0))                
 Update  #tempFinal set DepositAmount=isNull(Deposit*-1,0)
 UPDATE  #tempFinal SET AdvanceCreditAmount=isNull(AdvanceCredit*-1,0)
 Update  #tempFinal set OtherChargeAmount=isNull(OtherCharge*-1,0)                
 Update  #tempFinal set CurrentBalance=isNull(Balance,0)                
 Update  #tempFinal set DateOfLastDeposit=isnull(LastDeposit,'')                
 Update  #tempFinal set DateOfLastMovement=isnull(DateOfMovement,''),OPAmountCancel=isnull(OPAmountCancel,0),OPAmount=isnull(OPAmount,0)        
 Update  #tempFinal set OPNumTrans= isnull(OPNumTrans,0)-isnull(OPNumCancels,0),OPCommission=isnull(OPCommission,0)            
 Update  #tempFinal set LastBalance=CurrentBalance-TransfersAmount-OtherChargeAmount-DepositAmount-AdvanceCreditAmount-CommissionTransfersAmount-CancelledAmount-RejectedAmount-OPAmount-OPAmountCancel+ ( case when idAgentPaymentSchema=1  then 0 else OPCommission end )
 
 UPDATE #tempFinal SET MerchantFeeFinal = isnull(MerchantFee, 0) + isnull(MerchantFeeClosed, 0)
 UPDATE #tempFinal SET TotalFeeFinal = isnull(Fee, 0) + isnull(FeeClosed, 0)
 UPDATE #tempFinal SET FeeCanRFinal = isnull(FeeRej, 0) + isnull(FeeCan, 0) + isnull(FeeClosedRejected, 0) + isnull(FeeClosedCancelled, 0)
 UPDATE #tempFinal SET CashDiscountFinal = isnull(CashDiscount, 0) + isnull(CashDiscountClosed, 0)
 UPDATE #tempFinal SET NetFeeFinal = isnull(NetFee, 0) + isnull(NetFeeClosed, 0)
 UPDATE #tempFinal SET DCTranFinal = isnull(DCTr, 0) + isnull(DCTrClosed, 0)

      
select    
    AC.IDAGENT,         
    (select top 1 idagentcollectiondetail from agentcollectiondetail with(nolock) where DateofLastChange <=@BeginDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail desc) idcp1,      
    (select top 1 idagentcollectiondetail from agentcollectiondetail with(nolock) where DateofLastChange <=@EndDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail) idcp2,  
    (select top 1 idagentcollectiondetail from agentcollectiondetail with(nolock) where DateofLastChange <=@EndDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail desc) idfcp    ,  
  
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where DateofLastChange <=@BeginDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail desc) cp1,      
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where DateofLastChange <=@EndDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail) cp2,  
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where DateofLastChange <=@EndDate and idagentcollection=ac.IdAgentCollection  order by IdAgentCollectionDetail desc) fcp      
into   
    #CP  
from   
    agentcollection ac                  
                 
 Select                 
   t.IdAgent ,     
   Agent ,  
   --AgentPhone,  
   ACHWellsFargo ACH,  
   BankName,  
   AgentStatus ,   
   IdAgentStatus,                       
   DateOfLastDeposit ,                        
   DateOfLastMovement ,                        
   LastBalance ,                        
   NumberTransactions ,                        
   TransfersAmount ,                        
   CommissionTransfersAmount ,                        
   DepositAmount ,  
   RejectedAmount ,                        
   CancelledAmount ,                        
   OtherChargeAmount,        
   OPNumTrans as OPNum,        
   OPAmount as OPAmount,        
   OPCommission as OPComm,        
   OPAmountCancel as OPCancelled,                        
   CurrentBalance,  
        isnull(  
            case   
                when c.cp1 is null then c.cp2  
                else  
                c.cp1  
            end,  
        0)  
   InitialCP,     
       isnull(  
            case   
       when c.cp1 is null then c.cp2  
                else  
                c.cp1  
            end,  
        0)  
   -case   
 when idcp1=idfcp then c.cp1  
        when idcp2=idfcp then c.cp2  
        else  
            isnull(fcp,0)  
    end  
   CPMovements,     
   case   
    when idcp1=idfcp then c.cp1  
    when idcp2=idfcp then c.cp2  
    else  
        isnull(fcp,0)  
   end     
   FinalCP,  
   CurrentBalance +  
   case   
    when idcp1=idfcp then c.cp1  
    when idcp2=idfcp then c.cp2  
    else  
        isnull(fcp,0)  
   end   
   ConsolidatedDebt,
   IdAgentCurrentStatus,
   AgentCurrentStatusName,
   SpecialCommission,
   totChecks,
   amountChecks
   ,CASE WHEN A.IdAgentSuspendedSubStatus IS NOT NULL AND t.IdAgentCurrentstatus = 3 THEN A.DateOfLastChange 	
   		WHEN t.IdAgentCurrentStatus <> 3 THEN DateOfStatusChange
   	  	ELSE NULL END AS DateOfStatusChange,
   NetFeeFinal AS NetFee,
   FeeCanRFinal AS FeeCanR,
   CashDiscountFinal AS CashDiscount,
   TotalFeeFinal AS TotalFee,
   DCTranFinal AS DCTr,
   MerchantFeeFinal AS MerchantFee,
   AdvanceCreditAmount 
from    
    #tempFinal t   
left join #CP c on t.idagent=c.idagent 
LEFT JOIN Corp.AgentSuspendedSubStatus A ON A.IdAgent = t.idagent
									AND A.Suspended = 1 
									AND A.IdMaxiDepartment = 3 
      
order   
    by AgentOrder,Agent 
    
    
