CREATE procedure operation.st_GetStatusForTopUp
as
select IdStatus, case when idstatus=21 then 'Pending' else statusname end  statusname from status where idstatus in (21,22,30) order by statusname