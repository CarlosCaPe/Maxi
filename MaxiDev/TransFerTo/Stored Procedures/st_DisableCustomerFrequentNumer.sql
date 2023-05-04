create procedure [TransferTo].st_DisableCustomerFrequentNumer
(
    @IdCustomerFrequentNumber int,
    @EnterByIdUser int,
    @HasError bit output
)
as
Begin Try

update [TransferTo].[CustomerFrequentNumber] set [IdGenericStatus]=2,EnterByIdUser=@EnterByIdUser,[DateOfLastChange]=getdate() where [IdCustomerFrequentNumber]=@IdCustomerFrequentNumber

set @HasError = 0

End Try
Begin Catch
	Set @HasError=1	
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_DisableCustomerFrequentNumer',Getdate(),@ErrorMessage)
End Catch