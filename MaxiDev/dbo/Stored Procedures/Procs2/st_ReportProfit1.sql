CREATE procedure [dbo].[st_ReportProfit1]                            
(                            
@IdCountryCurrency int,                            
@StartDate datetime,                            
@EndDate datetime                            
)                            
as                            
Set nocount on                             
                            
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)                            
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                            
                            
                            
Create Table #Temp                            
(                            
Id int identity(1,1),                            
IdAgent Int,                            
AgentName nvarchar(max),                            
AgentCode nvarchar(max),                            
NumTrans int,                            
NumCancel int,                            
NumNet int,                            
AmountTrans money,                            
AmountCancel money,                            
AmountNet money,                            
CogsTrans money,                            
CogsCancel money,                            
CogsNet money,                            
FxResult money,                            
IncomeFee money,                            
Agentcommission money,          
FxFee money,                            
Payercommission money,                            
Result money,                            
OtherCharges money,                            
NetResult money                            
)                            
                            
Insert into #Temp (IdAgent)                            
Select Distinct IdAgent from Transfer where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End and DateOfTransfer>@StartDate and DateOfTransfer<@EndDate            
Union                           
Select IdAgent from TransferClosed           
where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End and          
DateOfTransfer>@StartDate and DateOfTransfer<@EndDate          
Union  
Select IdAgent from TransferClosed           
where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End and          
DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)          
Union  
Select IdAgent from Transfer           
where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End and          
DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)          
  
                            
                            
Update #Temp set AgentName=B.AgentName,AgentCode=B.Agentcode From #Temp A,Agent B where A.IdAgent=B.IdAgent                            
                            
Declare @TempId int,@IdAgent int,@NumTrans int,@NumCancel int,@AmountTrans money,@AmountCancel money,@FxResult money                            
Declare @Agentcommission money, @IncomeFee money,@OtherCharges money,@CogsNet Money,@CogsTrans money ,@CogsCancel Money  
                
Declare @NumTrans2 int,@NumCancel2 int,@AmountTrans2 money,@AmountCancel2 money,@FxResult2 money                            
Declare @Agentcommission2 money, @IncomeFee2 money,@OtherCharges2 money,@CogsNet2 Money,@CogsTrans2 money           
Declare @CogsCancel2 Money, @FxFee Money,@FxFee2 Money                         
  
Declare @CogsTransRej Money,@NumTransRej int,@AmountTransRej Money, @FxResultRej Money  
Declare @CogsTrans2Rej Money,@NumTrans2Rej int,@AmountTrans2Rej Money,@FxResult2Rej Money
Declare @FxResultCancel  Money, @FxResultCancel2 Money

Declare @AgentcommissionRej money,@IncomeFeeRej Money,@FxFeeRej Money
Declare @Agentcommission2Rej money,@IncomeFee2Rej Money,@FxFee2Rej Money
        

Declare @AgentcommissionCan Money,@IncomeFeeCan Money, @FxFeeCan Money
Declare @Agentcommission2Can Money,@IncomeFee2Can Money,@FxFee2Can Money
                
Set @TempId=1                            
                                
