create procedure PrecargaProfit
as
declare   @begindate datetime = '01/01/2015'
        , @endatedatetime datetime = [dbo].[RemoveTimeFromDatetime](getdate()-1)

select @begindate,@endatedatetime

while(@begindate<=@endatedatetime)
begin
    print  (@begindate)
    exec st_SaveProfitData @begindate
    set @begindate=@begindate+1    
end