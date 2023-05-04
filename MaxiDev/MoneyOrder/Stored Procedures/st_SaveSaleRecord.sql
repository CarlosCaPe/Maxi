
/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="03/08/2023" Author="jcsierra">Se agregan logs en status history</log>
	<log Date="03/08/2023" Author="jcsierra">Add IdAgentPaymentSchema column</log>
</ChangeLog>
********************************************************************/
CREATE   PROCEDURE [MoneyOrder].[st_SaveSaleRecord]
(
	@IdAgent							INT,
	@Sequence							BIGINT,

	@IdCustomer							INT = 0,
	@IdDialingCodePhoneNumber			INT,
	@CustomerCelullarNumber				VARCHAR(200),

	@CustomerName						VARCHAR(200),
	@CustomerFirstLastName				VARCHAR(200),
	@CustomerSecondLastName				VARCHAR(200),

	@Maker								VARCHAR(200),
	@Remitter							VARCHAR(600),
	@Payee								VARCHAR(600),
	@Purchaser							VARCHAR(600),

	@RouteCode							VARCHAR(200),
	@AccountNumber						VARCHAR(200),

	@Amount								MONEY,
	@FeeAmount							MONEY,

	@ExpirationDate						DATETIME,

	@CustomerHasTaxId					BIT,
	@CustomerIdTypeTaxId                INT,
	@CustomerSSN						VARCHAR(200),
	@CustomerHasDuplicatedTaxId         BIT,

	@CustomerIdIdentificationType       INT,
	@CustomerIdentificationNumber       VARCHAR(200),
	@CustomerExpirationIdentification   DATETIME,
	@CustomerIdentificationIdCountry    INT,
	@CustomerIdentificationIdState      INT,
	@CustomerIdCountryOfBirth           INT,

	@CustomerBornDate                   DATETIME,
	@CustomerIdOccupation               INT,
	@CustomerIdSubcategoryOccupation    INT,
	@CustomerSubcategoryOccupationOther VARCHAR(200),

	@CustomerPurpose                    VARCHAR(200),
	@CustomerRelationship               VARCHAR(200),
	@CustomerMoneySource                VARCHAR(200),

	@KycRules							NVARCHAR(MAX) = '',
	
	@CustomerScore						TINYINT = 0,
	@CustomerMatch						NVARCHAR(MAX) = '',
	
	@RemitterScore						TINYINT = 0,
	@RemitterMatch						NVARCHAR(MAX) = '',
	
	@MinMatchScore						TINYINT = 0,
	
	@EnterByIdUser						INT,
	@IdLanguage							INT,

	@Success							BIT OUT,
	@ResultMessage						VARCHAR(200) OUT,
	@IdRecord							INT OUT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	BEGIN TRY
		SET @IdRecord = 0

		DECLARE @IdCustomerOutput	INT,
				@IdElasticCustomer	VARCHAR(200),
				@CurrentDate		DATETIME = GETDATE(),
				@IdStatusOrigin		INT = 1,
				@TotalAmount		MONEY = @Amount + @FeeAmount,
				@IdSequence			INT,
				@IdSequenceStatus	INT

		SELECT 
			@IdSequence = s.IdSequence,
			@IdSequenceStatus = s.IdSequenceStatus
		FROM MoneyOrder.[Sequence] s WITH(NOLOCK)
			JOIN MoneyOrder.SequenceMovement sm WITH(NOLOCK) ON sm.IdSequenceMovement = s.IdSequenceMovement
		WHERE
			s.[Sequence] = @Sequence
			AND sm.IdAgent = @IdAgent

		-- Validations
		IF @IdSequenceStatus <> 1
			SET @MSG_ERROR = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'MO_SequenceNotValid');

		IF ISNULL(@MSG_ERROR, '') <> ''
		BEGIN
			SET @Success = 0
			SET @ResultMessage = @MSG_ERROR
			RETURN;
		END

		SET @CustomerSecondLastName = ISNULL(@CustomerSecondLastName, '')
		
		EXEC dbo.st_InsertCustomerByTransfer 
			@IdCustomer,                            --@IdCustomer
			@IdAgent,                               --@IdAgentCreatedBy
			@CustomerIdIdentificationType,          --@IdCustomerIdentificationType
			1,                                      --@IdGenericStatus
			@CustomerName,                          --@Name
			@CustomerFirstLastName,                 --@FirstLastName
			@CustomerSecondLastName,				--@SecondLastName
			'',                                     --@Address
			'',                                     --@City
			'',                                     --@State
			'',                                     --@Country
			'',                                     --@Zipcode
			'',                                     --@PhoneNumber
			@CustomerCelullarNumber,                --@CelullarNumber
			@CustomerSSN,                           --@SSNumber
			@CustomerBornDate,                      --@BornDate
			'',                                     --@Occupation
			@CustomerIdOccupation,                  --@IdOccupation
			@CustomerIdSubcategoryOccupation,       --@IdSubcategoryOccupation
			@CustomerSubcategoryOccupationOther,    --@SubcategoryOccupationOther
			@CustomerIdentificationNumber,          --@IdentificationNumber
			0,                                      --@PhysicalIdCopy
			@CurrentDate,                           --@DateOfLastChange
			@EnterByIdUser,                         --@EnterByIdUser
			@CustomerExpirationIdentification,      --@ExpirationIdentification
			0,                                      --@IdCarrier
			@CustomerIdentificationIdCountry,       --@IdentificationIdCountry
			@CustomerIdentificationIdState,         --@IdentificationIdState
			0,                                      --@AmountSend
			@CustomerIdCountryOfBirth,              --@IdCustomerCountryOfBirth
			0,                                      --@CustomerReceiveSms
			0,                                      --@ReSendSms
			@IdAgent,                               --@AgentIdRequest
			@CustomerIdTypeTaxId,                   --@TypeTaxID
			@CustomerHasDuplicatedTaxId,            --@IsDuplicate
			@CustomerHasTaxId,                      --@HasTaxId
			'',                                     --@CustomerOccupationDetail
			@IdCustomerOutput OUT,                  --@IdCustomerOutput
			@IdElasticCustomer OUT,                 --@idElasticCustomer
			@IdDialingCodePhoneNumber               --@IdDialingCodePhoneNumber

		DECLARE @AgentCommission		MONEY,
				@CorporateCommission	MONEY,
				@TotalAmountToCorporate	MONEY,
				@IdAgentPaymentSchema	INT,
				@CommissionToAgent		TINYINT

		SELECT @CommissionToAgent = CommissionToAgent FROM MoneyOrder.AgentRegistration WHERE IdAgent = @IdAgent

		SET @AgentCommission = @FeeAmount * @CommissionToAgent / 100
		SET @CorporateCommission = @FeeAmount - @AgentCommission
		SELECT
			@TotalAmountToCorporate = IIF(a.IdAgentPaymentSchema = 1, @Amount + @FeeAmount, @Amount + @FeeAmount - @AgentCommission),
			@IdAgentPaymentSchema = IdAgentPaymentSchema
		FROM Agent a 
		WHERE a.IdAgent = @IdAgent

		INSERT INTO MoneyOrder.SaleRecord
		(
			IdAgent,
			IdSequence,
			IdStatus,
			IdCustomer,
			IdDialingCodePhoneNumber,
			CustomerCelullarNumber,
			CustomerName,
			CustomerFirstLastName,
			CustomerSecondLastName,
			Maker,
			Remitter,
			Payee,
			Purchaser,
			RouteCode,
			AccountNumber,
			SequenceNumber,
			WorksheetDate,
			SaleDate,
			Amount,
			FeeAmount,
			TotalAmount,
			ExpirationDate,

			AgentCommission,
			CorporateCommission,

			TotalAmountToCorporate,

			CustomerHasTaxId,
			CustomerIdTypeTaxId,
			CustomerSSN,
			CustomerHasDuplicatedTaxId,

			CustomerIdIdentificationType,
			CustomerIdentificationNumber,
			CustomerExpirationIdentification,
			CustomerIdentificationIdCountry,
			CustomerIdentificationIdState,
			CustomerIdCountryOfBirth,

			CustomerBornDate,
			CustomerIdOccupation,
			CustomerIdSubcategoryOccupation,
			CustomerSubcategoryOccupationOther,

			CustomerPurpose,
			CustomerRelationship,
			CustomerMoneySource,

			CreationDate,
			DateOfLastChange,
			EnterByIdUser,
			IdAgentPaymentSchema
		)
		VALUES
		(
            @IdAgent,
            @IdSequence,
            @IdStatusOrigin,
            @IdCustomerOutput,
            @IdDialingCodePhoneNumber,
            @CustomerCelullarNumber,
            @CustomerName,
            @CustomerFirstLastName,
            @CustomerSecondLastName,
            @Maker,
            @Remitter,
            @Payee,
            @Purchaser,
            @RouteCode,
            @AccountNumber,
            @Sequence,
            @CurrentDate,
            @CurrentDate,
            @Amount,
            @FeeAmount,
            @TotalAmount,
            @ExpirationDate,

			@AgentCommission,
			@CorporateCommission,

			@TotalAmountToCorporate,

            @CustomerHasTaxId,
            @CustomerIdTypeTaxId,
            @CustomerSSN,
            @CustomerHasDuplicatedTaxId,

            @CustomerIdIdentificationType,
            @CustomerIdentificationNumber,
            @CustomerExpirationIdentification,
            @CustomerIdentificationIdCountry,
            @CustomerIdentificationIdState,
            @CustomerIdCountryOfBirth,

            @CustomerBornDate,
            @CustomerIdOccupation,
            @CustomerIdSubcategoryOccupation,
            @CustomerSubcategoryOccupationOther,

            @CustomerPurpose,
            @CustomerRelationship,
            @CustomerMoneySource,

            @CurrentDate,
            @CurrentDate,
            @EnterByIdUser,
			@IdAgentPaymentSchema
		)

		SET @IdRecord = @@IDENTITY

		IF ((@KycRules IS NOT NULL) AND len(@KycRules) > 0) 
		BEGIN
			DECLARE @XML XML = CAST(@KycRules AS XML)

			INSERT INTO MoneyOrder.SaleRecordBrokenRules
				(IdSaleRecord
				, IdRule
				, MessageInSpanish
				, MessageInEnglish)
			SELECT
				@IdRecord
				, doc.col.value('IdRule[1]', 'VARCHAR(200)')
				, doc.col.value('MessageInSpanish[1]', 'VARCHAR(200)')
				, doc.col.value('MessageInEnglish[1]', 'VARCHAR(200)')
			FROM @XML.nodes('/ArrayOfMOBrokenRules/MOBrokenRules') doc (col)
		END

		INSERT INTO MoneyOrder.SaleRecordOFACLog 
		(
			IdSaleRecord
			, CustomerScore
			, CustomerMatch
			, RemitterScore
			, RemitterMatch
			, MinMatchScore
		)
		VALUES
		(
			@IdRecord
			, @CustomerScore
			, IIF((@CustomerMatch IS NOT NULL) AND len(@CustomerMatch) > 0, @CustomerMatch, NULL)
			, @RemitterScore
			, IIF((@RemitterMatch IS NOT NULL) AND len(@RemitterMatch) > 0, @RemitterMatch, NULL)
			, @MinMatchScore
		)

		EXEC MoneyOrder.st_ChangeMoneyOrderStatus @IdRecord, NULL, 'Money Order Created', @EnterByIdUser, @IdLanguage

		SET @Success = 1
		SET @ResultMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericOkSave')
	END TRY
	BEGIN CATCH
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		SET @Success = 0
		SET @IdRecord = 0
		SET @ResultMessage = dbo.GetMessageFromMultiLenguajeResorces(@IdLanguage,'GenericErrorSave')

		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
		VALUES(ERROR_PROCEDURE() ,GETDATE(), @MSG_ERROR);
	END CATCH
END