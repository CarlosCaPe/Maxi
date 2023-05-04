CREATE PROCEDURE [Corp].[st_GetReportEgift_Operation]
(
    @BeginDate datetime = null,
    @EndDate datetime = null,
    @IdProvider int = null,
    @IdAgent int = null,    
    @StatusesPreselected XML,
    @Folio int =null,
    @IdLenguage int = null,
    @FullResult BIT = 0,
	@CellPhone nvarchar(max),
    @HasError bit output,
    @Message nvarchar(max) output
)
as
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
    folio bigint,
    transactionid bigint,
    ProductName nvarchar(max),
    amount money,
    agentcode nvarchar(max),
    agentname nvarchar(max),  
    idstatus  int,
    status nvarchar(max),
    idprovider int,
    providername nvarchar(max),
    cellPhone nvarchar(max),
    Username nvarchar(max)   
)

select @Tot=count(1) from operation.ProductTransfer t WITH (NOLOCK)
	join agent a  WITH (NOLOCK) on t.idagent = a.idagent
	join dbo.[OtherProductStatus] s  WITH (NOLOCK) on t.[IdStatus] = s.[IdStatus]
where t.IdOtherProduct = 11
	and T.DateOfCreation >= isnull(@BeginDate,T.DateOfCreation) and T.DateOfCreation <= isnull(@EndDate, T.DateOfCreation)
	and t.IdAgent = isnull(@IdAgent,t.Idagent)
	and t.IdStatus in (select id from @tStatus)
	and t.IdProductTransfer = isnull(@Folio, t.IdProductTransfer)    
    and t.IdProvider = isnull(@IdProvider, t.idprovider)
	and t.IdProductTransfer in (select IdProductTransfer from lunex.transferln WITH (NOLOCK) where Phone like '%'+isnull(@CellPhone,'')+'%')
    
if @Tot < 3001 OR @FullResult = 1
begin 
	insert into #Result
	select t.DateOfCreation DateOfTransaction, dbo.[fnFormatPhoneNumber](tt.TopupPhone) phonenumber, 
		t.IdProductTransfer folio, t.TransactionProviderID transactionid, tt.skuname ProductName, tt.amount, 
		agentcode, agentname, t.idstatus, StatusName status, t.idprovider, pr.providername, tt.Phone,isnull(u.UserName,'') UserName
	from operation.ProductTransfer t  WITH (NOLOCK)
		join lunex.TransferLN tt   WITH (NOLOCK) on t.IdProductTransfer=tt.IdProductTransfer and tt.Phone like '%'+isnull(@CellPhone, '')+'%'
		join agent a  WITH (NOLOCK) on t.idagent = a.idagent
		join dbo.status s  WITH (NOLOCK) on t.[IdStatus] = s.[IdStatus]
		join providers pr  WITH (NOLOCK) on pr.idprovider = t.idprovider
        left join users u  WITH (NOLOCK) on t.EnterByIdUser=u.IdUser
	where T.DateOfCreation >= isnull(@BeginDate, T.DateOfCreation) and T.DateOfCreation <= isnull(@EndDate, T.DateOfCreation)
		and t.IdAgent = isnull(@IdAgent, t.Idagent)
		and t.IdStatus in (select id from @tStatus)
		and t.IdProductTransfer = isnull(@Folio, t.IdProductTransfer)
		and t.idotherproduct = 11 
		and t.IdProvider = isnull(@IdProvider, t.idprovider)
end
if @Tot>3000 AND @FullResult=0
begin
    SELECT @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError = 1
end
else
begin
    SELECT @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError = 0
end

select DateOfTransaction, phonenumber, folio, transactionid, ProductName, amount, agentcode, agentname, idstatus, status, idprovider, providername, cellPhone,Username from #Result order by DateOfTransaction DESC
