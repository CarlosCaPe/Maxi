CREATE procedure [Corp].[st_GetStatusTransfer]
as
select IdStatus, StatusName from Status WITH(NOLOCK) Where IdType is null
