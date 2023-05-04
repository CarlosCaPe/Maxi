create procedure operation.st_GetStatusForLongDistance
as
select IdStatus,statusname from status where idstatus in (22,30) order by statusname
