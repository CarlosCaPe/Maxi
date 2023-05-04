CREATE procedure [Corp].[st_GetAllUsers]
	@IncludeDisabled BIT = 1
AS  
Set nocount on;
Begin try
Select d.IdUser, IdUserType, [Name], IdGenericStatus, GenericStatus, UserLogin, UserName, LastAccess, AgentCode, AgentName
from 
	(SELECT u.IdUser, u.IdUserType, [Name], u.IdGenericStatus, GenericStatus, UserLogin, UserName, LastAccess
	FROM [dbo].[Users] u WITH(nolock)
	join UsersType ut WITH(nolock) on u.IdUserType = ut.IdUserType
	join GenericStatus gs WITH(nolock) on u.IdGenericStatus = gs.IdGenericStatus
	left join UsersSession us WITH(nolock) on u.IdUser = us.IdUser
	where u.IdUserType != 3
		AND ((@IncludeDisabled = 0 AND u.IdGenericStatus IN (1,3)) OR  (@IncludeDisabled = 1))) d
left join AgentUser au WITH(nolock) on d.IdUser = au.IdUser
left join Agent a WITH(nolock) on au.IdAgent = a.IdAgent


SELECT u.IdUser, u.IdUserType, [Name], u.IdGenericStatus, GenericStatus, UserLogin, UserName, DateOfLastAccess, AgentCode, AgentName
FROM [dbo].[Users] u WITH(nolock)	
left join Seller s WITH(nolock) on u.IdUser = s.IdUserSeller
join GenericStatus g WITH(nolock) on u.IdGenericStatus = g.IdGenericStatus
join UsersType ut WITH(nolock) on u.IdUserType = ut.IdUserType
left join AgentUser au WITH(nolock) on au.IdUser  = u.IdUser
left join Agent a WITH(nolock) on au.IdAgent = a.IdAgent
where u.IdUserType = 3
	AND ((@IncludeDisabled = 0 AND u.IdGenericStatus IN (1,3)) OR  (@IncludeDisabled = 1))

End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAllUsers]',Getdate(),@ErrorMessage);
End catch


