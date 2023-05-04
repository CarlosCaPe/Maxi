CREATE PROCEDURE [Corp].[st_UpdateUserPassword]
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

	Execute [Corp].[st_InsertUpdateUsersAditionalInfoChangePassword] @IdUser
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_UpdateUserPassword',Getdate(),@ErrorMessage);
End catch
