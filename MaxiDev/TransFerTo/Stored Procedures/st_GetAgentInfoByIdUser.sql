create procedure TransferTo.st_GetAgentInfoByIdUser
@IdUser int
as
begin

	set nocount on
	select au.IdAgent, a.AgentCode
	from AgentUser au
	inner join Agent a on a.IdAgent = au.IdAgent
	where au.IdUser = @IdUser
end