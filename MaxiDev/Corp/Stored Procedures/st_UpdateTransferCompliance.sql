CREATE PROCEDURE [Corp].[st_UpdateTransferCompliance]
	@IdTransfer int,
	@idCustomer int,
	@updateCustomer bit,
	@IdUser int,
	@physicalIdCopy int,
	@ReviewDenyList bit,
    @ReviewOfac bit,
    @ReviewKyc bit,
    @ReviewGateaway bit,
    @ReviewReturned bit,
    @ReviewId bit = null,
	@HasError bit out,
	@Message nvarchar(max) out
AS  



Set nocount on;
Begin TRY
	/********************************************************************
	<Author> Unknown </Author>
	<app> Corporative </app>
	<Description> Update transfer compliance</Description>
	
	<ChangeLog>
	<log Date="11/10/2022" Author="cagarcia">MP-684 Fix No marcaba la opcion Review OFAC o Review KYC</log>
	</ChangeLog>
	*********************************************************************/

	if not exists(Select 1 from [Transfer] (NOLOCK) where IdTransfer = @IdTransfer)
	begin 
		Set @HasError = 1
		set @Message = 'Transfer is not allowed to edit'
		return;
	end

	if (@updateCustomer = 1)
	begin
		EXECUTE [Corp].[st_UpdateCustomerPhysicalIdCopy] @idCustomer, @IdUser, @physicalIdCopy, @HasError OUTPUT
		if(@HasError = 1)
		begin 
			set @Message = 'Error trying update transfer for compliance.'
			return;
		end
	end
	Declare @Customer int, @IdCustomerIdentificationType int
	Select @Customer = idCustomer, @IdCustomerIdentificationType = CustomerIdCustomerIdentificationType from [Transfer] (NOLOCK) where IdTransfer = @IdTransfer

	if(@ReviewKyc = 1 and @IdCustomerIdentificationType is not null)
	begin 
		if not exists 
		(Select 1 from uploadfiles u (NOLOCK) join documenttypes dt (NOLOCK) on u.IdDocumentType = dt.IdDocumentType
		where dt.IdType = 1 and u.idstatus=1 and u.IdReference =  @Customer and dt.IdDocumentType = @IdCustomerIdentificationType)
		begin
			Set @HasError = 1
			set @Message = 'Please attach an Up-to-date ID document.'
			return;
		end
	end
	else if (@ReviewKyc = 1 and @IdCustomerIdentificationType is null)
	begin
		Set @HasError = 1
		set @Message = 'Please attach an Up-to-date ID document.'
		return;
	end
	--else
	--begin
		update [Transfer] set ReviewDenyList=@ReviewDenyList, ReviewOfac = @ReviewOfac, ReviewKYC = @ReviewKYC, ReviewGateway = @ReviewGateaway, 
		ReviewReturned = @ReviewReturned, ReviewId = @ReviewId, DateOfLastChange = GETDATE()
		where IdTransfer = @IdTransfer

		Set @HasError = 0
		set @Message = 'Transfer has been successfully saved'
	--end
End try
Begin Catch
	set @HasError = 1
	set @Message = 'Transfer can not be save'
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_UpdateTransferCompliance',Getdate(),@ErrorMessage);
End catch

