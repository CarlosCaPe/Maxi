CREATE procedure OfacInfo
(
 @idstatus int = null
)
as

select o.Name,FirstLastName,SecondLastName,s.NAme OfacAuditStatus,isnull(UserName,'') UserName,LastChangeNote,LastChangeDate 
from OfacAuditDetail o
left join users u on o.LastChangeIdUser=u.IdUser
join OfacAuditStatus s on s.IdOfacAuditStatus=o.IdOfacAuditStatus
where 
o.IdOfacAuditStatus=isnull(@idstatus,o.IdOfacAuditStatus)
--IdOfacAudit=20