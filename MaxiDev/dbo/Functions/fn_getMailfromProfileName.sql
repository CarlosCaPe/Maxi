CREATE function [dbo].[fn_getMailfromProfileName]
(@name varchar(max))
returns varchar(max)
as
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin 
declare @email varchar(max)
SELECT @email= srv.username FROM [msdb].[dbo].[sysmail_profile] pro with(nolock)
inner join msdb.dbo.sysmail_profileaccount ac with(nolock)
on ac.profile_id = pro.profile_id
inner join msdb.dbo.sysmail_server  srv with(nolock)
on srv.account_id = ac.account_id
where name =@name

return @email
end 