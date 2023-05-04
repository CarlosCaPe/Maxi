/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="14/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_UpdateUserPassword]
@IdUser int,
@salt nvarchar(50),
@UserPassword nvarchar(max),
@HasError bit out,
@Message nvarchar(max) out
AS  
Set nocount on;
Begin try
	begin transaction;
	update Users set salt = @salt, UserPassword = @UserPassword, ChangePasswordAtNextLogin = 0 where IdUser = @IdUser;

	Execute st_InsertUpdateUsersAditionalInfoChangePassword @IdUser
	Set @HasError = 0;
	Set @Message = 'Password was saved successfully';
	Commit Transaction;
End try
Begin Catch
	RollBack Transaction;
	Set @HasError = 1;
	Set @Message = 'Password was not save';
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateUserPassword',Getdate(),@ErrorMessage);
End catch
