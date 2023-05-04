
/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="2021/11/05" Author="jcsierra" Name="TDD">Add IdPaymentMethod and Discount column</log>
	<log Date="2022/02/09" Author="jcsierra" Name="TDD">Se asigna el valor @IdPaymentMethod = 1 en caso que llegue como 0</log>
	<log Date="2022/02/10" Author="gnegrete" Name="PhoneValidation">se agregan campos de validacion de numero de telefono</log>
	<log Date="2022/04/11" Author="jcsierra" Name="DomesticTransfers">Se agrega el parametro @IdDialingCodeBeneficiaryPhoneNumber </log>
	<log Date="2022/09/09" Author="maprado"  Name="Agent">Se agrega bandera @IsMonoUser y validacion para modificar transacciones de una agencia suspendida (solo multiAgente) </log>
	<log Date="2022/10/19" Author="maprado"  Name="Agent">Se agrega guardado de  Razon de no captura de telefono de cliente(solo multiAgente) </log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_SendPretransfer]
(
	@IdLenguage                                     INT,
	@IdCustomer                                     INT,
	@IdBeneficiary                                  INT,
	@IdPaymentType                                  INT,
	@IdCity                                         INT,
	@IdBranch                                       INT,
	@IdPayer                                        INT,
	@IdGateway                                      INT,
	@GatewayBranchCode                              NVARCHAR(MAX),
	@IdAgentPaymentSchema                           INT,
	@IdAgent                                        INT,
	@IdAgentSchema                                  INT,
	@IdCountryCurrency                              INT,
	@AmountInDollars                                MONEY,
	@Fee                                            MONEY,
	@AgentCommission                                MONEY,
	@CorporateCommission                            MONEY,
	@ExRate                                         MONEY,
	@ReferenceExRate                                MONEY,
	@AmountInMN                                     MONEY,
	@DepositAccountNumber                           NVARCHAR(MAX),
	@EnterByIdUser                                  INT,
	@TotalAmountToCorporate                         MONEY,
	@BeneficiaryName                                NVARCHAR(MAX),
	@BeneficiaryFirstLastName                       NVARCHAR(MAX),
	@BeneficiarySecondLastName                      NVARCHAR(MAX),
	@BeneficiaryAddress                             NVARCHAR(MAX),
	@BeneficiaryCity                                NVARCHAR(MAX),
	@BeneficiaryState                               NVARCHAR(MAX),
	@BeneficiaryCountry                             NVARCHAR(MAX),
	@BeneficiaryZipcode                             NVARCHAR(MAX),
	@BeneficiaryPhoneNumber                         NVARCHAR(MAX),
	@BeneficiaryCelularNumber                       NVARCHAR(MAX),
	@CustomerName                                   NVARCHAR(MAX),
	@CustomerIdCustomerIdentificationType           INT,
	@CustomerFirstLastName                          NVARCHAR(MAX),
	@CustomerSecondLastName                         NVARCHAR(MAX),
	@CustomerAddress                                NVARCHAR(MAX),
	@CustomerCity                                   NVARCHAR(MAX),
	@CustomerState                                  NVARCHAR(MAX),
	@CustomerZipcode                                NVARCHAR(MAX),
	@CustomerPhoneNumber                            NVARCHAR(MAX),
	@CustomerCelullarNumber                         NVARCHAR(MAX),
	@CustomerSSNumber                               NVARCHAR(MAX),
	@TypeTaxId                                      INT,
	@HasTaxId                                       BIT,
	@HasDuplicatedTaxId                             BIT,
	@CustomerBornDate                               DATETIME,
	@CustomerOccupation                             NVARCHAR(MAX),
	@CustomerIdOccupation                           INT = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation                INT = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther             NVARCHAR(MAX) =NULL,/*M00207*/
	@CustomerIdentificationNumber                   NVARCHAR(MAX),
	@CustomerExpirationIdentification               DATETIME,
	@CustomerPurpose                                NVARCHAR(MAX),
	@CustomerRelationship                           NVARCHAR(MAX),
	@CustomerMoneySource                            NVARCHAR(MAX),
	@CustomerIdCarrier                              INT,
	@XmlRules                                       XML,
	@OWBName                                        NVARCHAR(MAX),
	@OWBFirstLastName                               NVARCHAR(MAX),
	@OWBSecondLastName                              NVARCHAR(MAX),
	@OWBAddress                                     NVARCHAR(MAX),
	@OWBCity                                        NVARCHAR(MAX),
	@OWBState                                       NVARCHAR(MAX),
	@OWBZipcode                                     NVARCHAR(MAX),
	@OWBPhoneNumber                                 NVARCHAR(MAX),
	@OWBCelullarNumber                              NVARCHAR(MAX),
	@OWBSSNumber                                    NVARCHAR(MAX),
	@OWBBornDate                                    DATETIME,
	@OWBOccupation                                  NVARCHAR(MAX),
	@OWBIdOccupation                                INT = 0,/*M00207*/
	@OWBIdSubcategoryOccupation                     INT = 0,/*M00207*/
	@OWBSubcategoryOccupationOther                  NVARCHAR(MAX) =NULL,/*M00207*/
	@OWBIdentificationNumber                        NVARCHAR(MAX),
	@OWBIdCustomerIdentificationType                INT,
	@OWBExpirationIdentification                    DATETIME,
	@OWBPurpose                                     NVARCHAR(MAX),
	@OWBRelationship                                NVARCHAR(MAX),
	@OWBMoneySource                                 NVARCHAR(MAX),
	@AgentCommissionExtra                           MONEY,
	@AgentCommissionOriginal                        MONEY,
	@AgentCommissionEditedByCommissionSlider        MONEY,
	@AgentCommissionEditedByExchangeRateSlider      MONEY,
	@StateTax                                       MONEY,
	@OriginExRate                                   MONEY,
	@OriginAmountInMN                               MONEY,
	@NoteAdditional                                 VARCHAR(MAX),
	@CustomerIdentificationIdCountry                INT,
	@CustomerIdentificationIdState                  INT,
	@OWBRuleType                                    INT, --@OWBRuleType  0- No pidio Owbh, 1- Pidio y el dinero es suyo, 2- pidio y el dinero no es suyo
	@IdTransferResend                               INT = NULL,
	@TransferAmount                                 MONEY,
	@IdBeneficiaryIdentificationType                INT,
	@BeneficiaryIdentificationNumber                NVARCHAR(MAX),
	@HasError                                       BIT out,
	@Message                                        VARCHAR(MAX) out,
	@IdPreTransferOutput                            INT OUTPUT,
	@IdCustomerOutput                               INT OUTPUT,
	@SSNRequired                                    BIT = NULL,
	@IsSaveCustomer                                 BIT = NULL,
	@IdCustomerCountryOfBirth                       INT = NULL,
	@IdBeneficiaryCountryOfBirth                    INT = NULL,
	@BeneficiaryBornDate                            DATETIME = NULL,
	@CustomerReceiveSms                             BIT = 0,
	@ReSendSms                                      BIT = 0,
	@AccountTypeId                                  INT = NULL,
	@IsModifyPre                                    BIT = 0,
	@CustomerOccupationDetail                       NVARCHAR(MAX) = NULL, /*S44:REQ. MA.025*/
	@TransferIdCity                                 INT = NULL,
	@BeneficiaryIdCarrier                           INT = NULL,
	@idElasticCustomer                              VARCHAR(MAX) OUTPUT, /*Optmizacion Agente*/
	@IdBeneficiaryOutput                            INT OUTPUT, /*Optmizacion Agente*/
	@cardVip                                        VARCHAR(MAX) = NULL OUTPUT, /*Optmizacion Agente*/
	@CustomerOFACMatch								XML,
	@BeneficiaryOFACMatch							XML,
	@SendMoneyAlertInvitation						BIT,
	@IdTransferOriginal								INT = NULL,
	@IdPaymentMethod								INT = 1,
	@Discount										MONEY = 0,
	@OperationFee									MONEY = 0,
	@isValidCustomerPhoneNumber						BIT = 0,

	@IdDialingCodePhoneNumber						INT = NULL,
    @IdDialingCodeBeneficiaryPhoneNumber            INT = NULL,
	
	@IdReasonNotCustomerCellphone					INT = NULL,          /*S65:REQ. MP-1084*/
	@ReasonNotCustomerCellphone						NVARCHAR(500) = NULL /*S65:REQ. MP-1084*/
										  
)
AS

