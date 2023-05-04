CREATE PROCEDURE [Corp].[st_GetAgentOfacNoteHistory]
(
  @IdAgentApplicationHistory INT,
  @IdType int = null
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @IdAgentApp int
declare @idgeneric int

Declare @IdType2 int

set @IdType2 = case 
				when @IdType = 1 then 6
				when @IdType = 2 then 5
				when @IdType = 3 then 4
			  end

declare @TableTmp table
(
	ID INT IDENTITY	,
	IdAgentOfacNoteHistory	int,
	AgentStatus	nvarchar(max),
	Note nvarchar(max),
	UserName nvarchar(max),
	DateOfMovement	datetime,
	IdType int
);

 
select @IdAgentApp=IdAgentApplication from RelationAgentApplicationWithAgent with(nolock) where IdAgent=@IdAgentApplicationHistory

insert into @TableTmp
SELECT 
	A.IdAgentOfacNoteHistory, 
	AT.AgentStatus, 
	A.Note, 
	U.UserName, 
	A.DateOfMovement, 
	A.IdType 
FROM 
	AgentOfacNoteHistory A with(nolock)
INNER JOIN 
	Users U with(nolock) ON (A.IdUserLastChange = U.IdUser)
INNER JOIN 
	AgentStatus AT with(nolock) ON (AT.IdAgentStatus = A.IdAgentStatus)
WHERE 
	IdAgent = @IdAgentApplicationHistory and A.IdType=isnull(@IdType,A.IdType)

IF (@IdAgentApp is not null)
begin
insert into @TableTmp
select 
	a.IdAgentApplicationStatusHistory IdAgentOfacNoteHistory,
	s.StatusName AgentStatus,
	a.Note,
	U.UserName,
	A.DateOfMovement, 
	A.IdType 
from 
	AgentApplicationStatusHistory a with(nolock)
join
	AgentApplicationStatuses s with(nolock) on 	a.IdAgentApplicationStatus = s.IdAgentApplicationStatus
join
	Users U with(nolock) ON (A.IdUserLastChange = U.IdUser)
where 
	IdAgentApplication=@IdAgentApp and A.IdType=isnull(@IdType,A.IdType)
end

if @IdType2=4
begin
	select @idgeneric=idowner from agent with(nolock) where IdAgent=@IdAgentApplicationHistory
end
else
begin
	set @idgeneric = @IdAgentApplicationHistory
end

--Se registra la busqueda OFAC 
insert into @TableTmp

select 
IdOfacAuditDetail, 
AgentStatus=(SELECT TOP 1 ast.AgentStatus FROM AgentStatusHistory hist with(nolock)
	JOIN AgentStatus ast with(nolock) ON ast.IdAgentStatus = hist.IdAgentStatus 
	WHERE IdAgent =1242 AND DateOfchange <= LastChangeDate ORDER BY DateOfchange DESC ), 
'OFAC '+CASE d.IdOfacAuditType WHEN 6 THEN 'Business' WHEN 5 THEN 'Guarantor' WHEN 4 THEN 'Owner' END +' Revision', isnull(u2.UserName,u.username) UserName, dateadd(millisecond,IdOfacAuditDetail-500,LastChangeDate), CASE d.IdOfacAuditType WHEN 6 THEN 1 WHEN 5 THEN 2 WHEN 4 THEN 3 END 
from ofacauditdetail d with(nolock)
JOIN OfacAuditStatus st with(nolock)
ON st.IdOfacAuditStatus = d.IdOfacAuditStatus
JOIN OfacAudit oa with(nolock)
ON oa.IdOfacAudit = d.IdOfacAudit 
left join users u with(nolock) on d.ChangeStatusIdUser=u.IdUser
left join users u2 with(nolock) on d.LastChangeIdUser=u2.IdUser
WHERE
(oa.IdUser = 37 OR oa.IdUser IS NULL) -- Solo ejecuciones de sistema, el resto se logean en las otras 2 queries
AND d.IdOfacAuditType IN (4,5,6) --Solo Owner, Business y Guarantor 
AND d.IdGeneric=@idgeneric and d.IdOfacAuditType=isnull(@IdType2,d.IdOfacAuditType) --SI SE FILTRA APLICAR FILTRO sino solo muestra Owner, Business y Guarantor

--Se registra el Resultado de la busqueda OFAC
UNION 
select 
IdOfacAuditDetail, 
AgentStatus=(SELECT TOP 1 ast.AgentStatus FROM AgentStatusHistory hist with(nolock)
	JOIN AgentStatus ast with(nolock) ON ast.IdAgentStatus = hist.IdAgentStatus 
	WHERE IdAgent =1242 AND DateOfchange <= LastChangeDate ORDER BY DateOfchange DESC ), 
'OFAC '+st.Name, isnull(u2.UserName,u.username) UserName, dateadd(millisecond,IdOfacAuditDetail,LastChangeDate), CASE d.IdOfacAuditType WHEN 6 THEN 1 WHEN 5 THEN 2 WHEN 4 THEN 3 END 
from ofacauditdetail d with(nolock)
JOIN OfacAuditStatus st with(nolock)
ON st.IdOfacAuditStatus = d.IdOfacAuditStatus
JOIN OfacAudit oa with(nolock)
ON oa.IdOfacAudit = d.IdOfacAudit 
left join users u with(nolock) on d.ChangeStatusIdUser=u.IdUser
left join users u2 with(nolock) on d.LastChangeIdUser=u2.IdUser
WHERE
(oa.IdUser = 37 OR oa.IdUser IS NULL) -- Solo ejecuciones de sistema, el resto se logean en las otras 2 queries
AND d.IdOfacAuditType IN (4,5,6) --Solo Owner, Business y Guarantor
AND d.IdGeneric=@idgeneric and d.IdOfacAuditType=isnull(@IdType2,d.IdOfacAuditType) --SI SE FILTRA APLICAR FILTRO sino solo muestra Owner, Business y Guarantor



select 
	IdAgentOfacNoteHistory,AgentStatus,Note,UserName,DateOfMovement,IdType 
from 
	@TableTmp A
ORDER BY A.DateOfMovement DESC , IdType ,IdAgentOfacNoteHistory ASC 

