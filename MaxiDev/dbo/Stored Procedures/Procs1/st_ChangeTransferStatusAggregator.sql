CREATE PROCEDURE [dbo].[st_ChangeTransferStatusAggregator]
(   --11063926737	2022-10-06 13:20:25.873	9	23	15982643 'error' 
    @IdGatewayUser		INT ,--= 12,
	@IdReference		NVARCHAR(50),-- = '11063926737',
	@ActionCode			NVARCHAR(50),--= 'REVERSAL',

	@DateOfPayment		DATETIME,--='2022-10-06 13:20:25.873',
	@BranchCode			NVARCHAR(100),--='9',
	@BeneficiaryId		NVARCHAR(200),--='15982643',
	@BeneficiaryIdType	NVARCHAR(200),--='23',
	@Notes				NVARCHAR(200),--='TECHNICAL_FAILURE'
	@Success			bit out,
	@Message			varchar(500) out
)
AS
BEGIN
	set @Message= NULL
			set @Success		= 1
	
	DECLARE	@IdTransfer			INT,
			@NextIdStatus		INT,
			@CurrentIdStatus	INT,
			@ReturnAllComission	BIT,
			@LogDescription		VARCHAR(MAX),
			@IdPaymentType		INT,
			@IdPayer			INT,
			@IdGateway			INT,
			@PaidStatus			INT = 30,
			@Rejected			INT = 31,
			@IsReverse			BIT = 0,
			@IdStatusFromReverse INT

	SELECT
		@IdGateway = u.IdGateway
	FROM GatewayUser u 
	WHERE u.IdGatewayUser = @IdGatewayUser

	SELECT
		@IdTransfer = t.IdTransfer,
		@CurrentIdStatus = t.IdStatus,
		@ReturnAllComission = ISNULL(rc.ReturnAllComission, 0),
		@IdPaymentType = t.IdPaymentType,
		@IdPayer = t.IdPayer
	FROM Transfer t WITH(NOLOCK)
		LEFT JOIN ReasonForCancel rc WITH(NOLOCK) ON rc.IdReasonForCancel = t.IdReasonForCancel
	WHERE 
		t.ClaimCode = @IdReference
	AND t.IdGateway = @IdGateway

	SELECT
		@NextIdStatus = gac.IdStatus,
		@LogDescription = CONCAT('Code: ', @ActionCode, ', Status: ', gac.Description),
		@IsReverse = gac.IsReverse,
		@IdStatusFromReverse = gac.IdStatusFromReverse
	FROM GatewayActionCodeAggregator gac
	WHERE gac.ActionCode = @ActionCode

	IF ISNULL(@Notes, '') <> ''
		SET @LogDescription = CONCAT(@LogDescription, ', Notes: ', @Notes)

	IF @IdGateway IS NULL
		SET @Message = 'The user in session does not exist or is not active.'
	ELSE IF @IdTransfer IS NULL
		SET @Message = CONCAT('The aggregator in session does not have transfers with moneyTransferCode (', @IdReference,')')
	ELSE IF @NextIdStatus IS NULL
		SET @Message = CONCAT('The code: ', @ActionCode, ' does not exist')
	ELSE IF @CurrentIdStatus IN (30, 31, 22, 27, 28) AND @IsReverse = 0 --EXISTS(SELECT 1 FROM GatewayActionCode g WITH(NOLOCK) WHERE g.IdStatus = @CurrentIdStatus AND g.TransferLock = 1)
		SELECT
			@Message = CONCAT('The transfer with idReference (', @IdReference ,') cannot be updated because it is already in (', st.StatusName,') state')
		FROM Status st WITH(NOLOCK)
		WHERE st.IdStatus = @CurrentIdStatus
	ELSE IF @NextIdStatus = @CurrentIdStatus
		SELECT
			@Message = CONCAT('The transfer with idReference (', @IdReference,') is already in status ', @ActionCode, ' (', st.StatusName,')')
		FROM Status st WITH(NOLOCK)
		WHERE st.IdStatus = @CurrentIdStatus
	ELSE IF @NextIdStatus = @PaidStatus AND @DateOfPayment IS NULL
		SELECT
			@Message = CONCAT('The (DateOfPayment) field is required when the status is (', st.StatusName, ')')
		FROM Status st WITH(NOLOCK)
		WHERE st.IdStatus = @PaidStatus
	ELSE IF @NextIdStatus = @Rejected AND RTRIM(LTRIM(ISNULL(@Notes, ''))) = ''
		SELECT
			@Message = CONCAT('The (Notes) field is required when the status is (', st.StatusName, ')')
		FROM Status st WITH(NOLOCK)
		WHERE st.IdStatus = @Rejected
	ELSE IF @IsReverse = 1 AND @CurrentIdStatus <> @IdStatusFromReverse
		SELECT
			@Message = CONCAT('The transfer with idReference (', @IdReference ,') cannot be updated because it is already in (', st.StatusName,') state')
		FROM Status st WITH(NOLOCK)
		WHERE st.IdStatus = @CurrentIdStatus
	ELSE IF (@NextIdStatus = 40 AND @CurrentIdStatus NOT IN (20, 21))
		OR (@NextIdStatus = 35 AND @CurrentIdStatus NOT IN (25))
		or (@CurrentIdStatus IN (25, 26, 35) AND @NextIdStatus NOT IN (25, 26, 35, 30, 22))
		SET @Message = CONCAT('The transfer with moneyTransferCode (', 
			@IdReference,
			') cannot be updated because not is allowed to change from (', 
			(SELECT TOP 1 s.StatusName FROM Status s WITH(NOLOCK) WHERE s.IdStatus = @CurrentIdStatus),
			') to (', 
			(SELECT TOP 1 s.StatusName FROM Status s WITH(NOLOCK) WHERE s.IdStatus = @NextIdStatus),
			')'
		)

	IF @Message is not null
	BEGIN
		SET @Success = 0
	END
	ELSE
	BEGIN 
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO MAXILOG.dbo.GatewayTransferUpdateLog(IdGateway, IdTransfer, PrevStatus, NewStatus, ChangeDate, IdGatewayUser)
			VALUES
			(@IdGateway, @IdTransfer, @CurrentIdStatus, @NextIdStatus, GETDATE(), @IdGatewayUser)

			UPDATE Transfer SET
				IdStatus = @NextIdStatus,
				DateStatusChange = GETDATE()
			WHERE IdTransfer = @IdTransfer

			EXEC st_SaveChangesToTransferLog @IdTransfer, @NextIdStatus, @LogDescription, 0

			IF @NextIdStatus = 31 --- Rejected balance
				EXEC st_RejectedCreditToAgentBalance @IdTransfer
			ELSE IF @NextIdStatus = 22  -- Cancel Balance
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM TransfersUnclaimed WITH(NOLOCK) WHERE IdTransfer=@IdTransfer AND IdStatus=1)	                                                     
				BEGIN
					IF (@ReturnAllComission=0)--validar si se regresa completa la comision
						EXEC st_CancelCreditToAgentBalance @IdTransfer 
					ELSE
						EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer
				END
				ELSE
				BEGIN
					DECLARE @UnclaimedStatus INT
					SET @UnclaimedStatus = 27

					UPDATE TransfersUnclaimed SET 
						IdStatus=2 
					WHERE IdTransfer=@IdTransfer
			
					UPDATE [Transfer] SET 
						IdStatus = @UnclaimedStatus,
						DateStatusChange = GETDATE() 
					WHERE IdTransfer=@IdTransfer  

					EXEC st_SaveChangesToTransferLog @IdTransfer, @UnclaimedStatus, @LogDescription, 0
				END
			END 
			ELSE IF @NextIdStatus = 30  -- Paid
			BEGIN
				DECLARE @IdBranch INT
				SET @IdBranch = dbo.funGetIdBranch(@BranchCode, @IdGateway, @IdPayer)


				INSERT INTO TransferPayInfo(IdTransfer, ClaimCode, IdGateway, DateOfPayment, BranchCode, BeneficiaryIdNumber, BeneficiaryIdType, IdBranch)
				VALUES(@IdTransfer, @IdReference, @IdGateway, @DateOfPayment, @BranchCode, @BeneficiaryId, @BeneficiaryIdType, @IdBranch )

			END
			ELSE IF @NextIdStatus in (22,30,31)
			BEGIN
				DECLARE	@HasErrorD BIT,	@MessageOutD VARCHAR(max)
				EXEC [dbo].[st_DismissComplianceNotificationByIdTransfer] @IdTransfer, 1, @HasErrorD OUTPUT, @MessageOutD OUTPUT
			END

			IF (@CurrentIdStatus <> @NextIdStatus)
			BEGIN
				IF EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer and IsCancel = 0) AND @NextIdStatus NOT IN (22, 25, 26, 35)
					EXEC st_TransferModifyResponseGateway @IdTransfer, 0
				ELSE IF @NextIdStatus = 22 AND EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer)
					EXEC st_TransferModifyResponseGateway @IdTransfer, 1
			END

			SET @Success = 1
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION

			IF(ISNULL(@Message, '') = '')
				SET @Message = ERROR_MESSAGE();

			INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
			Values('st_ChangeTransferStatusAggregator', GETDATE(), @Message)

			SET @Success = 0
			SET @Message = 'Internal database error'
		END CATCH
	END

	SELECT	@Success		Success,
			@Message	Message
END
