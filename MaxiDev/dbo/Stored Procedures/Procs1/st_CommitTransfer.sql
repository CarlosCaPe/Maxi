/********************************************************************
<app>Hermes/app>
<Description></Description>
<ChangeLog>
	<log Date="2022/03/14" Author="jcsierra" Name="OfacAutoRelease">Se aplica la logica de liberacion automatica de OFAC cuando se cuenta con una liberacion previa</log>
	<log Date="2022/04/11" Author="jcsierra" Name="DomesticTransfers">Se agrega el parametro @IdDialingCodeBeneficiaryPhoneNumber </log>
	<log Date="2022/12/06" Author="jcsierra" Name="Optimizacion-ClaimsCodes-V2">M1-530: Se implementa el metodo st_BuildClaimCodeForTransfer</log>
	<log Date="2023/01/21" Author="jacardenas" Name="Optimizacion-ClaimsCodes-V2">BM-448: Se agrega el parameto @ClaimCodeWs</log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_CommitTransfer]
(
	@IdPretransfer		BIGINT,
	@ClaimCodeApi		VARCHAR(50) = NULL,
	@IdUser				INT,
	@IdLenguage			INT,
	@IdTransfer			BIGINT OUT,
	@HasError			BIT OUT,
    @Message			VARCHAR(MAX) OUT
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM PreTransfer p WITH(NOLOCK) WHERE p.IdPretransfer = @IdPretransfer)
		SET @Message = 'Pretransfer not exists'	
	ELSE IF NOT EXISTS(SELECT 1 FROM PreTransfer p WITH(NOLOCK) WHERE p.IdPreTransfer = @IdPretransfer AND p.OnlineTransfer = 1)
		SET @Message = 'Pretransfer not is online'
	ELSE IF NOT EXISTS(SELECT 1 FROM PreTransfer p WITH(NOLOCK) WHERE p.IdPreTransfer = @IdPretransfer AND ISNULL(p.IdTransfer, 0) = 0)
		SET @Message = 'Pretransfer has ready commit'

	IF ISNULL(@Message, '') <> ''
	BEGIN
		SET @HasError = 1
		RETURN
	END

	DECLARE @IdCustomer										INT,
			@IdBeneficiary									INT,
			@IdPaymentType									INT,
			@IdCity											INT,
			@IdBranch										INT,
			@IdPayer										INT,
			@IdGateway										INT,
			@GatewayBranchCode								NVARCHAR(MAX),
			@IdAgentPaymentSchema							INT,
			@IdAgent										INT,
			@IdAgentSchema									INT,
			@IdCountryCurrency								INT,
			@AmountInDollars								MONEY,
			@Fee											MONEY,
			@AgentCommission								MONEY,
			@CorporateCommission							MONEY,
			@ExRate											MONEY,
			@ReferenceExRate								MONEY,
			@AmountInMN										MONEY,
			@DepositAccountNumber							NVARCHAR(MAX),
			@EnterByIdUser									INT,
			@TotalAmountToCorporate							MONEY,
			@BeneficiaryName								NVARCHAR(MAX),
			@BeneficiaryFirstLastName						NVARCHAR(MAX),
			@BeneficiarySecondLastName						NVARCHAR(MAX),
			@BeneficiaryAddress								NVARCHAR(MAX),
			@BeneficiaryCity								NVARCHAR(MAX),
			@BeneficiaryState								NVARCHAR(MAX),
			@BeneficiaryCountry								NVARCHAR(MAX),
			@BeneficiaryZipcode								NVARCHAR(MAX),
			@BeneficiaryPhoneNumber							NVARCHAR(MAX),
			@BeneficiaryCelularNumber						NVARCHAR(MAX),
			@CustomerName									NVARCHAR(MAX),
			@CustomerIdCustomerIdentificationType			INT,
			@CustomerFirstLastName							NVARCHAR(MAX),
			@CustomerSecondLastName							NVARCHAR(MAX),
			@CustomerAddress								NVARCHAR(MAX),
			@CustomerCity									NVARCHAR(MAX),
			@CustomerState									NVARCHAR(MAX),
			@CustomerZipcode								NVARCHAR(MAX),
			@CustomerPhoneNumber							NVARCHAR(MAX),
			@CustomerCelullarNumber							NVARCHAR(MAX),
			@CustomerSSNumber								NVARCHAR(MAX),
			@TypeTaxId										INT,
			@HasTaxId										BIT,
			@HasDuplicatedTaxId								BIT,
			@CustomerBornDate								DATETIME,
			@CustomerOccupation								NVARCHAR(MAX),
			@CustomerIdentificationNumber					NVARCHAR(MAX),
			@CustomerExpirationIdentification				DATETIME,
			@CustomerPurpose								NVARCHAR(MAX),
			@CustomerRelationship							NVARCHAR(MAX),
			@CustomerMoneySource							NVARCHAR(MAX),
			@CustomerIdCarrier								INT,
			@CustomerIdOccupation							INT = 0,
			@CustomerIdSubcategoryOccupation				INT = 0,
			@CustomerSubcategoryOccupationOther				NVARCHAR(MAX) =NULL,
			@XmlRules										XML,
			@IdTransferResend								INT,
			@OWBName										NVARCHAR(MAX),
			@OWBFirstLastName								NVARCHAR(MAX),
			@OWBSecondLastName								NVARCHAR(MAX),
			@OWBAddress										NVARCHAR(MAX),
			@OWBCity										NVARCHAR(MAX),
			@OWBState										NVARCHAR(MAX),
			@OWBZipcode										NVARCHAR(MAX),
			@OWBPhoneNumber									NVARCHAR(MAX),
			@OWBCelullarNumber								NVARCHAR(MAX),
			@OWBSSNumber									NVARCHAR(MAX),
			@OWBBornDate									DATETIME,
			@OWBOccupation									NVARCHAR(MAX),
			@OWBIdentificationNumber						NVARCHAR(MAX),
			@OWBIdCustomerIdentificationType				INT,
			@OWBExpirationIdentification					DATETIME,
			@OWBPurpose										NVARCHAR(MAX),
			@OWBRelationship								NVARCHAR(MAX),
			@OWBMoneySource									NVARCHAR(MAX),
			@OWBIdOccupation								INT,
			@OWBIdSubcategoryOccupation						INT,
			@OWBSubcategoryOccupationOther					NVARCHAR(MAX),
			@AgentCommissionExtra							MONEY,
			@AgentCommissionOriginal						MONEY,
			@AgentCommissionEditedByCommissionSlider		MONEY,
			@AgentCommissionEditedByExchangeRateSlider		MONEY,
			@StateTax										MONEY,
			@OriginExRate									MONEY,
			@OriginAmountInMN								MONEY,
			@NoteAdditional									VARCHAR(MAX),
			@CustomerIdentificationIdCountry				INT,
			@CustomerIdentificationIdState					INT,
			@OWBRuleType									INT,
			@IdBeneficiaryIdentificationType				INT,
			@BeneficiaryIdentificationNumber				NVARCHAR(MAX),
			@SSNRequired									BIT,
			@SendMoneyAlertInvitation						BIT,
			@IdCustomerCountryOfBirth						INT,
			@IdBeneficiaryCountryOfBirth					INT,
			@BeneficiaryBornDate							DATETIME,
			@CustomerReceiveSms								BIT,
			@ReSendSms										BIT,
			@AccountTypeId									INT,
			@CustomerOccupationDetail						NVARCHAR(MAX),
			@TransferIdCity									INT,
			@BeneficiaryIdCarrier							INT,
			@BranchCodePontual								VARCHAR(10),
			@CustomerOFACMatch								XML,
			@BeneficiaryOFACMatch							XML,
			@IdTransferOriginal								BIGINT,
			@IsModify										BIT,
			@IdPaymentMethod								INT,
			@Discount										MONEY,
			@OperationFee									MONEY,
            -- Cellular Validation
			@isValidCustomerPhoneNumber						BIT ,
			@IdDialingCodePhoneNumber						INT,
            @IdDialingCodeBeneficiaryPhoneNumber            INT

	SELECT
		@IdCustomer = p.IdCustomer,
		@IdBeneficiary = p.IdBeneficiary,
		@IdPaymentType = p.IdPaymentType,
		@IdCity = p.IdCity,
		@IdBranch = p.IdBranch,
		@IdPayer = p.IdPayer,
		@IdGateway = p.IdGateway,
		@GatewayBranchCode = p.GatewayBranchCode,
		@IdAgentPaymentSchema = p.IdAgentPaymentSchema,
		@IdAgent = p.IdAgent,
		@IdAgentSchema = p.IdAgentSchema,
		@IdCountryCurrency = p.IdCountryCurrency,
		@AmountInDollars = p.AmountInDollars,
		@Fee = p.Fee,
		@AgentCommission = p.AgentCommission,
		@CorporateCommission = p.CorporateCommission,
		@ExRate = p.ExRate,
		@ReferenceExRate = p.ReferenceExRate,
		@AmountInMN = p.AmountInMN,
		@DepositAccountNumber = p.DepositAccountNumber,
		@EnterByIdUser = p.EnterByIdUser,
		@TotalAmountToCorporate = p.TotalAmountToCorporate,
		@BeneficiaryName = p.BeneficiaryName,
		@BeneficiaryFirstLastName = p.BeneficiaryFirstLastName,
		@BeneficiarySecondLastName = p.BeneficiarySecondLastName,
		@BeneficiaryAddress = p.BeneficiaryAddress,
		@BeneficiaryCity = p.BeneficiaryCity,
		@BeneficiaryState = p.BeneficiaryState,
		@BeneficiaryCountry = p.BeneficiaryCountry,
		@BeneficiaryZipcode = p.BeneficiaryZipcode,
		@BeneficiaryPhoneNumber = p.BeneficiaryPhoneNumber,
		@BeneficiaryCelularNumber = p.BeneficiaryCelularNumber,
		@CustomerName = p.CustomerName,
		@CustomerIdCustomerIdentificationType = p.CustomerIdCustomerIdentificationType,
		@CustomerFirstLastName = p.CustomerFirstLastName,
		@CustomerSecondLastName = p.CustomerSecondLastName,
		@CustomerAddress = p.CustomerAddress,
		@CustomerCity = p.CustomerCity,
		@CustomerState = p.CustomerState,
		@CustomerZipcode = p.CustomerZipcode,
		@CustomerPhoneNumber = p.CustomerPhoneNumber,
		@CustomerCelullarNumber = p.CustomerCelullarNumber,
		@CustomerSSNumber = p.CustomerSSNumber,
		@TypeTaxId = c.IdTypeTax,
		@HasTaxId =  c.HasAnswerTaxId,
		@HasDuplicatedTaxId =  c.IdTaxDupli,
		@CustomerBornDate = p.CustomerBornDate,
		@CustomerOccupation = p.CustomerOccupation,
		@CustomerIdentificationNumber = p.CustomerIdentificationNumber,
		@CustomerExpirationIdentification = p.CustomerExpirationIdentification,
		@CustomerPurpose = p.Purpose,
		@CustomerRelationship = p.Relationship,
		@CustomerMoneySource = p.MoneySource,
		@CustomerIdCarrier = p.CustomerIdCarrier,
		@CustomerIdOccupation = p.CustomerIdOccupation,
		@CustomerIdSubcategoryOccupation = p.CustomerIdSubOccupation,
		@CustomerSubcategoryOccupationOther = p.CustomerSubOccupationOther,
		@XmlRules = p.BrokenRules,
		@IdTransferResend = p.IdTransferResend,
		@OWBName = o.Name,
		@OWBFirstLastName = o.FirstLastName,
		@OWBSecondLastName = o.SecondLastName,
		@OWBAddress = o.Address,
		@OWBCity = o.City,
		@OWBState = o.[State],
		@OWBZipcode = o.Zipcode,
		@OWBPhoneNumber = o.PhoneNumber,
		@OWBCelullarNumber = o.CelullarNumber,
		@OWBSSNumber = o.SSNumber,
		@OWBBornDate = o.BornDate,
		@OWBOccupation = o.Occupation,
		@OWBIdentificationNumber = o.IdentificationNumber,
		@OWBIdCustomerIdentificationType = o.IdCustomerIdentificationType,
		@OWBExpirationIdentification = o.ExpirationIdentification,
		@OWBPurpose = o.Purpose,
		@OWBRelationship = o.Relationship,
		@OWBMoneySource = o.MoneySource,
		@OWBIdOccupation = o.IdOccupation,
		@OWBIdSubcategoryOccupation = o.IdSubcategoryOccupation,
		@OWBSubcategoryOccupationOther = o.SubcategoryOccupationOther,
		@AgentCommissionExtra = p.AgentCommissionExtra,
		@AgentCommissionOriginal = p.AgentCommissionOriginal,
		@AgentCommissionEditedByCommissionSlider = p.ModifierCommissionSlider,
		@AgentCommissionEditedByExchangeRateSlider = p.ModifierExchangeRateSlider,
		@StateTax = p.StateTax,
		@OriginExRate = p.OriginExRate,
		@OriginAmountInMN = p.OriginAmountInMN,
		@NoteAdditional = p.NoteAdditional,
		@CustomerIdentificationIdCountry = p.CustomerIdentificationIdCountry,
		@CustomerIdentificationIdState = p.CustomerIdentificationIdState,
		@OWBRuleType = p.OWBRuleType,
		@IdBeneficiaryIdentificationType = p.IdBeneficiaryIdentificationType,
		@BeneficiaryIdentificationNumber = p.BeneficiaryIdentificationNumber,
		@SSNRequired = ISNULL(s.SSNRequired, 0),
		@SendMoneyAlertInvitation = p.SendMoneyAlertInvitation,
		@IdCustomerCountryOfBirth = p.CustomerIdCountryOfBirth,
		@IdBeneficiaryCountryOfBirth = p.BeneficiaryIdCountryOfBirth,
		@BeneficiaryBornDate = p.BeneficiaryBornDate,
		@CustomerReceiveSms = c.ReceiveSms,
		@ReSendSms = 0,-- @ReSendSms
		@AccountTypeId = p.AccountTypeId,
		@CustomerOccupationDetail = p.CustomerOccupationDetail,
		@TransferIdCity = p.TransferIdCity,
		@BeneficiaryIdCarrier = p.BeneficiaryIdCarrier,
		@BranchCodePontual = NULL,-- @BranchCodePontual
		@CustomerOFACMatch = p.CustomerOFACMatch,
		@BeneficiaryOFACMatch = p.BeneficiaryOFACMatch,
		@IdTransferOriginal = p.IdTransferOriginal,
		@IsModify = p.IsModify,
		@IdPaymentMethod = p.IdPaymentMethod,
		@Discount = p.Discount,
		@OperationFee = p.OperationFee,
        -- Cellular Validation
		@isValidCustomerPhoneNumber	=p.IsValidCustomerPhoneNumber,
		@IdDialingCodePhoneNumber=p.IdDialingCodePhoneNumber,
        @IdDialingCodeBeneficiaryPhoneNumber = p.IdDialingCodeBeneficiaryPhoneNumber
	FROM PreTransfer p WITH(NOLOCK)
		LEFT JOIN OnWhoseBehalf o WITH(NOLOCK) ON o.IdOnWhoseBehalf = p.IdOnWhoseBehalf
		LEFT JOIN PreTransferSSN s WITH(NOLOCK) ON s.IdPreTransfer = p.IdPreTransfer
		JOIN Customer c WITH(NOLOCK) ON c.IdCustomer = p.IdCustomer
	WHERE p.IdPreTransfer = @IdPretransfer

	IF @CustomerOFACMatch IS NULL OR @BeneficiaryOFACMatch IS NULL
	BEGIN
		SET @HasError = 1
		SET @Message = 'Error OFAC fields missings'
	END

	DECLARE @ClaimCode VARCHAR(50)
	IF @ClaimCodeApi IS NULL
	BEGIN
		EXEC st_BuildClaimCodeForTransfer @IdGateway, @IdPayer, @IdPaymentType, @ClaimCode OUT
	END
	ELSE
	BEGIN
		SET @ClaimCode =  @ClaimCodeApi
	END
	PRINT @IdGateway
	PRINT @IdPayer
	PRINT @IdPaymentType

	BEGIN TRANSACTION
	BEGIN TRY
		EXEC st_CreateTransferFromPreTransfer
		    @IdPreTransfer = @IdPreTransfer,
			@IdTransferOriginal = @IdTransferOriginal,
			@IdLenguage = @IdLenguage,
			@IdCustomer = @IdCustomer,
			@IdBeneficiary = @IdBeneficiary,
			@IdPaymentType = @IdPaymentType,
			@IdCity = @IdCity,
			@IdBranch = @IdBranch,
			@IdPayer = @IdPayer,
			@IdGateway = @IdGateway,
			@GatewayBranchCode = @GatewayBranchCode,
			@IdAgentPaymentSchema = @IdAgentPaymentSchema,
			@IdAgent = @IdAgent,
			@IdAgentSchema = @IdAgentSchema,
			@IdCountryCurrency = @IdCountryCurrency,
			@AmountInDollars = @AmountInDollars,
			@Fee = @Fee,
			@AgentCommission = @AgentCommission,
			@CorporateCommission = @CorporateCommission,
			@ExRate = @ExRate,
			@ReferenceExRate = @ReferenceExRate,
			@AmountInMN = @AmountInMN,
			@DepositAccountNumber = @DepositAccountNumber,
			@EnterByIdUser = @EnterByIdUser,
			@TotalAmountToCorporate = @TotalAmountToCorporate,
			@BeneficiaryName = @BeneficiaryName,
			@BeneficiaryFirstLastName = @BeneficiaryFirstLastName,
			@BeneficiarySecondLastName = @BeneficiarySecondLastName,
			@BeneficiaryAddress = @BeneficiaryAddress,
			@BeneficiaryCity = @BeneficiaryCity,
			@BeneficiaryState = @BeneficiaryState,
			@BeneficiaryCountry = @BeneficiaryCountry,
			@BeneficiaryZipcode = @BeneficiaryZipcode,
			@BeneficiaryPhoneNumber = @BeneficiaryPhoneNumber,
			@BeneficiaryCelularNumber = @BeneficiaryCelularNumber,
			@CustomerName = @CustomerName,
			@CustomerIdCustomerIdentificationType = @CustomerIdCustomerIdentificationType,
			@CustomerFirstLastName = @CustomerFirstLastName,
			@CustomerSecondLastName = @CustomerSecondLastName,
			@CustomerAddress = @CustomerAddress,
			@CustomerCity = @CustomerCity,
			@CustomerState = @CustomerState,
			@CustomerZipcode = @CustomerZipcode,
			@CustomerPhoneNumber = @CustomerPhoneNumber,
			@CustomerCelullarNumber = @CustomerCelullarNumber,
			@CustomerSSNumber = @CustomerSSNumber,
			@TypeTaxId = @TypeTaxId,
			@HasTaxId = @HasTaxId,
			@HasDuplicatedTaxId = @HasDuplicatedTaxId,
			@CustomerBornDate = @CustomerBornDate,
			@CustomerOccupation = @CustomerOccupation,
			@CustomerIdentificationNumber = @CustomerIdentificationNumber,
			@CustomerExpirationIdentification = @CustomerExpirationIdentification,
			@CustomerPurpose = @CustomerPurpose,
			@CustomerRelationship = @CustomerRelationship,
			@CustomerMoneySource = @CustomerMoneySource,
			@CustomerIdCarrier = @CustomerIdCarrier,
			@CustomerIdOccupation = @CustomerIdOccupation,
			@CustomerIdSubcategoryOccupation = @CustomerIdSubcategoryOccupation,
			@CustomerSubcategoryOccupationOther = @CustomerSubcategoryOccupationOther,
			@XmlRules = @XmlRules,
			@IdTransferResend = @IdTransferResend,
			@OWBName = @OWBName,
			@OWBFirstLastName = @OWBFirstLastName,
			@OWBSecondLastName = @OWBSecondLastName,
			@OWBAddress = @OWBAddress,
			@OWBCity = @OWBCity,
			@OWBState = @OWBState,
			@OWBZipcode = @OWBZipcode,
			@OWBPhoneNumber = @OWBPhoneNumber,
			@OWBCelullarNumber = @OWBCelullarNumber,
			@OWBSSNumber = @OWBSSNumber,
			@OWBBornDate = @OWBBornDate,
			@OWBOccupation = @OWBOccupation,
			@OWBIdentificationNumber = @OWBIdentificationNumber,
			@OWBIdCustomerIdentificationType = @OWBIdCustomerIdentificationType,
			@OWBExpirationIdentification = @OWBExpirationIdentification,
			@OWBPurpose = @OWBPurpose,
			@OWBRelationship = @OWBRelationship,
			@OWBMoneySource = @OWBMoneySource,
			@OWBIdOccupation = @OWBIdOccupation,
			@OWBIdSubcategoryOccupation = @OWBIdSubcategoryOccupation,
			@OWBSubcategoryOccupationOther = @OWBSubcategoryOccupationOther,
			@AgentCommissionExtra = @AgentCommissionExtra,
			@AgentCommissionOriginal = @AgentCommissionOriginal,
			@AgentCommissionEditedByCommissionSlider = @AgentCommissionEditedByCommissionSlider,
			@AgentCommissionEditedByExchangeRateSlider = @AgentCommissionEditedByExchangeRateSlider,
			@StateTax = @StateTax,
			@OriginExRate = @OriginExRate,
			@OriginAmountInMN = @OriginAmountInMN,
			@NoteAdditional = @NoteAdditional,
			@CustomerIdentificationIdCountry = @CustomerIdentificationIdCountry,
			@CustomerIdentificationIdState = @CustomerIdentificationIdState,
			@OWBRuleType = @OWBRuleType,
			@IdBeneficiaryIdentificationType = @IdBeneficiaryIdentificationType,
			@BeneficiaryIdentificationNumber = @BeneficiaryIdentificationNumber,
			@HasError = @HasError OUT,
			@Message = @Message OUT,
			@IdTransferOutput = @IdTransfer OUT,
			@SSNRequired = @SSNRequired,
			@IsSaveCustomer = 1,
			@SendMoneyAlertInvitation = @SendMoneyAlertInvitation,
			@IdCustomerCountryOfBirth = @IdCustomerCountryOfBirth,
			@IdBeneficiaryCountryOfBirth = @IdBeneficiaryCountryOfBirth,
			@BeneficiaryBornDate = @BeneficiaryBornDate,
			@CustomerReceiveSms = @CustomerReceiveSms,
			@ReSendSms = @ReSendSms,
			@AccountTypeId = @AccountTypeId,
			@CustomerOccupationDetail = @CustomerOccupationDetail,
			@TransferIdCity = @TransferIdCity,
			@BeneficiaryIdCarrier = @BeneficiaryIdCarrier,
			@BranchCodePontual = @BranchCodePontual,
			@IsModify = @IsModify,
			@OnlineTransfer = 1,
			@IdPaymentMethod = @IdPaymentMethod,
			@Discount = @Discount,
			@OperationFee = @OperationFee,
            -- Cellular Validation
			@isValidCustomerPhoneNumber	=@isValidCustomerPhoneNumber,
			@IdDialingCodePhoneNumber=	@IdDialingCodePhoneNumber,
			@ClaimCode = @ClaimCode

			UPDATE Transfer SET
				StateTax = @StateTax,
				IdTransferResend = @IdTransferResend,
                IdDialingCodeBeneficiaryPhoneNumber = @IdDialingCodeBeneficiaryPhoneNumber
			WHERE IdTransfer = @IdTransfer
			
			-- OFAC
			DECLARE @CustomerHasMatch           BIT,
					@CustomerCanDiscard         BIT,
					@CustomerXMLMatch           XML,
					@CustomerScore				FLOAT,
					@CustomerMessage			VARCHAR(300),

					@BeneficiaryHasMatch		BIT,
					@BeneficiaryCanDiscard		BIT,
					@BeneficiaryXMLMatch		XML,
					@BeneficiaryScore			FLOAT,
					@BeneficiaryMessage			VARCHAR(300),

					@PercentOfacMatchBit 		FLOAT,
					@PercentOfac 				FLOAT,
					@PercentDoubleVerification 	FLOAT,
					@IsOFACDoubleVerification	BIT

			SELECT	@PercentOfacMatchBit = dbo.GetGlobalAttributeByName('PercentOfacMatchBit'), 
        			@PercentOfac = dbo.GetGlobalAttributeByName('MinOfacMatch'),
        			@PercentDoubleVerification = dbo.GetGlobalAttributeByName('PercentOfacDoubleVerification')

			EXEC st_EvaluateOFACResult @CustomerOFACMatch, @CustomerScore OUT, @CustomerMessage OUT, @CustomerHasMatch OUT, @CustomerCanDiscard OUT, @CustomerXMLMatch OUT
			EXEC st_EvaluateOFACResult @BeneficiaryOFACMatch, @BeneficiaryScore OUT, @BeneficiaryMessage OUT, @BeneficiaryHasMatch OUT, @BeneficiaryCanDiscard OUT, @BeneficiaryXMLMatch OUT

			SET @IsOFACDoubleVerification = CASE WHEN (@CustomerScore >= @PercentOfacMatchBit OR @BeneficiaryScore >= @PercentOfacMatchBit) THEN 1 ELSE 0 END
			INSERT INTO TransferOFACInfo
			(
				IdTransfer,
				CustomerOfacPercent,
				CustomerMatch,
				BeneficiaryOfacPercent,
				BeneficiaryMatch,
				PercentOfacMatchBit,
				MinPercentOfacMatch,
				CustomerName,
				CustomerFirstLastName,
				CustomerSecondLastName,
				BeneficiaryName,
				BeneficiaryFirstLastName,
				BeneficiarySecondLastName,
				IsCustomerFullMatch,
				IsBeneficiaryFullMatch,
				IsOFACDoubleVerification,
				PercentDoubleVerification,
				IsCustomerOldProccess,
				IsBeneficiaryOldProccess
			)
     		VALUES 
			(
				@IdTransfer,
				@CustomerScore,
				@CustomerXMLMatch,
				@BeneficiaryScore,
				@BeneficiaryXMLMatch,
				@PercentOfacMatchBit,
				@PercentOfac,
				@CustomerName,
				@CustomerFirstLastName,
				@CustomerSecondLastName,
				@BeneficiaryName,
				@BeneficiaryFirstLastName,
				@BeneficiarySecondLastName,
				CASE WHEN @CustomerScore >= @PercentOfacMatchBit THEN 1 ELSE 0 END,
				CASE WHEN @BeneficiaryScore >= @PercentOfacMatchBit THEN 1 ELSE 0 END,
				@IsOFACDoubleVerification,
				@PercentDoubleVerification,
				0,
				0
			)

			IF ISNULL(@IdPaymentMethod, 1) = 2 AND NOT EXISTS (SELECT 1 FROM TransferModify tm WHERE tm.NewIdTransfer = @IdTransfer)
			BEGIN
				DECLARE @IdStatusPendingPayment INT = 73
				EXEC st_SaveChangesToTransferLog @IdTransfer, @IdStatusPendingPayment, 'Pending payment, the transfer is released when the payment is completed in the terminal', 0

				DECLARE @InvoiceNoText VARCHAR(200) = CONCAT('Invoice ID: ', @IdTransfer)
				EXEC st_SaveChangesToTransferLog @IdTransfer, @IdStatusPendingPayment, @InvoiceNoText, 0
			END
			ELSE
				EXEC st_InitTransaction @IdTransfer

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500) = ERROR_MESSAGE();

		SET @HasError = 1
		SET @Message = dbo.GetMessageFromMultiLenguajeResorces(1,'MESSAGE07')

		INSERT INTO ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage)
		VALUES('st_CommitTransfer', GETDATE(), CONCAT(@Message, ' EX: ', @MSG_ERROR, ' @IdPreTransfer: ', @IdPretransfer));
	END CATCH

END
