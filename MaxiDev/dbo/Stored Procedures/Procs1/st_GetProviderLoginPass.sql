create procedure st_GetProviderLoginPass
(
    @UserLogin nvarchar(max)
)
as
(
    select [Password] from providercredential where login=@UserLogin and idgenericstatus=1
)

--exec st_GetProviderLoginPass 'ffff'