CREATE procedure [OfacAudit].[st_GetOfacAuditCatalogs]
as
begin

	declare @IdUser int

	select @IdUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

    select IdOfacAudit,ExecutionDate from OfacAudit where IdUser=@IdUser or iduser is null

    select IdOfacAuditType,Name from OfacauditType

    select IdOfacAuditStatus,Name from OfacAuditStatus
end