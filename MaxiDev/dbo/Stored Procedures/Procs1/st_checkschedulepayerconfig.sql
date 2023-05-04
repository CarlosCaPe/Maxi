CREATE procedure [dbo].[st_checkschedulepayerconfig]
/********************************************************************
<Author>Jvelarde</Author>
<app>MaxiCorp</app>
<Description>To show log info Schedule Payer Config</Description>

<ChangeLog>
<log Date="12/09/2017" Author="Jvelarde">S38_2017: Get log info </log>
</ChangeLog>
********************************************************************/
as
declare @time1 time
declare @time2 time
declare @idpayerconfig int
declare @timeStart time
declare @timeEnd time

select IdPayerConfig,EndTime into #temp1 from PayerConfig  with(nolock)
where StartTime is not null and endtime is not null and EnabledSchedule=1
order by 1 desc

select IdPayerConfig,StartTime into #temp2 from PayerConfig with(nolock) 
where StartTime is not null and endtime is not null and EnabledSchedule=1
order by 1 desc

select @time2 = DATEADD (minute,1, convert(varchar(10), GETDATE(), 108))
select @time1 = DATEADD (minute,-1, convert(varchar(10), GETDATE(), 108))

	if (@time1='23:59:00.0000000')
	begin
		set @time1 = DATEADD(minute,1,@time1)
	end

while exists (select 1 from #temp1)
begin
	select top 1 @idpayerconfig=IdPayerConfig,@timeEnd=EndTime from #temp1
	if (@timeEnd>=@time1 and @timeEnd<=@time2) 
	begin
		--select 1
		update PayerConfig set IdGenericStatus=2 where IdPayerConfig=@idpayerconfig
	end
	delete from #temp1 where IdPayerConfig=@idpayerconfig
end

while exists (select 1 from #temp2)
begin
	select top 1 @idpayerconfig=IdPayerConfig,@timeStart=StartTime from #temp2
	if (@timeStart>=@time1 and @timeStart<=@time2) 
	begin
		--select 1
		update PayerConfig set IdGenericStatus=1 where IdPayerConfig=@idpayerconfig
	end
	delete from #temp2 where IdPayerConfig=@idpayerconfig
end


drop table #temp1
drop table #temp2