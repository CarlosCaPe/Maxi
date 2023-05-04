CREATE Procedure [dbo].[st_ServiceWatcher]
as
/*NEW*/

Declare @Now Datetime,@Times Int,@Hour int, @IdGateway int, @Gatewayname nvarchar(max), @Message nvarchar(max)
Set @Now=GETDATE()
Set @Times=4
Select @Hour=DatePart(HOUR,@Now)*100+DatePart(MINUTE,@Now)

Select idgateway,gatewayname into #gatewaytmp from Gateway A with (nolock)
Join ServiceTimer B with (nolock) on (A.Code=B.Code)
Where Status=1 and 
NextScheduleTime<DateAdd(minute,-((Interval/60000)*@Times),@Now) and 
@Hour>CONVERT(int,Replace(B.StartTime,':','')) and
@Hour<CONVERT(int,Replace(B.EndTime,':',''))
and IdGateway!=35--Se omite en lo que se activa dicho gateway

while exists(select top 1 1 from #gatewaytmp)
begin
    select top 1 @IdGateway=idgateway, @Gatewayname=gatewayname from #gatewaytmp

    set @Message='MAXI PROD GATEWAY SERVICE STOPPED - ' + @Gatewayname

    EXEC st_SendMail @Message,@Message

    delete from #gatewaytmp where idgateway=@IdGateway
end

/*OLD*/
/*
Declare @Now Datetime,@Times Int,@Hour int
Set @Now=GETDATE()
Set @Times=4
Select @Hour=DatePart(HOUR,@Now)*100+DatePart(MINUTE,@Now)


If Exists
(
Select 1 from Gateway A
Join ServiceTimer B on (A.Code=B.Code)
Where Status=1 and 
NextScheduleTime<DateAdd(minute,-((Interval/60000)*@Times),@Now) and 
@Hour>CONVERT(int,Replace(B.StartTime,':','')) and
@Hour<CONVERT(int,Replace(B.EndTime,':',''))
)
Begin
 EXEC st_SendMail 'MAXI PROD GATEWAY SERVICE STOPPED','MAXI PROD GATEWAY SERVICE STOPPED'      
End
*/