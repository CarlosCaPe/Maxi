
CREATE procedure [dbo].[st_FindTransferToTransfer]
(    
    @BeginDate datetime = null,
    @EndDate datetime = null,
    @IdAgent int = null,    
    @StatusesPreselected XML,
    @Folio int =null,
    @IdLenguage int = null,
    @HasError bit output,
    @Message nvarchar(max) output
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
Declare @tStatus table    
      (    
       id int    
      ) 

Declare @DocHandle int    
Declare @hasStatus bit    
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected      
    
insert into @tStatus(id)     
select id    
FROM OPENXML (@DocHandle, '/statuses/status',1)     
WITH (id int)    
    
EXEC sp_xml_removedocument @DocHandle  

if @IdLenguage is null 
    set @IdLenguage=2  

Declare @Tot  int = 0

set  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  
set  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  

create table #Result
(
    DateOfTransaction datetime,
    phonenumber nvarchar(max),
    folio int,
    transactionid bigint,
    ProductName nvarchar(max),
    WholeSalePrice money,
    RetailPrice money,
    agentcode nvarchar(max),
    agentname nvarchar(max),
    country nvarchar(max),    
    idstatus  int,
    carrier nvarchar(max), 
    status nvarchar(max)
   
)

select @Tot=count(1) 
from 
 TransferTo.[TransferTTo] t with(nolock)
join
    agent a with(nolock) on t.idagent=a.idagent
join
    dbo.[OtherProductStatus] s with(nolock) on t.[IdStatus]=s.[IdStatus]
where 
    T.DateOfCreation>= isnull(@BeginDate,T.DateOfCreation) and T.DateOfCreation<= isnull(@EndDate,T.DateOfCreation)
    and
    t.IdAgent=isnull(@IdAgent,t.Idagent)
    and
    t.IdStatus in (select id from @tStatus)
    and
    t.IdTransferTTo=isnull(@Folio,t.IdTransferTTo)
    --and t.idstatus not in (1,21)

if @Tot<3001
begin 

insert into #Result
select 
    DateOfCreation DateOfTransaction,
    Destination_Msisdn phonenumber,
    IdTransferTTo folio,
    IdTransactionTTo transactionid,
    Product ProductName,
    WholeSalePrice,
    RetailPrice,
    agentcode,
    agentname,
    country,    
    t.idstatus  ,
    operator carrier, 
    StatusName status
from 
    TransferTo.[TransferTTo] t with(nolock)
join
    agent a with(nolock) on t.idagent=a.idagent
join
    dbo.[OtherProductStatus] s with(nolock) on t.[IdStatus]=s.[IdStatus]
where 
    T.DateOfCreation>= isnull(@BeginDate,T.DateOfCreation) and T.DateOfCreation<= isnull(@EndDate,T.DateOfCreation)
    and
    t.IdAgent=isnull(@IdAgent,t.Idagent)
    and
    t.IdStatus in (select id from @tStatus)
    and
    t.IdTransferTTo=isnull(@Folio,t.IdTransferTTo);
    --and t.idstatus not in (1,21)

end

--if @Tot=0
--begin
-- SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),@HasError=1
--end
--else
if @Tot>3000
begin
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError=1
end
else
begin
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError=0
end

select
    DateOfTransaction,
    phonenumber,
    folio,
    transactionid,
    ProductName,
    WholeSalePrice,
    RetailPrice,
    agentcode,
    agentname,
    country,
    idstatus,
    carrier,
    status
from #Result
order by folio;

    