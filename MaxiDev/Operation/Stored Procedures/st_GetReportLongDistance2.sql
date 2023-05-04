create procedure [Operation].[st_GetReportLongDistance2]
(
    @DateFrom datetime,
    @DateTo datetime,
    @IdProvider int = null,
    @IdStatus int = null,
    @IdAgent int = null,
    @Folio int = null,
    @IsCancel bit,
    @IdLenguage int = null,
    @FullResult BIT = 0,
	@CellPhone varchar(max),
    @HasError bit output,
    @Message nvarchar(max) output
)
as
if @IdLenguage is null 
    set @IdLenguage=2  

Declare @Tot  int = 0

set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

declare @CellPhoneWithFormat VARCHAR(MAX)

if len(@CellPhone) = 10
begin 
	set @CellPhoneWithFormat = '('+SUBSTRING(@CellPhone, 0, 4)+') '+ SUBSTRING(@CellPhone, 4, 3)+ '-'+ SUBSTRING(@CellPhone, 7, 4)
end
ELSE
BEGIN
	set @CellPhoneWithFormat = @CellPhone
END

create table #Result
(
    IdProductTransfer bigint,
    AgentCode nvarchar(max),
    AgentName nvarchar(max),
    Folio int,
    Amount money,
    Date datetime,
    Customer nvarchar(max),
    TransactionProviderID nvarchar(max),
    STATUS nvarchar(max),
    ProviderName nvarchar(max),
    CellPhone nvarchar(max),
)

if @IsCancel = 1 
begin

	select @Tot = count(1) from operation.producttransfer t with(nolock)
		join Agent a with(nolock) on a.IdAgent = t.IdAgent
		left join Users u with(nolock) on u.IdUser = t.enterbyiduser
		left join Users u2 with(nolock) on u2.IdUser = t.enterbyidusercancel
		join status PS with(nolock) on ps.Idstatus=t.idstatus
	where t.idotherproduct = 5 
		and (t.DateOfCreation >= @DateFrom and t.DateOfCreation<@DateTo) 
		and t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
		and t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
		and a.IdAgent = isnull(@IdAgent, a.IdAgent) 
		and t.amount > 0
		and IdProvider = isnull(@IdProvider, IdProvider)
		and DATEDIFF(MINUTE, t.DateOfCreation, getdate()) < 1440

	if @Tot < 3001 OR @FullResult = 1
	begin
		insert into #Result 
			(IdProductTransfer,AgentCode,Folio,Amount,Date,Customer,TransactionProviderID,STATUS,ProviderName)
			select t.IdProductTransfer, 
				a.AgentCode,
				t.Idproducttransfer Folio,
				t.amount Amount,
				t.DateOfCreation Date,
				Isnull(pm.SenderName,'') +' '+ Isnull(pm.SenderFirstLastName,'') +' '+ Isnull(pm.SenderSecondLastName,'') Customer,
				t.TransactionProviderID,
				Ps.StatusName STATUS,
				Providername 
			from operation.producttransfer t with(nolock)
				join Agent a with(nolock) on a.IdAgent=t.IdAgent
				left join Users u with(nolock) on u.IdUser= t.enterbyiduser
				left join Users u2 with(nolock) on u2.IdUser= t.enterbyidusercancel
				join status PS with(nolock) on ps.idstatus=t.idstatus
				join pureminutestransaction pm with(nolock) on pm.Idproducttransfer=t.Idproducttransfer
				join providers p with(nolock) on t.idprovider=p.idprovider
			where t.idotherproduct=5 
			and (t.DateOfCreation>=@DateFrom and t.DateOfCreation<@DateTo) 
			and t.idstatus=isnull(@IdStatus,t.idstatus) and t.idstatus not in (1)
			and t.Idproducttransfer=isnull(@Folio,t.Idproducttransfer)
			and a.IdAgent=isnull(@IdAgent,a.IdAgent) 
			and t.amount>0
			and t.IdProvider = isnull(@IdProvider,t.IdProvider)
			and DATEDIFF(MINUTE, t.DateOfCreation, getdate())<1440
	end
