--select * from Agent where AgentName like '%ficohsa%' 3902


CREATE procedure [dbo].[st_GetUserById]

@IdUser int
as

select U.UserName, U.UserLogin,U.IdUserType,UT.Name from Users U,UsersType UT with(nolock) where U.IdUser = @IdUser and UT.IdUserType=U.IdUserType
