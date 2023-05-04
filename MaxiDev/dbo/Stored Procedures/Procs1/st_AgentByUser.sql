CREATE procedure [dbo].[st_AgentByUser]
(              
@IdAgent int         
)

as 
/********************************************************************
<Author>Earreola</Author>
<app> </app>
<Description>Create Agent by User Search </Description>

<ChangeLog>
<log Date="2018-10-10" Author="earreola"> Creacion  </log>

</ChangeLog>

*********************************************************************/            
Set nocount on         


select u.IdUser,
       u.UserName,
       u.FirstName,
       u.LastName,
       u.SecondLastName,
       u.UserLogin 
  from users as u with(nolock)
 inner join AgentUser as au with(nolock) on u.IdUser = au.IdUser
 inner join Agent as a with(nolock) on au.IdAgent = a.IdAgent 
 where a.IdAgent = @IdAgent
 order by u.UserName