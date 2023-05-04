CREATE procedure [Corp].[st_GetBeneficiaryTransactionHistory]  
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

 execute  st_GetBeneficiaryTransactionHistory
   @IdTransfer =9974560
   , @BeginDate ='2017/05/05' 

*/  
  
declare @IdStatusRejected int  
set @IdStatusRejected =31  
  
declare @IdStatusCancelled int  
set @IdStatusCancelled =22  
  
declare @IdBeneficiary int  
set @IdBeneficiary = ( select IdBeneficiary from Transfer where IdTransfer =@IdTransfer  
       union  
      select IdBeneficiary from TransferClosed where IdTransferClosed =@IdTransfer)  
  
declare @EndDate datetime  
select @EndDate = DateOfTransfer from transfer (nolock) where IdTransfer=@IdTransfer
--set @EndDate = dbo.RemoveTimeFromDatetime(DATEADD(DAY,1,GETDATE()))  
if (@EndDate is null)
	select @EndDate = DateOfTransfer from transferclosed (nolock) where IdTransferclosed=@IdTransfer
set @EndDate = dbo.RemoveTimeFromDatetime(DATEADD(DAY,1,@EndDate))  
  
--declare @BeginDate datetime  
--set @BeginDate = DATEADD(year,-3,@EndDate)  --#1 
--  

	--if @BeginDate is not null
	--begin
		--set @BeginDate = DATEADD(dd,-30+1,dbo.RemoveTimeFromDatetime(@EndDate))
		set @BeginDate = DATEADD(dd,-31+1,dbo.RemoveTimeFromDatetime(@EndDate))--#1
	--end
  
	 --set @BeginDate = isnull(@BeginDate, DATEADD(year,-3,@EndDate))  
  
  
--select @IdBeneficiary, @BeginDate, @EndDate  
  
select  
 IdTransfer,  
 DateOfTransfer,  
 BeneficiaryFullName,  
 AgentCode,  
 AmountInDollars,  
 Folio  
from (  
 select   
  t.IdTransfer,  
  t.DateOfTransfer,  
  t.BeneficiaryName + ' '+ t.BeneficiaryFirstLastName+ ' ' + t.BeneficiarySecondLastName BeneficiaryFullName,  
  a.AgentCode,  
  t.AmountInDollars,  
  t.Folio  
  from Transfer t  
   inner join Agent a on t.IdAgent= a.IdAgent  
  where t.IdBeneficiary = @IdBeneficiary and  
   t.IdStatus not in (@IdStatusRejected, @IdStatusCancelled) and  
   (t.DateOfTransfer>=@BeginDate and t.DateOfTransfer< @EndDate)  
 union   
 select   
  t.IdTransferClosed,  
  t.DateOfTransfer,  
  t.BeneficiaryName + ' '+ t.BeneficiaryFirstLastName+ ' ' + t.BeneficiarySecondLastName BeneficiaryFullName,  
  a.AgentCode,  
  t.AmountInDollars,  
  t.Folio  
  from TransferClosed t  
   inner join Agent a on t.IdAgent= a.IdAgent  
  where t.IdBeneficiary = @IdBeneficiary and  
   t.IdStatus not in (@IdStatusRejected, @IdStatusCancelled) and  
   (t.DateOfTransfer>=@BeginDate and t.DateOfTransfer< @EndDate)  
     
  )T   
order by T.DateOfTransfer desc

