/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="2022/02/10" Author="jcsierra"> Se omite el movimiento DCP en balance cuando es una transacción derivada de una modificación </log>
	<log Date="2022/08/11" Author="jcsierra"> Se agrega AgentCommision cuando la transaccion se creo como Retain</log>
	<log Date="2022/08/29" Author="jcsierra"> Se cambia el BankName para los depositos de TDD </log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_InitTransaction]
(
    @IdTransfer     BIGINT
)
AS
BEGIN
    DECLARE @IdStatus                       INT,
            @EnterByIdUser                  INT,
            @IdAgent                        INT,
            @IdPayer                        INT,
            @IdPaymentType                  INT,
            @CustomerName                   NVARCHAR(MAX),
            @CustomerFirstLastName          NVARCHAR(MAX),
            @CustomerSecondLastName         NVARCHAR(MAX),
            @BeneficiaryName                NVARCHAR(MAX),
            @BeneficiaryFirstLastName       NVARCHAR(MAX),
            @BeneficiarySecondLastName      NVARCHAR(MAX),
            @Amount                         MONEY,
            @Reference                      INT,
            @Country                        NVARCHAR(MAX),
			@AgentCommission				MONEY,
            @AgentCommissionExtra           MONEY,
            @AgentCommissionOriginal        MONEY,
            @ModifierCommissionSlider       MONEY,
            @ModifierExchangeRateSlider     MONEY,
            @DateOfTransfer                 DATETIME,
            @IdTransferResend               INT,
            @StateTax                       MONEY,
			@IdPaymentMethod				INT,
			@IdAgentPaymentSchema			INT

    SELECT
        @IdStatus = t.IdStatus,
        @EnterByIdUser = t.EnterByIdUser,
        @IdAgent = t.IdAgent,
        @IdPayer = t.IdPayer,
        @IdPaymentType = t.IdPaymentType,
        @CustomerName = t.CustomerName,
        @CustomerFirstLastName = t.CustomerFirstLastName,
        @CustomerSecondLastName = t.CustomerSecondLastName,
        @BeneficiaryName = t.BeneficiaryName,
        @BeneficiaryFirstLastName = t.BeneficiaryFirstLastName,
        @BeneficiarySecondLastName = t.BeneficiarySecondLastName,
        @Amount = t.TotalAmountToCorporate,
        @Reference = t.Folio,
        @Country = c.CountryCode,
		@AgentCommission = t.AgentCommission,
        @AgentCommissionExtra = t.AgentCommissionExtra,
        @AgentCommissionOriginal = t.AgentCommissionOriginal,
        @ModifierCommissionSlider = t.ModifierCommissionSlider,
        @ModifierExchangeRateSlider = t.ModifierExchangeRateSlider,
        @DateOfTransfer = t.DateOfTransfer,
        @IdTransferResend = t.IdTransferResend,
        @StateTax = t.StateTax,
		@IdPaymentMethod = t.IdPaymentMethod,
		@IdAgentPaymentSchema = t.IdAgentPaymentSchema
    FROM Transfer t WITH(NOLOCK)
        JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = t.IdCountryCurrency
        JOIN Country c WITH(NOLOCK) ON c.IdCountry = cc.IdCountry
    WHERE t.IdTransfer = @IdTransfer

    --- Pending by change request by modify Verification
    IF EXISTS(SELECT 1 FROM TransferModify WITH(NOLOCK) WHERE NewIdTransfer = @IdTransfer AND IsCancel = 0 AND OldIdStatus <> 22)
    BEGIN
        DECLARE @PendigByChangeRequetsStatus INT = 72

		EXEC st_SaveChangesToTransferLog @IdTransfer, @PendigByChangeRequetsStatus, 'Pending by change request', 0
        UPDATE Transfer SET
            IdStatus = @PendigByChangeRequetsStatus,
            DateStatusChange = GETDATE()
        WHERE IdTransfer = @IdTransfer

        RETURN
	END

    -- # Insert in case Resend Transfer
    IF ISNULL(@IdTransferResend, 0) <> 0
    BEGIN
        INSERT INTO TransferResend (IdTransfer, Note, DateOfLastChange, EnterByIdUser, NewIdTransfer)
        VALUES (@IdTransferResend, 'Resend by st_CreateTransfer', @DateOfTransfer, @EnterByIdUser, @IdTransfer)

        -- Afectar el saldo del agente con un cargo negativo -----------
        DECLARE @ReturnCommission    MONEY,
                @ResendHasError      BIT,
                @ResendMessage       NVARCHAR(MAX),
                @ReferenceResend     NVARCHAR(MAX),
                @ResendNote          NVARCHAR(MAX)

        IF EXISTS(SELECT 1 FROM Transfer WITH(NOLOCK) WHERE IdTransfer = @IdTransferResend)
        BEGIN
            SELECT
                @ReturnCommission = CASE WHEN TotalAmountToCorporate= AmountInDollars + Fee THEN (TotalAmountToCorporate-AmountInDollars) ELSE (CorporateCommission) END,
                @ResendNote = 'Folio:' + CONVERT(varchar(max), Folio),
                @ReferenceResend = CONVERT(varchar(max), Folio)
            FROM Transfer WITH(NOLOCK)
            WHERE IdTransfer=@IdTransferResend
        END
        Else
        Begin
            SELECT
                @ReturnCommission= CASE WHEN TotalAmountToCorporate=AmountInDollars+Fee THEN (TotalAmountToCorporate-AmountInDollars) ELSE (CorporateCommission) END,
                @ResendNote = 'Folio:' + CONVERT(varchar(max), Folio),
                @ReferenceResend = CONVERT(varchar(max), Folio)
            FROM TransferClosed WITH(NOLOCK)
            WHERE IdTransferClosed = @IdTransferResend
        End

        EXEC st_SaveOtherCharge 1,
            @IdAgent,
            @ReturnCommission,
            0,
            @DateOfTransfer,
            @ResendNote,
            @ReferenceResend,
            @EnterByIdUser,
            @HasError = @ResendHasError OUT,
            @Message = @ResendMessage  OUT,
            @IdOtherChargesMemo = 6,
            @OtherChargesMemoNote = NULL   --6	Retransfer Credit
    END

    -- # State Tax
    IF @StateTax > 0
    BEGIN
        INSERT INTO StateFee (State, Tax, IdTransfer)
        SELECT AgentState, @StateTax, @IdTransfer
        FROM Agent WITH(NOLOCK)
        WHERE IdAgent = @IdAgent

        DECLARE @FeeNote               NVARCHAR(MAX),
                @FeeReference          NVARCHAR(MAX),
                @SateName              NVARCHAR(MAX),
                @StateFeeHasError      BIT,
                @StateFeeMessage       NVARCHAR(MAX)

        SELECT TOP 1
            @SateName = StateName
        FROM ZipCode WITH(NOLOCK)
        WHERE StateCode = (SELECT AgentState FROM Agent WITH(NOLOCK) WHERE IdAgent = @IdAgent)

        Select
            @FeeNote = 'Folio:' + CONVERT(VARCHAR(MAX), Folio),
            @FeeReference = CONVERT(VARCHAR(MAX), Folio)
        FROM Transfer WITH(NOLOCK)
        WHERE IdTransfer = @IdTransfer

        EXEC st_SaveOtherCharge 1,
            @IdAgent,
            @StateTax,
            1,
            @DateOfTransfer,
            @FeeNote,
            @FeeReference,
            @EnterByIdUser,
            @HasError = @StateFeeHasError OUT,
            @Message = @StateFeeMessage   OUT,
            @IdOtherChargesMemo = 1,
            @OtherChargesMemoNote = NULL
    END

	DECLARE @IsModify BIT
	SET @IsModify = IIF((EXISTS(SELECT 1 FROM TransferModify WHERE NewIdTransfer = @IdTransfer AND IsCancel = 1)), 1, 0)


    -- # Balance
    If @IdStatus = 1 OR @IsModify = 1
    BEGIN
        EXEC st_DebitToAgentBalanceForSB @IdTransfer,
            @IdAgent,
            @Amount,
            @Reference,
            @CustomerName,
            @CustomerFirstLastName,
            @Country,
            @AgentCommissionExtra,
            @AgentCommissionOriginal,
            @ModifierCommissionSlider,
            @ModifierExchangeRateSlider

        EXEC st_SaveChangesToTransferLog @IdTransfer, 1, 'Transfer Charge Added to Agent Balance', 0, 1

        DECLARE @IdUserSystem               INT = CAST(dbo.GetGlobalAttributeByName('SystemUserID') AS INT),
                @AmountOfacValidation       MONEY = CAST(dbo.GetGlobalAttributeByName('AmountOfacHoldValidation') AS MONEY),
                @SmallAmountOFACPercentage  INT = CAST(dbo.GetGlobalAttributeByName('PercentageOfacMatchHoldValidation') AS INT),
                @OFACMinPercentage          INT = CAST(dbo.GetGlobalAttributeByName('MinOfacMatch') AS INT),
                @IdUserType                 INT

        SELECT @IdUserType = IdUserType
        FROM Users
        WHERE IdUser = @EnterByIdUser

        -- ## Signature Validation
        EXEC st_SaveChangesToTransferLog @IdTransfer, 2, 'Signature Validation', 0
        IF @IdUserType=2 AND NOT EXISTS(SELECT 1 FROM AgentUser WHERE IdUser = @EnterByIdUser)
        BEGIN
           INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
           VALUES(@IdTransfer, 3, GETDATE(), GETDATE(), @IdUserSystem)

           EXEC st_SaveChangesToTransferLog @IdTransfer, 3, 'Signature Hold', 0
        END

        -- ## Agent Verification
        EXEC st_SaveChangesToTransferLog @IdTransfer, 5, 'AR Validation', 0
        IF EXISTS(SELECT 1 FROM Agent a WITH(NOLOCK) WHERE a.IdAgent = @IdAgent AND a.IdAgentStatus IN (3, 4, 5, 7))
        BEGIN
           INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
           VALUES(@IdTransfer, 6, GETDATE(), GETDATE(), @IdUserSystem)

           EXEC st_SaveChangesToTransferLog @IdTransfer, 6, 'AR Hold', 0
        END

        -- ## KYC Verification
        EXEC st_SaveChangesToTransferLog @IdTransfer, 8, 'KYC Validation', 0
        IF EXISTS (SELECT 1 FROM BrokenRulesByTransfer WHERE IdTransfer = @IdTransfer AND IsDenyList = 0)
        BEGIN
            DECLARE @IsHolded           BIT,
                    @InfoMessage    NVARCHAR(255)

            SELECT
                @IsHolded = isHolded,
                @InfoMessage = infoMeesage
            FROM dbo.fun_GetIfInsertKycBasedOnRequestId(@IdTransfer)

            EXEC st_SaveChangesToTransferLog @IdTransfer, 8, @infoMessage, 0

            IF (@isHolded = 1)
            BEGIN
                INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
                VALUES (@IdTransfer, 9, GETDATE(), GETDATE(), @IdUserSystem)

                EXEC st_SaveChangesToTransferLog @IdTransfer, 9, 'KYC Hold', 0
            END
        END

        -- ## DenyList Verification
        EXEC st_SaveChangesToTransferLog @IdTransfer, 11, 'Deny List Verification', 0
        IF EXISTS (SELECT 1 FROM BrokenRulesByTransfer WHERE IdTransfer = @IdTransfer AND IsDenyList=1)
        BEGIN
           INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
           VALUES ( @IdTransfer, 12, GETDATE(), GETDATE(), @IdUserSystem)

           EXEC st_SaveChangesToTransferLog @IdTransfer, 12, 'Deny List Hold', 0
        END

        -- ## OFAC validation
        EXEC st_SaveChangesToTransferLog @IdTransfer, 14, 'OFAC Verification', 0
        DECLARE @TransferMaxMatch           INT,
                @IsOFACDoubleVerification   BIT,
                @IsAutoRelease              BIT

        SELECT
            @TransferMaxMatch = CASE
                WHEN t.CustomerOfacPercent > t.BeneficiaryOfacPercent THEN ISNULL(t.CustomerOfacPercent, 0)
                ELSE ISNULL(t.BeneficiaryOfacPercent, 0)
            END,
            @IsOFACDoubleVerification = t.IsOFACDoubleVerification,
            @IsAutoRelease = CASE
                WHEN t.IsOFACDoubleVerification = 1 THEN CASE WHEN (t.IdUserRelease1 IS NOT NULL AND t.IdUserRelease2 IS NOT NULL) THEN 1 ELSE 0 END
                ELSE CASE WHEN t.IdUserRelease1 IS NOT NULL THEN 1 ELSE 0 END
            END
        FROM TransferOFACInfo t WITH(NOLOCK)
        WHERE t.IdTransfer = @IdTransfer

		DECLARE @AmountDlls MONEY
		SELECT
			@AmountDlls = t.TotalAmountToCorporate
		FROM Transfer t WITH(NOLOCK) 
		WHERE t.IdTransfer = @IdTransfer

        IF ((@AmountDlls > @AmountOfacValidation OR @TransferMaxMatch > @SmallAmountOFACPercentage) AND (@TransferMaxMatch >= @OFACMinPercentage))
        BEGIN
            INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
            VALUES(@IdTransfer, 15, GETDATE(), GETDATE(), @IdUserSystem)

			EXEC st_SaveChangesToTransferLog @IdTransfer, 15, 'OFAC Hold', 0

            IF (@IsOFACDoubleVerification = 1)
            BEGIN
                INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
                VALUES(@IdTransfer, 15, GETDATE(), GETDATE(), @IdUserSystem)

                EXEC st_SaveChangesToTransferLog @IdTransfer, 15, 'OFAC Hold', 0
            END

            IF @IsAutoRelease = 1
            BEGIN
                DECLARE @AutoRelesaseMessage VARCHAR(500)

                SELECT
                    @AutoRelesaseMessage = CONCAT('OFAC AutoRelease, ',
                        CASE WHEN t.IsOFACDoubleVerification = 1 THEN 'Double Verification' ELSE 'Single Verification' END,
                        ' Note1: ',
                        t.UserNoteRelease1, 
                        CASE WHEN t.IsOFACDoubleVerification = 1 THEN CONCAT(' Note2: ', t.IdUserRelease2)
                        ELSE '' END    
                    )
                FROM TransferOFACInfo t WITH(NOLOCK)
                WHERE t.IdTransfer = @IdTransfer

                EXEC st_SaveChangesToTransferLog @IdTransfer, 16, @AutoRelesaseMessage, 0

                UPDATE TransferHolds SET
                    IsReleased = 1
                WHERE IdTransfer = @IdTransfer
                AND IdStatus = 15
            END
        END

        -- ## Deposit Verification
        EXEC st_SaveChangesToTransferLog @IdTransfer, 17, 'Deposit Verification', 0
        IF EXISTS (SELECT 1 FROM PayerConfig WHERE IdPayer = @IdPayer AND DepositHold = 1 AND IdPaymentType = @IdPaymentType)
        BEGIN
           INSERT INTO TransferHolds(IdTransfer, IdStatus, DateOfValidation, DateOfLastChange, EnterByIdUser)
           VALUES(@IdTransfer, 18, GETDATE(), GETDATE(), @IdUserSystem)

           EXEC st_SaveChangesToTransferLog @IdTransfer, 18, 'Deposit Hold', 0
        END

		DECLARE @VerifyHoldIdStatus INT = 41
        EXEC st_SaveChangesToTransferLog @IdTransfer, @VerifyHoldIdStatus, 'Verify Hold', 0
        UPDATE Transfer SET
            IdStatus = 41,
            DateStatusChange = GETDATE()
        WHERE IdTransfer = @IdTransfer

		EXEC st_CreateComplianceNotificationCustomerRequestId @IdTransfer;
        INSERT INTO SBReceiveOriginMessageLog (ConversationID, MessageXML, IdTransfer)
        VALUES (NULL, NULL, @IdTransfer)

		-- ## Create TDD Credit
		IF @IdPaymentMethod = 2 AND @IsModify = 0
		BEGIN
			DECLARE @Balance			MONEY = 0,
					@IdAgentBalance		INT,
					@CreditAmount		MONEY,
					@DateOfMovement		DATETIME

			SET @DateOfMovement = DATEADD (SECOND, 1, GETDATE())  
			SET @CreditAmount = @Amount

			IF @IdAgentPaymentSchema = 2
				SET @CreditAmount = @CreditAmount + @AgentCommission
					
			UPDATE AgentCurrentBalance SET
				Balance = Balance - @CreditAmount, 
				@Balance = Balance - @CreditAmount 
			WHERE IdAgent = @IdAgent

			INSERT INTO AgentBalance
			(
				IdAgent, 
				TypeOfMovement, 
				DateOfMovement, 
				Amount, 
				Reference, 
				Description,
				Country,
				Commission,
				FxFee,
				DebitOrCredit,
				Balance,
				IdTransfer,
				IsMonthly
			)
			VALUES
			(
				@IdAgent,
				'DCP',
				@DateOfMovement,
				@CreditAmount,
				@Reference,
				CONCAT(@CustomerName, ' ', @CustomerFirstLastName),
				@Country,
				0,
				0,
				'Credit',
				@Balance,
				@IdTransfer,
				0
			);

			SET @IdAgentBalance = SCOPE_IDENTITY()

			INSERT INTO AgentBalanceDetail (IdAgentBalance, TotalAmount, CGS, Fee, ProviderFee, CorpCommission)
			VALUES (@IdAgentBalance, @CreditAmount, @CreditAmount, 0, 0, 0);

			DECLARE @IdAgentBankDepositForDCP	INT,
					@DCPBankName				VARCHAR(200)

			SET @IdAgentBankDepositForDCP = TRY_CAST(dbo.GetGlobalAttributeByName('IdAgentBankDepositForDCP') AS INT)
			SELECT 
				@DCPBankName = ad.BankName
			FROM AgentBankDeposit ad WITH(NOLOCK)
			WHERE ad.IdAgentBankDeposit = @IdAgentBankDepositForDCP

			IF ISNULL(@DCPBankName, '') = ''
				SET @DCPBankName = CONCAT('Debit Card Payment ', @IdTransfer)
			
			INSERT INTO AgentDeposit
			(
				IdAgent,
				IdAgentBalance,
				BankName,
				Amount,
				DepositDate,
				Notes,
				DateOfLastChange,
				EnterByIdUser,
				IdAgentCollectType,
				ReferenceNumber
			)
			VALUES
			(        
				@IdAgent,
				@IdAgentBalance,
				@DCPBankName,
				@CreditAmount,
				@DateOfTransfer,
				CONCAT(@CustomerName, ' ', @CustomerFirstLastName, ' ', @CustomerSecondLastName),
				@DateOfMovement,
				@EnterByIdUser,
				10, 
				NULL
			);

			EXEC st_AgentVerifyCreditLimit @IdAgent;
		END

		--EXEC st_TransferProcessorDetail @IdTransfer, @VerifyHoldIdStatus
    END
END