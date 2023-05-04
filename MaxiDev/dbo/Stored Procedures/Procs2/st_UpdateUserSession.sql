CREATE procedure [dbo].[st_UpdateUserSession](@idUser int, @iP varchar(50), @SessionGuid uniqueidentifier, @isValid bit out )
as

BEGIN 


DECLARE @time DATETIME, @user INT 
select @time = LastAccess, @user=IdUser from UsersSession WITH (NOLOCK) where IdUser=@idUser and  SessionGuid =@SessionGuid and  IP=@iP

if @user IS NOT NULL 
Begin
	set @isValid =1
	
	IF datediff(second,@time,getDate()) >= 10 BEGIN 

		update UsersSession set LastAccess=GETDATE()
			where IdUser=@idUser and  SessionGuid =@SessionGuid and  IP=@iP	
	END 
End
else
	set @isValid =0

End