While exists(Select  1 from #temp  where Id=@TempId)                                
Begin                             
    Select @IdAgent=IdAgent from #Temp where Id=@TempId                  
          
    Set @NumTrans =0                
    Set @NumCancel =0                
    Set @AmountTrans=0                 
    Set @AmountCancel=0                
    Set @FxResult=0                            
    Set @Agentcommission=0                
    Set @IncomeFee=0                
    Set @OtherCharges=0                 
    Set @CogsNet=0                
    Set @CogsTrans=0                
    Set @CogsCancel=0                
    Set @NumTrans2 =0                
    Set @NumCancel2 =0                
    Set @AmountTrans2=0                 
    Set @AmountCancel2=0                
    Set @FxResult2=0                            
    Set @Agentcommission2=0                
    Set @IncomeFee2=0                
    Set @OtherCharges2=0                 
    Set @CogsNet2=0                
    Set @CogsTrans2=0                
    Set @CogsCancel2=0           
    Set @FxFee=0          
    Set @FxFee2=0 
    Set @AgentcommissionRej=0
    Set @IncomeFeeRej=0
    Set @FxFeeRej =0
	Set @Agentcommission2Rej=0 
	Set @IncomeFee2Rej=0
	Set @FxFee2Rej=0
	Set @IncomeFeeCan=0
	Set @IncomeFee2Can=0
        

                              
                    
    ---  Transfer All --------              
    Select @NumTrans= isnull(COUNT(1),0),@AmountTrans=isnull(SUM(AmountInDollars),0),
    @FxResult=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) ,0),
    @Agentcommission=isnull(SUM(AgentCommission),0), 
    @IncomeFee=isnull(SUM(TotalAmountToCorporate-AmountInDollars),0),
    @FxFee=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)
    from Transfer where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateOfTransfer>@StartDate and                             
    DateOfTransfer<@EndDate and                             
    IdAgent=@IdAgent                 
                    
                    
    ----- TransferClosed All----                
    Select @NumTrans2= isnull(COUNT(1),0),@AmountTrans2=isnull(SUM(AmountInDollars),0),
    @FxResult2=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)),0),
    @Agentcommission2=isnull(SUM(AgentCommission),0), 
    @IncomeFee2=isnull(SUM(TotalAmountToCorporate-AmountInDollars),0),
    @FxFee2=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)    
    from TransferClosed where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateOfTransfer>@StartDate and                             
    DateOfTransfer<@EndDate and                             
    IdAgent=@IdAgent                              
        
      
     ---  Transfer Rejected--------              
    Select @NumTransRej= isnull(COUNT(1),0),@AmountTransRej=isnull(SUM(AmountInDollars),0),
    @FxResultRej=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) ,0),         
    @AgentcommissionRej=isnull(SUM(AgentCommission),0), 
    @IncomeFeeRej=isnull(SUM(TotalAmountToCorporate-AmountInDollars),0),
    @FxFeeRej=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)
    from Transfer where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateStatusChange>@StartDate and                             
    DateStatusChange<@EndDate and                             
    IdAgent=@IdAgent and IdStatus=31                
                    
                    
    ----- TransferClosed Rejected----                
    Select @NumTrans2Rej= isnull(COUNT(1),0),@AmountTrans2Rej=isnull(SUM(AmountInDollars),0),
    @FxResult2Rej=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)),0),
    @Agentcommission2Rej=isnull(SUM(AgentCommission),0), 
    @IncomeFee2Rej=isnull(SUM(TotalAmountToCorporate-AmountInDollars),0),
    @FxFee2Rej=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)
    from TransferClosed where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateStatusChange>@StartDate and                             
    DateStatusChange<@EndDate and                             
    IdAgent=@IdAgent and IdStatus=31   
      
                                
    ------ Transfer Cancel---------------------                            
    Select @CogsCancel=isnull(SUM((AmountInDollars*ExRate)/ReferenceExRate),0),@NumCancel= isnull(COUNT(1),0),@AmountCancel=isnull(SUM(AmountInDollars),0),
    @FxResultCancel=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)),0),
    @AgentcommissionCan=isnull(SUM(AgentCommission),0), 
    @FxFeeCan=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)
    from Transfer where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateStatusChange>@StartDate and                             
    DateStatusChange<@EndDate and                             
    IdAgent=@IdAgent and IdStatus=22 -- Cancelled                            
                      
    ----------- TransferClosed Cancelled -------------                
    Select @CogsCancel2=isnull(SUM((AmountInDollars*ExRate)/ReferenceExRate),0),@NumCancel2= isnull(COUNT(1),0),@AmountCancel2=isnull(SUM(AmountInDollars),0),
    @FxResultCancel2=ISNULL( SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)),0),
    @Agentcommission2Can=isnull(SUM(AgentCommission),0), 
    @FxFee2Can=isnull(SUM(ModifierCommissionSlider+ModifierExchangeRateSlider ),0)
    from TransferClosed where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and                             
    DateStatusChange>@StartDate and                             
    DateStatusChange<@EndDate and                             
    IdAgent=@IdAgent and IdStatus=22 -- Cancelled                    
         
                            
    Select @OtherCharges=isnull(SUM(Amount),0) from AgentOtherCharge where IdAgent=@IdAgent and                            
    ChargeDate>@StartDate and                             
    ChargeDate<@EndDate                              
            
                                        
    Update #Temp set NumTrans=@NumTrans+@NumTrans2-@NumTransRej-@NumTrans2Rej,NumCancel=@NumCancel+@NumCancel2,
    AmountTrans=@AmountTrans+@AmountTrans2-@AmountTransRej-@AmountTrans2Rej,                
    OtherCharges=@OtherCharges,CogsCancel=@CogsCancel+@CogsCancel2,                      
    AmountCancel=@AmountCancel+@AmountCancel2,FxResult=@FxResult+@FxResult2-@FxResultRej-@FxResult2Rej-@FxResultCancel-@FxResultCancel2,                
    Agentcommission=@Agentcommission+@Agentcommission2-@AgentcommissionRej-@Agentcommission2Rej-@AgentcommissionCan-@Agentcommission2Can,
    IncomeFee=@IncomeFee+@IncomeFee2-@IncomeFeeRej-@IncomeFee2Rej-@IncomeFeeCan-@IncomeFee2Can,
    FxFee=@FxFee+@FxFee2-@FxFeeRej-@FxFeeRej
    where Id=@TempId                            
                            
 Set @TempId=@TempId+1                            
End                            
                            
Update #Temp set NumNet=NumTrans-NumCancel,AmountNet=AmountTrans-AmountCancel,Result=IncomeFee-AgentCommission
Update #Temp set Payercommission=0,CogsNet=AmountNet-FxResult                                                        
Update #Temp set OtherCharges=0 where OtherCharges is null                            
Update #Temp set NetResult=FxResult+OtherCharges+Result,CogsTrans= CogsCancel+CogsNet                           
                           
                          
Select                
IdAgent,AgentName,AgentCode,                           
NumTrans,                            
NumCancel,                            
NumNet,                            
AmountTrans,                            
AmountCancel,                            
AmountNet,                            
CogsTrans,                            
CogsCancel,                            
CogsNet,                            
FxResult,                            
IncomeFee ,                            
Agentcommission,           
FxFee,                           
Payercommission,                            
Result ,                            
OtherCharges,                            
NetResult                            
from #Temp                 
Order by AgentCode