IF ISNULL(@IdPaymentMethod, 0) = 0
	SET @IdPaymentMethod = 1

SET NOCOUNT ON
SELECT  @HasError

DECLARE @CustomerIdAgentCreatedBy	INT				= @IdAgent,
		@DateOfPreTransfer			DATETIME		= GETDATE(),
		@DateOfPreTransferUTC		DATETIME		= GETUTCDATE(),
		@DateOfLastChange			DATETIME		= GETDATE(),
		@CustomerCountry			NVARCHAR(MAX)	= 'USA',
		@OWBCountry					NVARCHAR(MAX)	= 'USA',
		@BeneficiaryNote			NVARCHAR(MAX)	= '',
		@dateNow					DATETIME		= GETDATE(),
		@IsMonoUser                 BIT             = 0 
IF @IdLenguage IS NULL
    SET @IdLenguage=2
IF @IdBeneficiaryCountryOfBirth = 0
    SET @IdBeneficiaryCountryOfBirth=NULL

IF @IdCustomerCountryOfBirth = 0
    SET @IdCustomerCountryOfBirth=NULL

BEGIN TRY
	----------------------  Verify IF @EnterByIdUser resend PreTransfer in #time --------------------
	IF @EnterByIdUser<>0
	BEGIN
		DECLARE @DateOfTransfer2	DATETIME,
				@IdCustomerVal		INT,
				@IdBeneficiaryVal	INT,
				@AmountVal			MONEY

		SELECT TOP 1
			@IdCustomerVal = IdCustomer,
			@IdBeneficiaryVal = IdBeneficiary,
			@AmountVal = AmountInDollars,
			@DateOfTransfer2 = DateOfPreTransfer
		FROM [dbo].[PreTransfer] WITH(NOLOCK)
		WHERE EnterByIdUser= @EnterByIdUser
		ORDER BY IdTransfer DESC

		IF(DATEDIFF(SECOND, @DateOfTransfer2, @dateNow) <= 5 AND @IdCustomer = @IdCustomerVal AND @IdBeneficiary = @IdBeneficiaryVal AND @AmountInDollars = @AmountVal AND @IsModifyPre = 0)
		BEGIN
			SET @HasError=1
			SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE68')

			INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData)
			VALUES ('st_CreatePreTransfer', GETDATE(), ISNULL(@Message, ''), 'IdUser: ' +CONVERT(VARCHAR, @EnterByIdUser) + ', IdAgent: ' + CONVERT(VARCHAR, @IdAgent) + ', IdCustomer: ' + CONVERT(VARCHAR, @IdCustomer) + ', IdBeneficiary: ' + CONVERT(VARCHAR, @IdBeneficiary) + ', AmountInDollar: ' + CONVERT(VARCHAR, @AmountInDollars) );

			RETURN
		END
	END

	----------  Special case when Agent IS disable, Only MultiUser can Create ------------------------------

	IF EXISTS (SELECT 1 FROM AgentUser WITH (NOLOCK) WHERE IdUser = @EnterByIdUser)
	BEGIN
		SET @IsMonoUser = 1
	END

	IF EXISTS (SELECT 1 FROM Agent WITH(NOLOCK) WHERE IdAgent=@IdAgent AND (IdAgentStatus=2 OR IdAgentStatus=3 OR IdAgentStatus=5 OR IdAgentStatus=6 OR IdAgentStatus=7) AND (@IsMonoUser = 1))
	BEGIN
		SET @IdPreTransferOutput = 0
		SET @HasError = 1
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE29')

		RETURN
	END

	IF NOT EXISTS(SELECT idpayer FROM branch WITH(NOLOCK) WHERE idbranch=@IdBranch)
		SET @IdBranch=NULL

	----- Special case when Idbranch IS NULL but PreTransfer IS cash ----------------
	IF (@IdBranch IS NULL AND (@IdPaymentType=1 OR @IdPaymentType=4 OR @IdPaymentType=2 OR  @IdPaymentType=5))
	BEGIN
		IF @IdCity IS NULL
		BEGIN
			SELECT top 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL)  ORDER BY IdBranch
			SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch
		END
		ELSE
		BEGIN
			SELECT top 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL) AND IdCity=@IdCity ORDER BY IdBranch
			SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch
		END
	END

	-- Check Again IdBranch in case @IdCity was NOT NULL but NOT EXISTS
	IF (@IdBranch IS NULL AND (@IdPaymentType=1 OR @IdPaymentType=4 OR @IdPaymentType=2 OR @IdPaymentType=5))
	BEGIN
		SELECT top 1 @IdBranch=IdBranch FROM Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 OR IdGenericStatus IS NULL)  ORDER BY IdBranch
		SELECT @GatewayBranchCode=GatewayBranchCode FROM GatewayBranch WITH(NOLOCK) WHERE IdBranch=@IdBranch

		INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage) VALUES ('st_CreatePreTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(VARCHAR,@IdPayer));
	END

	---------------------------------------------------------------------------------

	IF @GatewayBranchCode IS NULL  SET @GatewayBranchCode=''
	IF @DepositAccountNumber IS NULL SET @DepositAccountNumber=''
	IF @BeneficiaryZipcode IS NULL  SET @BeneficiaryZipcode=''
	IF @BeneficiaryAddress IS NULL SET @BeneficiaryAddress=''
	IF @BeneficiaryCity IS NULL SET @BeneficiaryCity=''
	IF @BeneficiaryState IS NULL SET @BeneficiaryState=''
	IF @BeneficiaryCountry IS NULL SET @BeneficiaryCountry=''
	IF @BeneficiaryName IS NULL SET @BeneficiaryName=''
	IF @BeneficiaryFirstLastName IS NULL SET @BeneficiaryFirstLastName=''
	IF @BeneficiarySecondLastName IS NULL SET @BeneficiarySecondLastName=''
	IF @BeneficiaryPhoneNumber IS NULL SET @BeneficiaryPhoneNumber=''
	IF @BeneficiaryCelularNumber IS NULL SET @BeneficiaryCelularNumber=''
	IF @BeneficiaryNote IS NULL SET @BeneficiaryNote=''
	IF @CustomerZipcode IS NULL SET @CustomerZipcode=''
	IF @CustomerPhoneNumber  IS NULL SET @CustomerPhoneNumber=''
	IF @CustomerCelullarNumber IS NULL SET @CustomerCelullarNumber=''
	IF @CustomerSSNumber IS NULL SET @CustomerSSNumber=''
	IF @CustomerOccupation IS NULL SET @CustomerOccupation=''
	IF @CustomerSubcategoryOccupationOther IS NULL SET @CustomerSubcategoryOccupationOther=''
	IF @CustomerIdentificationNumber IS NULL SET @CustomerIdentificationNumber=''
	IF @CustomerPurpose IS NULL SET @CustomerPurpose=''
	IF @CustomerRelationship IS NULL SET @CustomerRelationship=''
	IF @CustomerMoneySource  IS NULL SET @CustomerMoneySource=''
	IF @OWBName IS NULL SET   @OWBName=''
	IF @OWBFirstLastName IS NULL SET @OWBFirstLastName=''
	IF @OWBSecondLastName IS NULL SET @OWBSecondLastName=''
	IF @OWBAddress IS NULL SET  @OWBAddress=''
	IF @OWBCity IS NULL SET @OWBCity=''
	IF @OWBState IS NULL SET @OWBState=''
	IF @OWBZipcode IS NULL SET @OWBZipcode=''
	IF @OWBPhoneNumber IS NULL SET @OWBPhoneNumber=''
	IF @OWBCelullarNumber  IS NULL SET @OWBCelullarNumber=''
	IF @OWBSSNumber  IS NULL SET @OWBSSNumber=''
	IF @OWBOccupation  IS NULL SET @OWBOccupation=''
	IF @OWBSubcategoryOccupationOther IS NULL SET @OWBSubcategoryOccupationOther=''
	IF @OWBIdentificationNumber  IS NULL SET @OWBIdentificationNumber=''
	IF @OWBPurpose  IS NULL SET @OWBPurpose=''
	IF @OWBRelationship  IS NULL SET @OWBRelationship=''
	IF @OWBMoneySource  IS NULL SET @OWBMoneySource=''

	/*S44:REQ. MA.025 - BEGIN*/
	IF @CustomerOccupationDetail IS NULL SET @CustomerOccupationDetail = '';
	IF @TransferIdCity = 0 SET @TransferIdCity = NULL;
	IF @BeneficiaryIdCarrier = 0 SET @BeneficiaryIdCarrier = NULL;
	/*S44:REQ. MA.025 - END*/
	IF @isValidCustomerPhoneNumber= 0 SET @isValidCustomerPhoneNumber = NULL;
	--IF @IdDialingCodePhoneNumber IS NULL SET @IdDialingCodePhoneNumber = '';				
																				   
	SET @DepositAccountNumber = CASE
		WHEN @IdPaymentType = 2 THEN @DepositAccountNumber
		WHEN @IdPaymentType = 5 THEN @DepositAccountNumber
		WHEN @IdPaymentType = 6 THEN @DepositAccountNumber /*MA_008*/
		ELSE ''
	END
	----------------------------------- INSERT/UPDATE Customer ----------------------------
	IF (@IdCustomer>0) AND (@IsSaveCustomer=0) AND NOT EXISTS (SELECT 1 FROM customer WITH(NOLOCK) WHERE idcustomer=@IdCustomer AND IdAgentCreatedBy=@IdAgent)
		SET @IsSaveCustomer = 1

	DECLARE @duplicate INT = 0

	IF (@HasDuplicatedTaxId =1)
		SET @duplicate = 1

	IF (@IsSaveCustomer=1)
	BEGIN
		EXEC [dbo].[st_InsertCustomerByTransfer]
		   @IdCustomer,
		   @CustomerIdAgentCreatedBy,
		   @CustomerIdCustomerIdentificationType,
		   1,
		   @CustomerName,
		   @CustomerFirstLastName,
		   @CustomerSecondLastName,
		   @CustomerAddress,
		   @CustomerCity,
		   @CustomerState,
		   @CustomerCountry,
		   @CustomerZipcode,
		   @CustomerPhoneNumber,
		   @CustomerCelullarNumber,
		   @CustomerSSNumber,
		   @CustomerBornDate,
		   @CustomerOccupation,
		   @CustomerIdOccupation, /*M00207*/
		   @CustomerIdSubcategoryOccupation,/*M00207*/
		   @CustomerSubcategoryOccupationOther,/*M00207*/
		   @CustomerIdentificationNumber,
		   0,
		   @DateOfPreTransfer,
		   @EnterByIdUser,
		   @CustomerExpirationIdentification,
		   @CustomerIdCarrier,
		   @CustomerIdentificationIdCountry,
		   @CustomerIdentificationIdState,
		   0,
		   @IdCustomerCountryOfBirth,
		   @CustomerReceiveSms,
		   @ReSendSms,
		   @IdAgent,
		   @TypeTaxId,
		   @duplicate,
		   @HasTaxId,
		   @CustomerOccupationDetail, /*S44:REQ. MA.025*/
		   @IdCustomerOutput OUTPUT,
		   @idElasticCustomer OUTPUT,
		   @IdDialingCodePhoneNumber
							  

		   SET @cardVip = ISNULL((SELECT top 1 CardNumber FROM CardVIP with (nolock) WHERE IdCustomer = @IdCustomerOutput),'')
		   SET @IdCustomer=@IdCustomerOutput--#1
	END
	ELSE
	BEGIN
		SET @idElasticCustomer = (SELECT top 1 idElasticCustomer FROM Customer with (nolock) WHERE IdCustomer = @IdCustomer)
		SET @cardVip = ISNULL((SELECT top 1 CardNumber FROM CardVIP with (nolock) WHERE IdCustomer = @IdCustomer),'')

		IF @ReSendSms = 1
			EXEC [Infinite].[st_insertInvitationSms] @CelullarNumber = @CustomerCelullarNumber, @EnterByIdUser = @EnterByIdUser, @AgentId = @IdAgent, @InsertSms = @ReSendSms

		SET @IdCustomerOutput=@IdCustomer
	END

	----------------------------------- INSERT/UPDATE Beneficiary ----------------------------
	EXEC st_InsertBeneficiaryByTransfer
		@IdBeneficiary,
		@BeneficiaryName,
		@BeneficiaryFirstLastName,
		@BeneficiarySecondLastName,
		@BeneficiaryAddress,
		@BeneficiaryCity,
		@BeneficiaryState,
		@BeneficiaryCountry,
		@BeneficiaryZipcode,
		@BeneficiaryPhoneNumber,
		@BeneficiaryCelularNumber,
		'',
		@BeneficiaryBornDate,
		'',
		@BeneficiaryNote,
		1,
		@DateOfPreTransfer,
		@EnterByIdUser,
		@IdBeneficiaryIdentificationType,
		@BeneficiaryIdentificationNumber,
		@IdBeneficiaryCountryOfBirth,
		@IdBeneficiaryOutput OUTPUT,
		@IdDialingCodeBeneficiaryPhoneNumber

	------------------------------ INSERT OWB ----------------------------------------------------
	DECLARE @IdOnWhoseBehalfOutput INT
	IF LEN(@OWBName)>0
		BEGIN
		EXEC st_InsertOnWhoseBehalf
			@IdAgent,
			1,
			@OWBName,
			@OWBFirstLastName,
			@OWBSecondLastName,
			@OWBAddress,
			@OWBCity,
			@OWBState,
			@OWBCountry,
			@OWBZipcode,
			@OWBPhoneNumber,
			@OWBCelullarNumber,
			@OWBSSNumber,
			@OWBBornDate,
			@OWBOccupation,
			@OWBIdOccupation,/*M00207*/
			@OWBIdSubcategoryOccupation,/*M00207*/
			@OWBSubcategoryOccupationOther,/*M00207*/
			@OWBIdentificationNumber,
			0,
			@OWBIdCustomerIdentificationType,
			@OWBExpirationIdentification,
			@OWBPurpose,
			@OWBRelationship,
			@OWBMoneySource,
			@DateOfPreTransfer,
			@EnterByIdUser,
			@IdOnWhoseBehalfOutput OUTPUT
	END
	ELSE
		SET @IdOnWhoseBehalfOutput=NULL

	-------------------------- Incremente de Folio por Agencia -----------------------------------------------------
	DECLARE @Folio INT
	DECLARE @IdPreTransfer INT
	DECLARE @IdSeller INT

	IF NOT EXISTS(SELECT 1 FROM [AgentFolioPreFolio] WITH(NOLOCK) WHERE idagent=@IdAgent)
		INSERT INTO [AgentFolioPreFolio] (idagent,folio,prefolio) VALUES (@IdAgent,0,0);

	UPDATE dbo.[AgentFolioPreFolio] SET
		PreFolio = PreFolio + 1,
		@Folio = PreFolio + 1
	WHERE IdAgent=@IdAgent;

	--------------------------- SELECT IDSeller  --------------------------------------------------------------------
	SELECT
		@IdSeller = ISNULL(IdUserSeller,1)
	FROM Agent WITH(NOLOCK)
	WHERE IdAgent=@IdAgent

	-----------------------------Crear PreTransfer------------------------------------------------------------------------------------
	INSERT INTO [PreTransfer]
	(
		IdCustomer,
		IdBeneficiary,
		IdPaymentType,
		IdBranch,
		IdPayer,
		IdGateway,
		GatewayBranchCode,
		IdAgentPaymentSchema,
		IdAgent,
		IdAgentSchema,
		IdCountryCurrency,
		--IdStatus,
		--ClaimCode,
		--ConfirmationCode,
		AmountInDollars,
		Fee,
		AgentCommission,
		CorporateCommission,
		DateOfPreTransfer,
		ExRate,
		ReferenceExRate,
		AmountInMN,
		Folio,
		DepositAccountNumber,
		DateOfLastChange,
		EnterByIdUser,
		TotalAmountToCorporate,
		BeneficiaryName,
		BeneficiaryFirstLastName,
		BeneficiarySecondLastName,
		BeneficiaryAddress,
		BeneficiaryCity,
		BeneficiaryState,
		BeneficiaryCountry,
		BeneficiaryZipcode,
		BeneficiaryPhoneNumber,
		BeneficiaryCelularNumber,
		BeneficiaryNote,
		CustomerName,
		CustomerIdAgentCreatedBy,
		CustomerIdCustomerIdentificationType,
		CustomerFirstLastName,
		CustomerSecondLastName,
		CustomerAddress,
		CustomerCity,
		CustomerState,
		CustomerCountry,
		CustomerZipcode,
		CustomerPhoneNumber,
		CustomerCelullarNumber,
		CustomerSSNumber,
		CustomerBornDate,
		CustomerOccupation,
		[CustomerIdOccupation],
		[CustomerIdSubOccupation],
		[CustomerSubOccupationOther],
		CustomerIdentificationNumber,
		CustomerExpirationIdentification,
		CustomerIdCarrier,
		IdOnWhoseBehalf,
		Purpose,
		Relationship,
		MoneySource,
		AgentCommissionExtra,
		AgentCommissionOriginal,
		ModifierCommissionSlider,
		ModifierExchangeRateSlider,
		IdSeller,
		OriginExRate,
		OriginAmountInMN,
		NoteAdditional,
		CustomerIdentificationIdCountry,
		CustomerIdentificationIdState,
		BrokenRules,
		IdCity,
		StateTax,
		OWBRuleType,
		IdTransferResend,
		TransferAmount,
		IdBeneficiaryIdentificationType,
		BeneficiaryIdentificationNumber,
		CustomerIdCountryOfBirth,
		BeneficiaryIdCountryOfBirth,
		BeneficiaryBornDate,
		[AccountTypeId],
		CustomerOccupationDetail, /*S44:REQ. MA.025*/
		TransferIdCity,
		BeneficiaryIdCarrier,
		CustomerOFACMatch,
		BeneficiaryOFACMatch,
		OnlineTransfer,
		SendMoneyAlertInvitation,
		IdTransferOriginal,
		IsModify,
		DateOfPreTransferUTC,
		IdPaymentMethod,
		Discount,
		OperationFee,
		isValidCustomerPhoneNumber,
		IdDialingCodePhoneNumber,
        IdDialingCodeBeneficiaryPhoneNumber 
	)
	VALUES (
		@IdCustomerOutput,
		@IdBeneficiaryOutput,
		@IdPaymentType,
		@IdBranch,
		@IdPayer,
		@IdGateway,
		@GatewayBranchCode,
		@IdAgentPaymentSchema,
		@IdAgent,
		@IdAgentSchema,
		@IdCountryCurrency,
		@AmountInDollars,
		@Fee,
		@AgentCommission,
		@CorporateCommission,
		@DateOfPreTransfer,
		@ExRate,
		@ReferenceExRate,
		@AmountInMN,
		@Folio,
		@DepositAccountNumber,
		@DateOfLastChange,
		@EnterByIdUser,
		@TotalAmountToCorporate,
		@BeneficiaryName,
		@BeneficiaryFirstLastName,
		@BeneficiarySecondLastName,
		@BeneficiaryAddress,
		@BeneficiaryCity,
		@BeneficiaryState,
		@BeneficiaryCountry,
		@BeneficiaryZipcode,
		@BeneficiaryPhoneNumber,
		@BeneficiaryCelularNumber,
		@BeneficiaryNote,
		@CustomerName,
		@CustomerIdAgentCreatedBy,
		@CustomerIdCustomerIdentificationType,
		@CustomerFirstLastName,
		@CustomerSecondLastName,
		@CustomerAddress,
		@CustomerCity,
		@CustomerState,
		@CustomerCountry,
		@CustomerZipcode,
		@CustomerPhoneNumber,
		@CustomerCelullarNumber,
		@CustomerSSNumber,
		@CustomerBornDate,
		@CustomerOccupation,
		@CustomerIdOccupation, /*M00207*/
		@CustomerIdSubcategoryOccupation,/*M00207*/
		@CustomerSubcategoryOccupationOther,/*M00207*/
		@CustomerIdentificationNumber,
		@CustomerExpirationIdentification,
		@CustomerIdCarrier,
		@IdOnWhoseBehalfOutput,
		@CustomerPurpose,
		@CustomerRelationship,
		@CustomerMoneySource,
		@AgentCommissionExtra,
		@AgentCommissionOriginal,
		@AgentCommissionEditedByCommissionSlider,
		@AgentCommissionEditedByExchangeRateSlider,
		@IdSeller,
		@OriginExRate,
		@OriginAmountInMN,
		@NoteAdditional,
		@CustomerIdentificationIdCountry,
		@CustomerIdentificationIdState,
		ISNULL(@XmlRules,''),
		@IdCity,
		@StateTax,
		@OWBRuleType,
		@IdTransferResend,
		@TransferAmount,
		@IdBeneficiaryIdentificationType,
		@BeneficiaryIdentificationNumber,
		@IdCustomerCountryOfBirth,
		@IdBeneficiaryCountryOfBirth,
		@BeneficiaryBornDate,
		@AccountTypeId,
		@CustomerOccupationDetail, /*S44:REQ. MA.025*/
		@TransferIdCity,
		@BeneficiaryIdCarrier,
		@CustomerOFACMatch,
		@BeneficiaryOFACMatch,
		1,
		@SendMoneyAlertInvitation,
		@IdTransferOriginal,
		@IsModifyPre,
		@DateOfPreTransferUTC,
		@IdPaymentMethod,
		@Discount,
		@OperationFee,
		@isValidCustomerPhoneNumber,
		@IdDialingCodePhoneNumber,
        @IdDialingCodeBeneficiaryPhoneNumber
	)

	SELECT @IdPreTransfer=SCOPE_IDENTITY();

	----------------------- S32 INSERT INFO TRANSFER CUSTOMER AND ACCOUNNUMBER OF DEPOSIT BY PAYER ------------
	EXEC st_saveTransferCustomerInfoByPayer	@IdCustomerOutput, @IdPayer,  @IdBeneficiaryOutput, @DepositAccountNumber;


	SET @IdPreTransferOutput=@IdPreTransfer

	IF(ISNULL(@SSNRequired, 0) = 1)
		INSERT INTO [PreTransferSSN] VALUES (@IdPreTransfer, 1, GETDATE());

	IF (ISNULL(@IsMonoUser,0) = 1 AND ISNULL(@IdReasonNotCustomerCellphone,0) != 0)
		INSERT INTO [TransferReasonNotCustomerPhone] VALUES (@IdPreTransfer,NULL,@IdReasonNotCustomerCellphone,@ReasonNotCustomerCellphone,@EnterByIdUser,GETDATE(),GETDATE());

	SET @HasError=0
	SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE69')
	SELECT @Message, @idElasticCustomer
END TRY
BEGIN CATCH
	SET @HasError=1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE70')

	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @CustomerOrCustomerOut VARCHAR(250)
	DECLARE @BenificiaryOrBenificiaryOut VARCHAR(250)

	SELECT  @ErrorMessage=ERROR_MESSAGE()

	SET @CustomerOrCustomerOut = CASE WHEN (@IdCustomer = 0 OR @IdCustomer IS NULL) AND @IdCustomerOutput > 0 THEN ' IdCustomerOutput: ' + CONVERT(VARCHAR, @IdCustomerOutput) ELSE ' IdCustomer: ' + CONVERT(VARCHAR, @IdCustomer) END
	SET @BenificiaryOrBenificiaryOut = CASE WHEN (@IdBeneficiary = 0 OR @IdBeneficiary IS NULL) AND @IdBeneficiaryOutput > 0 THEN ' IdBeneficiaryOutput: ' + CONVERT(VARCHAR, @IdBeneficiaryOutput) ELSE ' IdBeneficiary: ' + CONVERT(VARCHAR, @IdBeneficiary) END

	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_CreatePreTransfer : ' + @CustomerOrCustomerOut + ', ' + @BenificiaryOrBenificiaryOut + ', IdAgent: ' + CONVERT(VARCHAR, @IdAgent) + ', Folio ' + CONVERT(VARCHAR, ISNULL(@Folio, 0)) + ', Customer: ' + ISNULL(@CustomerName, 'UNK') + ' - ' + ISNULL(@CustomerFirstLastName, 'UNK') + ' - ' + ISNULL(@CustomerSecondLastName, 'UNK') + ', line: ' + CONVERT(VARCHAR,ERROR_LINE()),GETDATE(),@ErrorMessage);
END CATCH