CREATE procedure [dbo].[st_BGuayaquilChangeTransferStatus]-- 12,'11063926737','Falla','REVERSAL'
-- exec  [dbo].[st_BGuayaquilChangeTransferStatus]  12,'11063926700','Falla','REVERSAL'
(
	@IdGatewayUser	INT,
	@MoneyTransferCode	varchar(50) ,
	--@IdTransfer int ,
	@Notes varchar(300),
	@ActionCode varchar(50)
)
AS
/********************************************************************
<Author></Author>
<app>Aggregators :BGuayaquil</app>
<Description>Get BGuayaquil operations</Description>
<ChangeLog>
</ChangeLog>
*********************************************************************/
--Set nocount on

Begin try
DECLARE @ErrorMessage	NVARCHAR(500),
		@Success		BIT = 1

DECLARE @IdGateway			INT

	SELECT
		@IdGateway = u.IdGateway --54
	FROM GatewayUser u 
	WHERE u.IdGatewayUser = @IdGatewayUser

	if not exists(SELECT t.ClaimCode FROM Transfer t WITH (NOLOCK)	WHERE t.ClaimCode= @MoneyTransferCode /*and t.IdTransfer = @IdTransfer*/ AND t.IdGateway = @IdGateway)
	BEGIN
		SET @Success = 0
		SET @ErrorMessage = 'BGuayaquil user in session does not have transfers with MoneyTransferCode ('+ @MoneyTransferCode +')'

		Select  @Success Success, @ErrorMessage  [Message]
	END
	ELSE
	BEGIN
		declare @IdReference varchar(50), 
					@DateOfPayment datetime, 
					@BranchCode NVARCHAR(100), 
					@BeneficiaryId NVARCHAR(200), 
					@BeneficiaryIdType NVARCHAR(200)
		Select 
		 @IdReference = t.ClaimCode,
		 @DateOfPayment =t.DateOfTransfer,
		 @BranchCode =t.GatewayBranchCode,
		@BeneficiaryId =t.IdBeneficiary,
		@BeneficiaryIdType = isnull(CONVERT(varchar(20),IdBeneficiaryIdentificationType), '')
		from Transfer t with(nolock)
		WHERE t.ClaimCode= @MoneyTransferCode /*and t.IdTransfer = @IdTransfer*/ AND t.IdGateway = @IdGateway

		Declare @Response Table (Success bit, Message varchar(500))

		insert into @Response Exec st_ChangeTransferStatusAggregator 
					@IdGatewayUser, 
					@IdReference, 
					@ActionCode, 
					@DateOfPayment, 
					@BranchCode, 
					@BeneficiaryId, 
					@BeneficiaryIdType, 
					@Notes,
					0,
					''


				

		SELECT	@Success = R.Success, @ErrorMessage = R.Message --,
			--getdate()		processDateTime,
			--	@IdReference	moneyTransferCode,
			--	'READY_TO_PAY'	orderStatus,
			--	NULL			saleMovementID
				from @Response R

		Select  @Success Success, @ErrorMessage  [Message]

	End
End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessages nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(20), ERROR_LINE()), 
	   @ErrorMessages = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_BGuayaquilChangeTransferStatus',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessages);

End Catch