CREATE PROCEDURE [Corp].[st_AddNoteAgentException]
(
 @IdLenguage int,
 @IdAgent Int,
 @Exception bit,
 @IdUser int,
 @Note nvarchar(max),
 @HasError bit OUTPUT,
 @Message nvarchar(max) OUTPUT      
)            
AS            
Set nocount on

Begin Try

	declare @IsSpanishLenguage bit

	set @IsSpanishLenguage = case when isnull(@IdLenguage,1)=1 then 0 else 1 end

	Insert into AgentException
		(IdAgent,Exception,IdUser,Note,EnterDate)
	Values
		(@IdAgent,@Exception,@IdUser,@Note,getdate());

	Set @HasError=0;
	SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLenguage,81)

  End Try
Begin Catch
	 Set @HasError=1;
	 SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLenguage,81)

	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE();
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_AddNoteAgentException]',Getdate(),@ErrorMessage);
End Catch

