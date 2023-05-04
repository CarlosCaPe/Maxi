CREATE procedure [Corp].[st_FindDebitHistory]     
(
    @Idagent int,
    @Date datetime
)    
as    

if @Date is not null
    Select  @Date=dbo.RemoveTimeFromDatetime(@Date) 

select 
   dateofcollection dateofdebit, 
   sum(amount)-sum(collectamount) amount, 
   --case when sum(amountbycalendar)> 0 then 1 else 0 end 
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
    maxicollection m with(nolock)
join 
    agent a with(nolock)
on    
    m.idagent=a.idagent
where 
    dateofcollection>=dbo.fn_GetDateOfDebit(@Idagent, @Date) and  dateofcollection < @Date and
    m.Idagent=@IdAgent
group by m.idagent,dateofcollection,a.DoneOnSundayPayOn, a.DoneOnMondayPayOn, a.DoneOnTuesdayPayOn, a.DoneOnWednesdayPayOn, a.DoneOnThursdayPayOn, a.DoneOnFridayPayOn, a.DoneOnSaturdayPayOn
order by dateofcollection desc
