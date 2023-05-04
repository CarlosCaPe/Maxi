
CREATE Procedure [dbo].[st_DismissNotificationReminder] 
( 
	 @IdAgent Int, 
	 @IsSpanishLanguage bit, 
	 @HasError bit out, 
	 @MessageOut varchar(max) out 
) 
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="23/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

Begin Try 
		
	update 
        msg.MessageSubcribers set IdMessageStatus = 4, 
        DateOfLastChange=Getdate() where IdMessage IN (SELECT IdMessage FROM [dbo].AgentNotificacionReminder WITH(NOLOCK) WHERE IdAgent=@IdAgent)
	
    update msg.[Messages] set  DateOfLastChange=Getdate() where IdMessage IN (SELECT IdMessage FROM [dbo].AgentNotificacionReminder WITH(NOLOCK) WHERE IdAgent=@IdAgent)

    DELETE FROM [dbo].AgentNotificacionReminder WHERE IdAgent=@IdAgent

	set @HasError = 0
	Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 
End Try 
Begin Catch
	 Set @HasError=1 
	 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,65) 
	 Declare @ErrorMessage nvarchar(max) 
	 Select @ErrorMessage=ERROR_MESSAGE() 
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DismissNotificationReminder',Getdate(),@ErrorMessage) 
End Catch 


