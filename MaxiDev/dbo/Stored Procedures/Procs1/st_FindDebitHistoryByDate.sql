create procedure [dbo].[st_FindDebitHistoryByDate]     
(
    @Idagent int,
    @BeginDate datetime,
    @EndDate datetime
)    
as    

Select   @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate) 
        ,@EndDate=dbo.RemoveTimeFromDatetime(@EndDate) + 1

--select @BeginDate,@EndDate

select 
   dateofcollection dateofdebit, sum(amount)-sum(collectamount) amount, 
   --case when sum(amountbycalendar)> 0 then 1 else 0 end IsPayDay
   case 
        when dbo.[GetDayOfWeek](dateofcollection) = DoneOnSundayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnMondayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnTuesdayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnWednesdayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnThursdayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnFridayPayOn	or
             dbo.[GetDayOfWeek](dateofcollection) = DoneOnSaturdayPayOn then 1
        else
            0
   end
   IsPayDay
from 
    maxicollection m
join 
    agent a
on    
    m.idagent=a.idagent
where 
    dateofcollection>=@BeginDate and  dateofcollection < @EndDate and
    m.Idagent=@IdAgent
group by m.idagent,dateofcollection,a.DoneOnSundayPayOn, a.DoneOnMondayPayOn, a.DoneOnTuesdayPayOn, a.DoneOnWednesdayPayOn, a.DoneOnThursdayPayOn, a.DoneOnFridayPayOn, a.DoneOnSaturdayPayOn
order by dateofcollection desc