CREATE PROCEDURE [Corp].[st_OfacAuditHistoryByAgent]
(
	@IdAgent int,
	@IdType int
)
as
/********************************************************************
<Author>José Velarde</Author>
<app>Corporativo</app>
<Description>Obtiene historicos de Ofac Audit por tipo y Agente</Description>

<ChangeLog>
<log Date="24/01/2017" Author="jvelarde"> Creación </log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
SET NOCOUNT ON;

--bussines 1, Gurantor 2, owner 3
--5 Type,	--Agent Guarantor
--4 Type,	--Agent Owner
--6 Type,	--Agent

declare @idgeneric int

set @IdType = case 
				when @IdType = 1 then 6
				when @IdType = 2 then 5
				when @IdType = 3 then 4
				when @IdType = 4 then 8
			  end

if @IdType=4
begin
	select @idgeneric=idowner from agent with(nolock) where IdAgent=@idagent
end
else
begin
	set @idgeneric = @idagent
end

select 
CurrentName = ltrim(rtrim(d.Name+' '+d.FirstLastName+' '+d.SecondLastName)),  
LastChangeDate,s.Name StatusName,ChangeStatusNote,isnull(u.UserName,isnull(u2.UserName,'')) UserName,m.*
from ofacauditdetail d with(nolock)
join OfacAuditStatus s with(nolock) on d.IdOfacAuditStatus=s.IdOfacAuditStatus
left join users u with(nolock) on d.ChangeStatusIdUser=u.IdUser
left join users u2 with(nolock) on d.LastChangeIdUser=u2.IdUser
left join OfacAuditMatch m with(nolock) on d.IdOfacAuditDetail=m.IdOfacAuditDetail
where IdGeneric=@idgeneric and IdOfacAuditType=@IdType  AND  s.IdOfacAuditStatus IN (2,3,4)
order by d.LastChangeDate desc

