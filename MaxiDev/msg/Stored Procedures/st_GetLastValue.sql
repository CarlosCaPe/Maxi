

/*******************/
/* st_GetLastValue */
/*******************/
CREATE Procedure [msg].[st_GetLastValue]
(
    @idMessageProvider int,
    @userSession nvarchar(max),
    @currentValue nvarchar(max)
)
as
declare @lastValue nvarchar(max)

Select top 1 @lastValue=LastValueRetrieved From [msg].MessageLastValues with (nolock) Where IdMessageProvider = @idMessageProvider and UserSession = @userSession

If (@lastValue is null)
Begin
    Insert into [msg].MessageLastValues values (@idMessageProvider,@userSession,@currentValue);
    Select @currentValue as Value, @@IDENTITY as IdMessageLastValue
End
Else
Begin
    If(@lastValue <> @currentValue)
    Begin
		Update [msg].MessageLastValues set LastValueRetrieved = @currentValue Where IdMessageProvider = @idMessageProvider and UserSession = @userSession;
		Select LastValueRetrieved as Value, IdMessageLastValue From [msg].MessageLastValues with (nolock) Where IdMessageProvider = @idMessageProvider and UserSession = @userSession
		--Select @currentValue as Value
    End
End

