CREATE procedure st_GetStatusTransfer
as
select IdStatus, StatusName from Status Where IdType is null
