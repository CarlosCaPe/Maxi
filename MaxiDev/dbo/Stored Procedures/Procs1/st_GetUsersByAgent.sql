--select * from Agent where AgentName like '%ficohsa%' 3902



/* Store para obtener los usuarios de una agencia, utilizado en reporting services
 * y la vista de balance por cajero.
 */
CREATE procedure [dbo].[st_GetUsersByAgent]

@IdAgent int
as

select au.IdUser, us.UserName from AgentUser au with(nolock) inner join Users us on au.IdUser = us.IdUser where IdAgent=@IdAgent and us.IdGenericStatus = 1