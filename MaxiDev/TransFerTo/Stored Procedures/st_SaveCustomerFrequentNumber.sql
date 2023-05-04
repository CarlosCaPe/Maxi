create procedure [TransferTo].st_SaveCustomerFrequentNumber
(
    @IdCustomerFrequentNumber int,
    @IdCustomer int,
    @NickName nvarchar(max),    
    @BeneficiaryCelullar nvarchar(max),
    @EnterByIdUser int,
    @IdCustomerFrequentNumberOut int out,
    @HasError bit out
)
as
Begin Try

if (isnull(@IdCustomerFrequentNumber,0)=0)
begin
    INSERT INTO [TransFerTo].[CustomerFrequentNumber]
           ([IdCustomer]
           ,[NickName]           
           ,[BeneficiaryCelullar]
           ,EnterByIdUser
           ,CreationDate
           ,DateOfLastChange
           ,IdGenericStatus
           )
     VALUES
           (@IdCustomer
           ,@NickName           
           ,@BeneficiaryCelullar
           ,@EnterByIdUser
           ,getdate()
           ,getdate()
           ,1
           )
    set @IdCustomerFrequentNumberOut = SCOPE_IDENTITY()
end
else
begin
    UPDATE [TransFerTo].[CustomerFrequentNumber]
   SET [IdCustomer] = @IdCustomer
      ,[NickName] = @NickName      
      ,[BeneficiaryCelullar] = @BeneficiaryCelullar
      ,EnterByIdUser = @EnterByIdUser
      ,DateOfLastChange = getdate()
    WHERE IdCustomerFrequentNumber=@IdCustomerFrequentNumber
    set @IdCustomerFrequentNumberOut = @IdCustomerFrequentNumber
end

set @HasError = 0

End Try
Begin Catch
	Set @HasError=1	
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_SaveCustomerFrequentNumber',Getdate(),@ErrorMessage)
End Catch