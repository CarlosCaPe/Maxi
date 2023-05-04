-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Jun-12
-- Description:	Update the Messages
-- =============================================
CREATE Procedure [Teleprompter].[st_UpdateMessage]
(	
	@StateCode nvarchar(12),
	@MsgEs nvarchar(max),
	@MsgEn nvarchar(max),
	
	@EnterByIdUser int,
    @HasError bit out,
	@Message varchar(max) out
)
as
Begin Try

set @HasError = 0;

IF EXISTS(SELECT TOP 1 1 FROM [Teleprompter].[MessagesToClose] WITH(NOLOCK)
					WHERE [StateCode] = @StateCode)
BEGIN

	SET @Message ='The message was successfully updated.';

	UPDATE [Teleprompter].[MessagesToClose]
	SET 
      [MessageEn] = @MsgEn
      ,[MessageEs] = @MsgEs
      ,[EnterByIdUser] = @EnterByIdUser
	 WHERE [StateCode] = @StateCode;

END

ELSE
BEGIN

	SET @Message ='The message was successfully saved.';

	INSERT INTO [Teleprompter].[MessagesToClose]
           ([StateCode]
           ,[MessageEn]
           ,[MessageEs]
           ,[EnterByIdUser])
     VALUES
           (@StateCode
           ,@MsgEn
           ,@MsgEs
           ,@EnterByIdUser);

END

End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Teleprompter.st_UpdateMessage',Getdate(),@ErrorMessage);
End Catch
