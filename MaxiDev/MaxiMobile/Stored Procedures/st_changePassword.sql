CREATE PROCEDURE [MaxiMobile].[st_changePassword]
(
	@IdUser int,
	@UserLogin nvarchar(500),
	@UserPass nvarchar(500),
	@NewPass nvarchar(500),
	@Returncode int output,
	@MsgOutEs nvarchar(max) output,
	@MsgOutEn nvarchar(max) output
)
as
/********************************************************************
<Author> Jvelarde </Author>
<app> WebApi </app>
<Description> Sp para cambio de pass </Description>

<ChangeLog>
<log Date="26/10/2017" Author="jvelarde">Creation</log>
</ChangeLog>

*********************************************************************/
Declare @salt nvarchar(max)
Declare @pass nvarchar(max)

if exists(
	SELECT  top 1 1 
	FROM            
	Users U (nolock)
	where U.IdGenericStatus = 1 AND U.UserLogin = @userlogin AND U.UserPassword = dbo.fnCreatePasswordHash(@userpass, U.salt) and u.IdUser=@IdUser
)
begin
	select @salt=[dbo].[fnCreateSalt](30)
	set  @pass=dbo.fnCreatePasswordHash(@NewPass, @salt)
	update Users set UserPassword=@pass,salt=@salt where IdUser=@IdUser
	set  @MsgOutEs= 'Contraseña cambiada correctamente'
	set  @MsgOutEn= 'Password sucessfully change'
	set  @Returncode = 0
end
else
begin
	set  @MsgOutEs= 'Error al cambiar la contraseña'
	set  @MsgOutEn= 'Error in change password'
	set  @Returncode = 1
end







