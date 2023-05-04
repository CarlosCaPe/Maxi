CREATE procedure [dbo].[AutoCallAssigment]
as
--1	Open
--2	In Progress
--3	Closed

return

--declare @ApplyDate datetime
--declare @today int
--declare @iduser int


--set @ApplyDate=[dbo].[RemoveTimeFromDatetime](getdate()-1)
--Select  @today=[dbo].[GetDayOfWeek] (@ApplyDate)   

--select @iduser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

--if @today=6 or @today=7
--begin            
--    select @ApplyDate = case 
--                        when @today=6 then
--                            @ApplyDate-1 
--                        when @today=7 then
--                            @ApplyDate-2
--                        else
--                            @ApplyDate
--                        end
--end

--insert into [CallHistory]
--select distinct idagent,@iduser,idcallstatus,getdate(),'Assigned by System',0 from dbo.[CallHistory] where idcallstatus=2 and idagent not in (
--select idagent from dbo.[CallHistory] where @ApplyDate=[dbo].[RemoveTimeFromDatetime](DateOfLastChange) and idcallstatus=3
--)
--and
--@ApplyDate=[dbo].[RemoveTimeFromDatetime](DateOfLastChange)

--insert into maxicollectionassign
--select idagent,m.iduser,[dbo].[RemoveTimeFromDatetime](getdate()) 
--from 
--    MaxiCollectionAssign m
--join users u on u.iduser=m.iduser
--where 
--    @ApplyDate=[dbo].[RemoveTimeFromDatetime](DateOfAssign)
--and u.IdGenericStatus=1
--and idagent in
--(
--select distinct idagent from dbo.[CallHistory] where idcallstatus=2 and idagent not in (
--select idagent from dbo.[CallHistory] where @ApplyDate=[dbo].[RemoveTimeFromDatetime](DateOfLastChange) and idcallstatus=3
--)
--and
--@ApplyDate=[dbo].[RemoveTimeFromDatetime](DateOfLastChange)
--)