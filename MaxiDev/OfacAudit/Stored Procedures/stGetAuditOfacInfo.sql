create procedure OfacAudit.stGetAuditOfacInfo
(
    @IdOfacAudit int,
    @IdOfacAuditStatus int = null,
    @IdOfacAuditType int = null,
    @filter NVARCHAR(MAX) = NULL,
    @PageIndex INT = null,
    @PageSize INT = null,
    @PageCount INT OUTPUT
)
as

set @PageIndex=isnull(@PageIndex,1)
set @PageSize=isnull(@PageSize,10)

Select @filter=upper(isnull(@filter,'')),       
       @PageIndex=@PageIndex-1


Create Table #temp      
(    
    Id  int identity (1,1),
    IdOfacAuditDetail int,
    IdOfacaudit int,
    AgentCode nvarchar(max),
    Name nvarchar(max),
    FirstLastName nvarchar(max),
    SecondLastName nvarchar(max),
    IdOfacAuditStatus int,
    Status nvarchar(max),
    IdOfacAuditType int,
    Type nvarchar(max),
    ChangeStatusIdUser int,
    ChangeStatusUserName nvarchar(max),
    ChangeStatusNote nvarchar(max),
    LastChangeDate datetime,
    LastChangeNote nvarchar(max),
    LastChangeIP nvarchar(max),
    LastChangeIdUser int,
    LastChangeUserName nvarchar(max),
    IdGeneric int
)     

 

;WITH cte AS
(
SELECT  
  ROW_NUMBER() OVER(
    ORDER BY a.AgentCode,a.Name,a.FirstLastName,a.SecondLastName        
   )RowNumber,
    IdOfacAuditDetail,IdOfacaudit,AgentCode,a.Name,FirstLastName,a.SecondLastName,a.IdOfacAuditStatus,s.Name Status,a.IdOfacAuditType,t.Name Type ,ChangeStatusIdUser, isnull(u1.UserName,'') ChangeStatusUserName,isnull(ChangeStatusNote,'') ChangeStatusNote,LastChangeDate,isnull(LastChangeNote,'') LastChangeNote,isnull(LastChangeIP,'') LastChangeIP,LastChangeIdUser, isnull(u2.UserName,'') LastChangeUserName,IdGeneric
    from 
        OfacAuditDetail a
    join
        OfacAuditStatus s on a.IdOfacAuditStatus=s.IdOfacAuditStatus
    join
        OfacAuditType t on a.IdOfacAuditType=t.IdOfacAuditType
    left join
        users u1 on a.ChangeStatusIdUser=u1.iduser --and u1.iduser!=dbo.GetGlobalAttributeByName('SystemUserID')
    left join
        users u2 on a.LastChangeIdUser=u2.iduser --and u2.iduser!=dbo.GetGlobalAttributeByName('SystemUserID')
    where 
        IdOfacAudit=isnull(@IdOfacAudit,IdOfacAudit) and
        a.IdOfacAuditStatus=isnull(@IdOfacAuditStatus,a.IdOfacAuditStatus) and
        a.IdOfacAuditType=isnull(@IdOfacAuditType,a.IdOfacAuditType)  and        
        (agentcode like '%'+@filter+'%' or a.name like '%'+@filter+'%' or a.FirstLastName like '%'+@filter+'%'/* or FirstLastName like '%'+@filter+'%'*/)
)
INSERT INTO #temp
SELECT  IdOfacAuditDetail,IdOfacaudit,AgentCode,Name,FirstLastName,SecondLastName,IdOfacAuditStatus,Status,IdOfacAuditType,Type,ChangeStatusIdUser,ChangeStatusUserName,ChangeStatusNote,LastChangeDate,LastChangeNote,LastChangeIP,LastChangeIdUser,LastChangeUserName,IdGeneric
FROM    cte
ORDER BY RowNumber

SELECT @PageCount = COUNT(1) FROM #temp

--SALIDA
SELECT /*id,*/IdOfacAuditDetail,IdOfacaudit,AgentCode,Name,FirstLastName,SecondLastName,IdOfacAuditStatus,Status,IdOfacAuditType,Type,ChangeStatusIdUser,ChangeStatusUserName,ChangeStatusNote,LastChangeDate,LastChangeNote,LastChangeIP,LastChangeIdUser,LastChangeUserName,IdGeneric FROM #temp
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize