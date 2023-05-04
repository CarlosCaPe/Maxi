﻿CREATE PROCEDURE [Corp].[st_SaveRefExRate]	 
	 @IdCountryCurrency int,
	 @RefExRate money,
	 @DateOfLastChange  datetime,
	 @EnterByIdUser int,
	 @IdGateway int,
	 @IdPayer int,
	 @HasError bit out,
	 @Message nvarchar(max) out
AS
begin try
	
	update dbo.RefExRate set Active=0 where idCountryCurrency=@IdCountryCurrency
	and isnull(IdPayer,0) = isnull(@IdPayer,0) and isnull(IdGateway,0)=isnull(@IdGateway,0) and Active=1

	INSERT INTO [dbo].[RefExRate]
           ([IdCountryCurrency]
           ,[RefExRate]
           ,[Active]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdGateway]
           ,[IdPayer])
     VALUES
           (@IdCountryCurrency
           ,@RefExRate
           ,1 
           ,@DateOfLastChange
           ,@EnterByIdUser
           ,@IdGateway
           ,@IdPayer)
	Set @HasError = 0
	Set @Message = 'Reference Exchange Rate has been successfully saved'
	
end try
begin catch
	Set @HasError = 1
	Set @Message = 'Reference Exchange Rate was not save'
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveRefExRate',Getdate(),@ErrorMessage);
end catch

