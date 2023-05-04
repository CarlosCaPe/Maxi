/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="13/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_UpdateTransferLookupOwb]
@IdTransfer int,
@Name nvarchar(max),
@FirstLastName nvarchar(max),
@SecondLastName nvarchar(max),
@ExpirationIdentification datetime,
@IdentificationNumber nvarchar(max),
@PhoneNumber nvarchar(max),
@CelullarNumber nvarchar(max),
@Address nvarchar(max),
@BornDate datetime,
@City nvarchar(max),
@Country nvarchar(max),
@MoneySource nvarchar(max),
@Relationship nvarchar(max),
@Purpose nvarchar(max),
@Zipcode nvarchar(max),
@State nvarchar(max),
@SSNumber nvarchar(max),
@Occupation nvarchar(max),
@IdCustomerIdentificationType int,
@HasError bit out,
@Message nvarchar(max) out
AS  
Set nocount on;
Begin try
	if not exists (select 1 from  [Transfer] with (nolock) where IdTransfer = @IdTransfer)
	begin
		SET @HasError = 1;
		if exists (Select 1 from TransferClosed with (nolock) where IdTransferClosed = @IdTransfer)
		Set @Message = 'Transfer is not allowed to edit';
		else 
		Set @Message = 'No Exists Transfer';
		return;
	end
	Declare @IdOnWhoseBehalf int, @IdAgent int, @DateOfLastChange datetime = GETDATE();
	Select @IdOnWhoseBehalf = IdOnWhoseBehalf, @IdAgent = IdAgent from [Transfer] with (nolock) where IdTransfer = @IdTransfer
	BEGIN TRANSACTION;
	if (@IdOnWhoseBehalf = 0 or @IdOnWhoseBehalf is null)
	begin
		insert into OnWhoseBehalf ([Name], FirstLastName, SecondLastName, ExpirationIdentification, IdentificationNumber, PhoneNumber, CelullarNumber,
		[Address], BornDate, City, Country, MoneySource, Relationship, Purpose, Zipcode, [State], SSNumber, Occupation, DateOfLastChange, IdGenericStatus, IdAgentCreatedBy)
		values
		(@Name, @FirstLastName, @SecondLastName, @ExpirationIdentification, @IdentificationNumber, @PhoneNumber, @CelullarNumber,
		@Address, @BornDate, @City, @Country, @MoneySource, @Relationship, @Purpose, @Zipcode, @State, @SSNumber, @Occupation, @DateOfLastChange, 1, @IdAgent);

		Set @IdOnWhoseBehalf = (Select IdOnWhoseBehalf from OnWhoseBehalf with (nolock) where IdOnWhoseBehalf = @@IDENTITY);

		update [Transfer] set IdOnWhoseBehalf = @IdOnWhoseBehalf, DateOfLastChange = @DateOfLastChange where IdTransfer = @IdTransfer;
	end
	else
	begin
		update OnWhoseBehalf set [Name] = @Name, FirstLastName = @FirstLastName, SecondLastName = @SecondLastName, ExpirationIdentification = @ExpirationIdentification,
		IdentificationNumber = @IdentificationNumber, PhoneNumber = @PhoneNumber, CelullarNumber = @CelullarNumber, [Address] = @Address, BornDate = @BornDate,
		City = @City, Country = @Country, MoneySource = @MoneySource, Relationship = @Relationship, Purpose = @Purpose, Zipcode = @Zipcode, [State] = @State, 
		SSNumber = @SSNumber, Occupation = @Occupation, DateOfLastChange = @DateOfLastChange
		where IdOnWhoseBehalf = @IdOnWhoseBehalf

		update [Transfer] set DateOfLastChange = @DateOfLastChange where IdTransfer = @IdTransfer;
	end
	if(@IdCustomerIdentificationType >0)
		update OnWhoseBehalf set IdCustomerIdentificationType = @IdCustomerIdentificationType where IdOnWhoseBehalf = @IdOnWhoseBehalf
	SET @HasError = 0;
	Set @Message = 'Transfer information has been successfully saved';
	COMMIT TRANSACTION;
End try
Begin Catch
	if (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;
	SET @HasError = 1;
	Set @Message = 'Error trying update transfer information sp';
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateTransferLookupOwb',Getdate(),@ErrorMessage);
End catch
