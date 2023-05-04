CREATE PROCEDURE [ExRateService].[st_GetExRateSchedule]
(
    @IdCountryCurrency int,
    @IdGateway int = null,
    @IdPayer int  = null,
    @ShowDisable bit = null,
    @BeginDate datetime = null,
    @EndDate datetime = null
)
as

set @ShowDisable = isnull(@ShowDisable,0)
set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                      
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1) 

select IdExRateSchedule,IdCountryCurrency,IdGateway,IdPayer,ExRate,ScheduleDate,r.EnterByIdUser,UserName,r.DateOfLastChange,ServiceApplyDate,IsApply
from 
    ExRateService.ExRateSchedule r
join
    users u on r.EnterByIdUser=u.iduser
where 
    isnull(IdCountryCurrency,0)=isnull(@IdCountryCurrency,0) and 
    isnull(IdGateway,0)=isnull(@IdGateway,0) and 
    isnull(IdPayer,0)=isnull(@IdPayer,0) and 
    r.IdGenericStatus= case when @ShowDisable=1 then r.IdGenericStatus else 1 end and
    ScheduleDate>=isnull(@BeginDate,ScheduleDate) and ScheduleDate<=isnull(@EndDate,ScheduleDate)
order by ScheduleDate desc
