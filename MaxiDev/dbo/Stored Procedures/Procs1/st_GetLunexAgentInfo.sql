CREATE procedure [dbo].[st_GetLunexAgentInfo]
@IdAgent int,
@IdUser int
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

DECLARE @AuthKey nvarchar(max),
	@Realm nvarchar(max),
	@HostUser nvarchar(max)

Select Top 1 
	@AuthKey=AuthKey, 
	@Realm=Realm,
	@HostUser=HostUser
FROM[Lunex].[ServiceCredential] with(nolock)


select 
--u.userlogin loginmaxi,
@AuthKey [Key],
@Realm [Realm],
@HostUser HostUser,
a.AgentCode StoreId,
'M'+CONVERT(VARCHAR,AU.IDUSER*AU.IDAGENT)+'S'+CONVERT(VARCHAR,AU.IdUser) AgentId,
a.AgentName StoreName,
u.username CashierName,
a.agentcode+' '+a.Agentname DisplayName,
a.AgentName Agency,
a.AgentPhone Phone,
a.AgentEmail Email,
a.AgentAddress [Address],
a.AgentCity City,
a.AgentState [State],
a.AgentZipcode Zipcode,
sr.UserName AS SalesRep
--CASE WHEN USERLOGIN=REPLACE(AgentCode,'-','') THEN 1 ELSE 0 END ISMANAGER,
--ROW_NUMBER() OVER (PARTITION BY agentcode,agentname,CASE WHEN USERLOGIN=REPLACE(AgentCode,'-','') THEN 1 ELSE 0 END ORDER BY agentcode,agentname,CASE WHEN USERLOGIN=REPLACE(AgentCode,'-','') THEN 1 ELSE 0 END desc) AS RowFilter
from AgentUser au with(nolock) 
join agent a with(nolock) on au.idagent=a.idagent
join users u with(nolock) on au.IdUser=u.iduser
JOIN Users sr with(nolock) ON sr.IdUser = a.IdUserSeller
where au.idagent=@IdAgent and au.IdUser=@IdUser and u.IdGenericStatus=1




