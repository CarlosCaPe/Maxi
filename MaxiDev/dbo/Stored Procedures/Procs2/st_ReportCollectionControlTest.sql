
CREATE procedure [dbo].[st_ReportCollectionControlTest]                
@BeginDate datetime,                
@EndDate datetime                
as                
                
set nocount on                
                
declare @IAgentStatusDisable int                
set @IAgentStatusDisable = 2  

Declare @Money as Money 
Set @Money=0   
                
                
set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                   
         
                 
 Select                 
 A.IdAgent,                
 A.AgentCode+ ' - '+AgentName Agent,                
 S.AgentStatus                
 into #agentTemp                
 from Agent A                
 inner join AgentStatus S on S.IdAgentStatus= A.IdAgentStatus                
 where A.IdAgentStatus!= @IAgentStatusDisable        
         
 Create clustered index idxTemp on  #agentTemp (IdAgent)               
         
                
declare @tResult table                
(                
 IdAgent int,                
 Agent varchar(200),                
 AgentStatus varchar(20),                
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
 DebitOrCredit varchar(50)                
)                
          
 Insert into  @tResult (IdAgent,Agent,AgentStatus)        
 Select IdAgent,Agent,AgentStatus from #agentTemp        


Select A.IdAgent,count(1) as BPNum,SUM(A.ReceiptAmount) as BPAmount, SUM( case when ismonthly=1 then A.Fee else A.CorpCommission end) as BPCommission
 into #tempBP  from BillPaymentTransactions A Join AgentBalance B on (A.IdBillPayment=B.IdTransfer)
join #agentTemp C on (C.IdAgent=A.IdAgent)
Where  B.DateOfMovement>=@BeginDate and B.DateOfMovement<@EndDate  and B.TypeOfMovement='BP'
Group by A.IdAgent


Select A.IdAgent,count(1) as BPNumCancel,SUM(A.ReceiptAmount) as BPAmountCancel, SUM( case when ismonthly=1 then A.Fee else A.CorpCommission end) as BPCommissionCancel
 into #tempCBP from BillPaymentTransactions A Join AgentBalance B on (A.IdBillPayment=B.IdTransfer)
join #agentTemp C on (C.IdAgent=A.IdAgent)
Where  B.DateOfMovement>=@BeginDate and B.DateOfMovement<@EndDate and B.TypeOfMovement='CBP'
Group by A.IdAgent


         
 Select Count(1) as TransferNum,isNull(Sum(AmountInDollars),0) as TransferAmount,A.IdAgent,isnull(Sum(TotalAmountToCorporate-AmountInDollars),0) as Commission         
 into #temp1        
 from Transfer A  Join #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateOfTransfer>=@BeginDate and DateOfTransfer<@EndDate          
 Group by A.IdAgent        
        
       
 Select Count(1) as TransferNumRejected,isNull(Sum(TotalAmountToCorporate),0) as TransferAmountRejected,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionRej         
 into #temp21        
 from Transfer A  Join #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate      
 and IdStatus in (31)          
 Group by A.IdAgent        
       
       
 Select Count(1) as TransferNumCancelled,isNull(Sum(AmountInDollars),0) as TransferAmountCancelled,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionCan          
 into #temp22        
 from Transfer A  Join #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate      
 and IdStatus in (22)          
 Group by A.IdAgent        
       
       
         
 Select Count(1) as TransferNumClosed,isnull(Sum(AmountInDollars),0) as TransferAmountClosed,A.IdAgent,isnull(Sum(TotalAmountToCorporate-AmountInDollars),0) as CommissionClosed          
 into #temp2        
 from TransferClosed A  Join  #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateOfTransfer>=@BeginDate and DateOfTransfer<@EndDate          
 Group by A.IdAgent         
       
       
 Select Count(1) as TransferNumClosedRejected,isNull(Sum(TotalAmountToCorporate),0) as TransferAmountClosedRejected,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionClosedRej         
 into #temp23        
 from TransferClosed A  Join #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate      
 and IdStatus in (31)          
 Group by A.IdAgent        
       
       
 Select Count(1) as TransferNumClosedCancelled,isNull(Sum(AmountInDollars),0) as TransferAmountClosedCancelled,A.IdAgent,isnull(Sum(AgentCommission),0) as CommissionClosedCan         
 into #temp24        
 from TransferClosed A  Join #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateStatusChange>=@BeginDate and DateStatusChange<@EndDate      
 and IdStatus in (22)          
 Group by A.IdAgent        
       
         
 Select isnull(Sum(Amount),0) as Deposit,A.IdAgent         
 into #temp9        
 from AgentDeposit A  Join  #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateOfLastChange>=@BeginDate and DateOfLastChange<@EndDate          
 Group by A.IdAgent         
         
        
 Select isnull(Sum(case when DebitOrCredit='Credit' Then Amount else Amount*-1 end),0) as OtherCharge,A.IdAgent         
 into #temp10        
 from AgentBalance A  Join  #agentTemp B on (A.IdAgent=B.IdAgent)        
 where DateOfMovement>=@BeginDate and DateOfMovement<@EndDate and TypeOfMovement='CGO'      
 Group by A.IdAgent         
         
--   @AgentcommissionRetain=isnull( SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end),0),                         
-- Select top 1 * from AgentBalance    
--SELECT DISTINCT TYPEOFMOVEMENT FROM AgentBalance         
          
          
   Select Max(DateOfMovement) as DateOfMovement, IdAgent        
   Into #temp15        
   from AgentBalance        
   Where DateOfMovement<@EndDate        
   Group by IdAgent        
           
   Select Balance,A.IdAgent         
   Into #temp11        
   from AgentBalance A         
   Join #temp15 B on (A.DateOfMovement=B.DateOfMovement and A.IdAgent=B.IdAgent)        
           
           
        
 Select Max(IdAgentDeposit) as IdAgentDeposit, IdAgent        
 Into #temp12        
 from Agentdeposit        
 Group by IDAgent        
           
 Select DateOfLastChange as LastDeposit,A.IdAgent         
 Into #temp13        
 from  Agentdeposit A        
 Join #temp12 B on (A.IdAgentDeposit=B.IdAgentDeposit)        
         
           
 Select Max(DateOfMovement) as DateOfMovement, IdAgent        
 Into #temp14        
 from AgentBalance        
 Where TypeOfMovement='TRAN'        
 Group by IdAgent        
         
          
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
 S.BPNum,T.BPNumCancel,S.BPAmount,S.BPCommission,
 T.BPCommissionCancel,T.BPAmountCancel,
 @Money as BPComm
         
         
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
 Left Join #tempBP S on (A.IdAgent=S.IdAgent)
 Left Join #tempCBP T on (A.IdAgent=T.IdAgent)        
         
 Update  #tempFinal set NumberTransactions=isNull(TransferNum,0)+isNull(TransferNumClosed,0)-isNull(TransferNumRejected,0)-isNull(TransferNumCancelled,0)-isNull(TransferNumClosedRejected,0)-isNull(TransferNumClosedCancelled,0)        
 Update  #tempFinal set TransfersAmount=isNull(TransferAmount,0)+isNull(TransferAmountClosed,0)          
 Update  #tempFinal set CommissionTransfersAmount=isNull(Commission,0)+isNull(CommissionClosed,0)       
 Update  #tempFinal set RejectedAmount=(isNull(TransferAmountRejected,0)+isNull(TransferAmountClosedRejected,0))*-1       
 Update  #tempFinal set CancelledAmount=(isNull(TransferAmountCancelled,0)+isNull(TransferAmountClosedCancelled,0))*-1        
 Update  #tempFinal set DepositAmount=isNull(Deposit*-1,0)        
 Update  #tempFinal set OtherChargeAmount=isNull(OtherCharge*-1,0)        
 Update  #tempFinal set CurrentBalance=isNull(Balance,0)        
 Update  #tempFinal set DateOfLastDeposit=isnull(LastDeposit,'')        
 Update  #tempFinal set DateOfLastMovement=isnull(DateOfMovement,''),BPAmountCancel=isnull(BPAmountCancel,0),BPAmount=isnull(BPAmount,0)
 Update  #tempFinal set BPNum= isnull(BPNum,0)-isnull(BPNumCancel,0),BPComm=isnull(BPCommission,0)-isnull(BPCommissionCancel,0)      
 Update  #tempFinal set LastBalance=CurrentBalance-TransfersAmount-OtherChargeAmount-DepositAmount- CommissionTransfersAmount-CancelledAmount-RejectedAmount-BPAmount-BPComm-BPAmountCancel        
         
         
 Select         
   IdAgent ,                
   Agent ,                
   AgentStatus ,                
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
   BPNum,
   BPAmount,
   BPComm,
   BPAmountCancel as BpCancelled,                
   CurrentBalance    from  #tempFinal         
order by Agent

