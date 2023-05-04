CREATE procedure [MaxiMobile].[st_saveTransferAdditionalInfo]
@IdTransfer int,
@Note nvarchar(max),
@RequiereID bit = 0,
@RequiereProof bit = 0,
@CustomerOccupation bit = 0,
@CustomerAddress bit = 0,
@CustomerSSN bit = 0,
@IDNotLegible bit = 0,
@CustomerIDNumber bit = 0,
@CustomerDateOfBirth bit = 0,
@CustomerPlaceOfBirth bit = 0,
@CustomerIDExpiration bit = 0,
@CustomerFullName bit = 0,
@CustomerFullAddress bit = 0,
@BeneficiaryFullName bit = 0,
@BeneficiaryDateOfBirth bit = 0,
@BeneficiaryPlaceOfBirth bit = 0,
@BeneficiaryRequiereID bit = 0,
@SignReceipt bit = 0
as

begin try

set @RequiereID = isnull(@RequiereID,0)
set @RequiereProof = isnull(@RequiereProof,0)
set @CustomerOccupation = isnull(@CustomerOccupation,0)
set @CustomerAddress = isnull(@CustomerAddress,0)
set @CustomerSSN = isnull(@CustomerSSN,0)
set @IDNotLegible = isnull(@IDNotLegible,0)
set @CustomerIDNumber = isnull(@CustomerIDNumber,0)
set @CustomerDateOfBirth = isnull(@CustomerDateOfBirth,0)
set @CustomerPlaceOfBirth = isnull(@CustomerPlaceOfBirth,0)
set @CustomerIDExpiration = isnull(@CustomerIDExpiration,0)
set @CustomerFullName = isnull(@CustomerFullName,0)
set @CustomerFullAddress = isnull(@CustomerFullAddress,0)
set @BeneficiaryFullName = isnull(@BeneficiaryFullName,0)
set @BeneficiaryDateOfBirth = isnull(@BeneficiaryDateOfBirth,0)
set @BeneficiaryPlaceOfBirth = isnull(@BeneficiaryPlaceOfBirth,0)
set @BeneficiaryRequiereID = isnull(@BeneficiaryRequiereID,0)
set @SignReceipt = isnull(@SignReceipt,0)

declare @tot int = 0

if @RequiereID =1 set @tot=@tot+1
if @RequiereProof =1 set @tot=@tot+1
if @CustomerOccupation =1 set @tot=@tot+1
if @CustomerAddress =1 set @tot=@tot+1
if @CustomerSSN =1 set @tot=@tot+1
if @IDNotLegible =1 set @tot=@tot+1
if @CustomerIDNumber =1 set @tot=@tot+1
if @CustomerDateOfBirth =1 set @tot=@tot+1
if @CustomerPlaceOfBirth =1 set @tot=@tot+1
if @CustomerIDExpiration =1 set @tot=@tot+1
if @CustomerFullName =1 set @tot=@tot+1
if @CustomerFullAddress =1 set @tot=@tot+1
if @BeneficiaryFullName =1 set @tot=@tot+1
if @BeneficiaryDateOfBirth =1 set @tot=@tot+1
if @BeneficiaryPlaceOfBirth =1 set @tot=@tot+1
if @BeneficiaryRequiereID =1 set @tot=@tot+1
if @SignReceipt = 1 set @tot=@tot+1


print @IdTransfer

if not exists (select top 1 1 from [MaxiMobile].[TransferAdditionalInfo] where IdTransfer=@IdTransfer)
begin
print 'insert'
INSERT INTO [MaxiMobile].[TransferAdditionalInfo]
           ([IdTransfer]
           ,[Note]
           ,[RequiereID]
           ,[RequiereProof]
           ,[CustomerOccupation]
           ,[CustomerAddress]
           ,[CustomerSSN]
           ,[IDNotLegible]
           ,[CustomerIDNumber]
           ,[CustomerDateOfBirth]
           ,[CustomerPlaceOfBirth]
           ,[CustomerIDExpiration]
           ,[CustomerFullName]
           ,[CustomerFullAddress]
           ,[BeneficiaryFullName]
           ,[BeneficiaryDateOfBirth]
           ,[BeneficiaryPlaceOfBirth]
           ,[BeneficiaryRequiereID]
           ,[SignReceipt]
		   ,NumDocs
		   )
     VALUES
           (@IdTransfer ,
			@Note ,
			@RequiereID ,
			@RequiereProof ,
			@CustomerOccupation ,
			@CustomerAddress ,
			@CustomerSSN ,
			@IDNotLegible ,
			@CustomerIDNumber ,
			@CustomerDateOfBirth ,
			@CustomerPlaceOfBirth ,
			@CustomerIDExpiration ,
			@CustomerFullName ,
			@CustomerFullAddress ,
			@BeneficiaryFullName ,
			@BeneficiaryDateOfBirth ,
			@BeneficiaryPlaceOfBirth ,
			@BeneficiaryRequiereID ,
			@SignReceipt,
			@tot
			 )
end
else
begin
print 'update'
	UPDATE [MaxiMobile].[TransferAdditionalInfo]
   SET  
       [Note] = @Note 
      ,[RequiereID] = @RequiereID 
      ,[RequiereProof] = @RequiereProof 
      ,[CustomerOccupation] = @CustomerOccupation 
      ,[CustomerAddress] = @CustomerAddress 
      ,[CustomerSSN] = @CustomerSSN 
      ,[IDNotLegible] = @IDNotLegible 
      ,[CustomerIDNumber] = @CustomerIDNumber 
      ,[CustomerDateOfBirth] = @CustomerDateOfBirth 
      ,[CustomerPlaceOfBirth] = @CustomerPlaceOfBirth 
      ,[CustomerIDExpiration] = @CustomerIDExpiration 
      ,[CustomerFullName] = @CustomerFullName 
      ,[CustomerFullAddress] = @CustomerFullAddress 
      ,[BeneficiaryFullName] = @BeneficiaryFullName 
      ,[BeneficiaryDateOfBirth] = @BeneficiaryDateOfBirth 
      ,[BeneficiaryPlaceOfBirth] = @BeneficiaryPlaceOfBirth 
      ,[BeneficiaryRequiereID] = @BeneficiaryRequiereID 
      ,[SignReceipt] = @SignReceipt 
      ,[NumDocs] = @tot
 WHERE [IdTransfer] = @IdTransfer
end



END TRY

BEGIN CATCH

    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('maximobile.st_saveTransferAdditionalInfo',Getdate(),@ErrorMessage);
END CATCH
