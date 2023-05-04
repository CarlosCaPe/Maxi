CREATE PROCEDURE [Corp].[st_FindTransfersInProcess]
    --@StatusesPreselected XML,    
    @BeginDate datetime ,    
    @EndDate datetime,    
    @IdAgent int,    
    @Customer nvarchar(max),    
    @Beneficiary nvarchar(max),        
    @TransferFolio int,    
    @IdCurrency int,     
    @IdPayer int,
    @IdGateway int
    --@IsTimeForVerifyHold bit = null    
as    

--set @IsTimeForVerifyHold=isnull(@IsTimeForVerifyHold,0)

if @BeginDate is not null    
    Select  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  

if @EndDate is not null
    Select  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  
    
 
Declare @tStatus table    
      (    
       id int    
      )    
    
Declare @hasStatus bit    
    
insert into @tStatus(id)     
values
(29),
(24),
(21),
(40)

select t.*,(select top 1 note from TransferNote where idtransferdetail=t.idtransferdetail order by enterdate desc) note from 
(
select t.*,(select top 1 IdTransferDetail from transferdetail idtransferdetail where idtransfer=t.idtransfer order by DateOfMovement desc) idtransferdetail from 
(    
  select    
   T.IdTransfer,    
   ag.agentcode,
   ag.agentname,
   T.CustomerName,    
   T.CustomerFirstLastName,    
   T.CustomerSecondLastName,    
   T.CustomerZipcode,    
   T.CustomerCity,    
   T.CustomerState,    
   T.CustomerAddress,    
   T.CustomerPhoneNumber,    
   T.CustomerCelullarNumber,    
   T.BeneficiaryName,    
   T.BeneficiaryFirstLastName,    
   T.BeneficiarySecondLastName,    
   T.BeneficiaryCountry,    
   T.BeneficiaryZipcode,    
   T.BeneficiaryState,    
   T.BeneficiaryCity,    
   T.BeneficiaryAddress,    
   T.BeneficiaryPhoneNumber,    
   T.BeneficiaryCelularNumber,    
   case    
    when T.IdAgentSchema is not null then A.SchemaName    
    when T.IdCountryCurrency is not null then A1.SchemaName      
   end SchemaName,--Nullable    
   P.PaymentName, 
   g.gatewayname,   
   Py.PayerName,    
   Br.BranchName,--Nullable    
   Ci.CityName,--Nullable    
   S.StateName,--Nullable    
   T.ExRate,    
   --T.CorporateCommission+ T.AgentCommission Commission,    
   T.Fee Commission,
   T.AmountInDollars,    
   T.AmountInMN,    
   --T.CorporateCommission+ T.AgentCommission+T.AmountInDollars Total,    
   T.Fee+T.AmountInDollars Total,
   T.DateOfTransfer,    
   T.Folio,    
   St.StatusName,    
   T.DepositAccountNumber,    
   T.IdAgent,
   T.ClaimCode,
   dbo.fun_GetTransferHoldSemaphore(T.IdTransfer) as Semaphore,
   Pre.IdPreTransfer,
   CC.idcountry,
   T.IdCustomer         
  FROM [dbo].[Transfer] T    
   left join AgentSchema A on A.IdAgentSchema=T.IdAgentSchema    
   left join     
    (    
     select A.IdCountryCurrency, MIN(A.IdAgentSchema) IdAgentSchema     
     from AgentSchema A    
     where A.IdGenericStatus = 1    
     group by A.IdCountryCurrency    
    )AC on AC.IdCountryCurrency =T.IdCountryCurrency    
    left join AgentSchema A1 on A1.IdAgentSchema=AC.IdAgentSchema    
   inner join PaymentType P on P.IdPaymentType= T.IdPaymentType    
   inner join Payer Py on Py.IdPayer =T.IdPayer    
   inner join CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency    
   left join dbo.Branch Br on Br.IdBranch =T.IdBranch    
   left join dbo.City Ci on Ci.IdCity =Br.IdCity     
   left join dbo.State S on Ci.IdState = S.IdState     
   inner join Status St on St.IdStatus = T.IdStatus       
   left join PreTransfer Pre on Pre.IdTransfer = T.IdTransfer
   join agent ag on t.idagent=ag.idagent
   join gateway g on t.idgateway=g.idgateway   
   where     
        T.IdAgent = Isnull(@IdAgent,T.IdAgent) and
        T.DateOfTransfer>= isnull(@BeginDate,T.DateOfTransfer) and T.DateOfTransfer <= isnull(@EndDate,T.DateOfTransfer) and         
        T.IdStatus in (select id from @tStatus) and        
        T.Folio = isnull(@TransferFolio ,T.Folio) and
        CC.IdCurrency = isnull(@IdCurrency,CC.IdCurrency) and
        t.IdPayer = isnull(@IdPayer,t.IdPayer) and
        t.idgateway = isnull(@IdGateway, t.idgateway) 
        and
        (
             (T.CustomerName = isnull(@Customer,T.CustomerName) or T.CustomerFirstLastName = isnull(@Customer,T.CustomerFirstLastName) or T.CustomerSecondLastName = Isnull(@Customer,T.CustomerSecondLastName))        
        )
        and
        (
            (T.BeneficiaryName = isnull(@Beneficiary,T.BeneficiaryName) or T.BeneficiaryFirstLastName = isnull(@Beneficiary,T.BeneficiaryFirstLastName) or T.BeneficiarySecondLastName = isnull(@Beneficiary,T.BeneficiarySecondLastName))
        )
)
t
)t
order by DateOfTransfer desc


/****************************************************************************/
