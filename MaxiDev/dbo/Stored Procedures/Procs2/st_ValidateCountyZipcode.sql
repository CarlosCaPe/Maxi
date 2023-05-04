CREATE PROCEDURE [dbo].[st_ValidateCountyZipcode]
(
    @ZipCode int,
    @IdState int,
    @IdLenguage int,
    @MessageError nvarchar(max) out,
    @HasError bit Out
)
as
--declare @zipcode int = 96671
--declare @idstate int = 418


/*store*/
declare @StateCode nvarchar(max)

create table #temp
(
    zipcode int,
    cityname nvarchar(max)
)

set @HasError=0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'VALIDATECOUNTY')

select @StateCode=statecode from state where idstate=@idstate

if not exists (select top 1 1 from zipcode where zipcode=@zipcode and StateCode=@StateCode)
begin
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'VALIDATECOUNTYE1')
    set @HasError=1
    select zipcode,cityname from #temp
    RETURN
end
else
begin    
    if exists (select top 1 1 from zipcode where zipcode=@zipcode  and idcounty is not null)
    begin
        set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'VALIDATECOUNTYE2')
        set @HasError=1
        select zipcode,cityname from #temp
        RETURN
    end
    else
    begin
        insert into #temp
        select zipcode,cityname from zipcode where zipcode=@zipcode and idgenericstatus=1
    end
end

if not exists(select top 1 1 from #temp)
begin
       set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'VALIDATECOUNTYE3')
       set @HasError=1
end

select zipcode,cityname from #temp

drop table #temp
