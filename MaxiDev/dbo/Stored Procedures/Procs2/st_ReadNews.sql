create procedure st_ReadNews
(
    @IdAgent int,
    @IdNews int,
    @IdUser int,
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Begin Try

insert into [AgentNews] ([IdNews],[IdAgent],[DateOfRead],[ReadByIdUser],[IsRead]) values (@IdNews,@IdAgent,getdate(),@IdUser,1)

select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ReadNews',Getdate(),@ErrorMessage)
End Catch