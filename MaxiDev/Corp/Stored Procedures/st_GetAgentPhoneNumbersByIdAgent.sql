CREATE procedure [Corp].[st_GetAgentPhoneNumbersByIdAgent]
 (
	@IdAgent int
 )
 AS
begin 

select Phone,Owner from 
(
	select AgentPhone as Phone, 'Agent Phone Number' as Owner,1 as priority from Agent with(nolock) where idAgent=@IdAgent
	union
	select AgentFax as Phone, 'Agent Fax Number' as Owner,2 as priority from Agent with(nolock) where idAgent=@IdAgent
	union 
	--select PhoneNumber as Phone,'Additional Phone Number' as Owner,3 as priority from AgentPhoneNumber where idAgent = @IdAgent 
	select PhoneNumber as Phone,IsNull(Comment,'') as Owner,3 as priority from AgentPhoneNumber with(nolock) where idAgent = @IdAgent 
	union 
	--select OwnerPhone as Phone, 'Owner Phone Number' as Owner,4 as priority from Agent where idAgent=@IdAgent
	--union
	--select OwnerCel as Phone, 'Owner CellPhone Number' as Owner,5 as priority from Agent where idAgent=@IdAgent
	select o.Phone as Phone,'Owner Phone Number' as Owner, 4 as priority from Owner o with(nolock)
	inner join agent a with(nolock) on o.IdOwner = a.IdOwner
	where idagent=@IdAgent
	union
	select o.Cel as Phone, 'Owner Cell Phone Number' as Owner, 5 as priority from Owner o with(nolock)
	inner join agent a with(nolock) on o.IdOwner = a.IdOwner
	where idagent=@IdAgent
	)
	phones
	order by priority asc
end
