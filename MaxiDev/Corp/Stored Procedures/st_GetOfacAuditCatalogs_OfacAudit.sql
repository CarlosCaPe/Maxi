CREATE PROCEDURE [Corp].[st_GetOfacAuditCatalogs_OfacAudit]
as
begin

	declare @IdUser int

	select @IdUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

    select IdOfacAudit,ExecutionDate from OfacAudit with(nolock) where IdUser=@IdUser or iduser is null

    select IdOfacAuditType, [Name] from OfacauditType with(nolock)

    select IdOfacAuditStatus, [Name] from OfacAuditStatus with(nolock)
end
