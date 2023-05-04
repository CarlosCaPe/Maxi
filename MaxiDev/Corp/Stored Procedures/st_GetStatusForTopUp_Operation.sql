CREATE procedure [Corp].[st_GetStatusForTopUp_Operation]
as
select IdStatus, case when idstatus=21 then 'Pending' else statusname end  statusname from status WITH (NOLOCK)  where idstatus in (21,22,30) order by statusname