end
else
begin

	select @Tot = count(1) from operation.producttransfer t with(nolock) 
		join Agent a with(nolock) on a.IdAgent = t.IdAgent
		left join Users u with(nolock) on u.IdUser = t.enterbyiduser
		left join Users u2 with(nolock) on u2.IdUser = t.enterbyidusercancel
		join status PS with(nolock) on ps.idstatus = t.idstatus
	where t.idotherproduct  in (5, 10)
		and (t.DateOfCreation >= @DateFrom and t.DateOfCreation < @DateTo)
		and t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
		and t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
		and IdProvider = isnull(@IdProvider, IdProvider)
		and a.IdAgent = isnull(@IdAgent, a.IdAgent)
		and t.IdProductTransfer in (select IdProductTransfer from lunex.transferln with(nolock) where Phone like '%'+isnull(@CellPhone,'')+'%' 
		union select IdProductTransfer from pureminutestransaction with(nolock) where SenderPhoneNumber like '%'+isnull(@CellPhoneWithFormat,'')+'%')

	print(@Tot)

	if @Tot<3001 OR @FullResult=1
	begin    

		print('pureminutestransaction')
		insert into #Result
		select 
			t.IdProductTransfer,
			a.AgentCode,
			a.AgentName,
			t.Idproducttransfer Folio,
			t.amount Amount,
			t.DateOfCreation Date,
			Isnull(pm.SenderName,'') +' '+ Isnull(pm.SenderFirstLastName,'') +' '+ Isnull(pm.SenderSecondLastName,'') Customer,
			t.TransactionProviderID,
			Ps.StatusName STATUS,
			providername, 
			pm.ReceiveAccountNumber as 'CellPhone'
		from operation.producttransfer t with(nolock)
			join Agent a with(nolock) on a.IdAgent=t.IdAgent
			left join Users u with(nolock) on u.IdUser= t.enterbyiduser
			left join Users u2 with(nolock) on u2.IdUser= t.enterbyidusercancel
			join status PS with(nolock) on ps.idstatus=t.idstatus
			join pureminutestransaction pm with(nolock) on pm.Idproducttransfer=t.Idproducttransfer and pm.ReceiveAccountNumber like '%'+isnull(@CellPhoneWithFormat, '')+'%'
			join providers p with(nolock) on t.idprovider=p.idprovider
		where t.idotherproduct=5 
			and (t.DateOfCreation>=@DateFrom and t.DateOfCreation<@DateTo) 
			and t.idstatus=isnull(@IdStatus,t.idstatus) and t.idstatus not in (1)
			and t.Idproducttransfer=isnull(@Folio,t.Idproducttransfer)
			and t.IdProvider = isnull(@IdProvider,t.IdProvider)
			and a.IdAgent=isnull(@IdAgent,a.IdAgent)

		print('lunex')
			
		insert into #Result
		select 
			t.IdProductTransfer,
			a.AgentCode,
			a.AgentName,
			t.Idproducttransfer Folio,
			t.amount Amount,
			t.DateOfCreation Date,
			pm.SenderName Customer,
			t.TransactionProviderID,
			Ps.StatusName STATUS,
			providername,
			pm.Phone as 'CellPhone'
		from operation.producttransfer t with(nolock)
			join Agent a with(nolock) on a.IdAgent = t.IdAgent
			left join Users u with(nolock) on u.IdUser = t.enterbyiduser
			left join Users u2 with(nolock) on u2.IdUser = t.enterbyidusercancel
			join status PS with(nolock)on ps.idstatus = t.idstatus
			join lunex.transferln pm with(nolock) on pm.Idproducttransfer = t.Idproducttransfer and pm.Phone like '%'+isnull(@CellPhone, '')+'%'
			join providers p with(nolock) on t.idprovider = p.idprovider
		where t.idotherproduct = 10
			and (t.DateOfCreation >= @DateFrom and t.DateOfCreation < @DateTo) 
			and t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
			and t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
			and t.IdProvider = isnull(@IdProvider, t.IdProvider)
			and a.IdAgent = isnull(@IdAgent, a.IdAgent)      
	end
end

if @Tot > 3000 AND @FullResult = 0
begin
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError=1
end
else
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError=0

select * from #Result
order by Folio