CREATE procedure [Corp].[st_GetStatusForLongDistance_Operation]
as
select IdStatus,statusname from status WITH (NOLOCK)  where idstatus in (22,30) order by statusname
