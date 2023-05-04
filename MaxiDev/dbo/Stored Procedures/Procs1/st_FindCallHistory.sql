create procedure [dbo].[st_FindCallHistory]     
(
    @Idagent int,
    @BeginDate datetime,
    @EndDate datetime
)    
as    

if @BeginDate is not null    
    Select  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  

if @EndDate is not null
    Select  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1) 

select 
    h.iduser,u.Userlogin,s.name statusname,note,h.DateOfLastChange DateCall
from 
    callhistory h
join
    users u on h.iduser=u.iduser
join
    callstatus s on h.IdCallStatus=s.IdCallStatus
where
    (h.idagent=@Idagent) and (h.DateOfLastChange>=@BeginDate and h.DateOfLastChange<=@EndDate)