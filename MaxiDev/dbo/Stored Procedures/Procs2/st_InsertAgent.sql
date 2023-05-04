CREATE PROCEDURE [dbo].[st_InsertAgent]
(
	@AgentApp_AgentCode								VARCHAR(200),

	@AgentApp_IdAgentCommunication                  INT,
	@AgentApp_IdAgentEntityType                     INT, --
	@AgentApp_LegalName                             VARCHAR(500),
	@AgentApp_DBA                                   VARCHAR(500),
	@AgentApp_Address                               VARCHAR(500),
	@AgentApp_City                                  VARCHAR(500),
	@AgentApp_State                                 VARCHAR(500),
	@AgentApp_Country                               VARCHAR(500),	--
	@AgentApp_ZipCode                               VARCHAR(500), 
	@AgentApp_Email                                 VARCHAR(500),	--
	--@AgentApp_PermitNumber                          VARCHAR(500),	-- BM-801
	@AgentApp_Expires                               DATETIME,		--
	@AgentApp_IdAgentTaxIdType                      INT,			--
	@AgentApp_Phone                                 VARCHAR(500),	
	@AgentApp_Fax                                   VARCHAR(500),
	@AgentApp_TimeInBusiness                        DATETIME,
	@AgentApp_Website                               VARCHAR(150),	--
	@AgentApp_Contact                               VARCHAR(500),	--
	@AgentApp_CheckCasher                           BIT,			--
	@AgentApp_License                               BIT,			--
	@AgentApp_LicenseNumber                         VARCHAR(500),	--
	@AgentApp_FinCENReg                             VARCHAR(500),	--
	@AgentApp_ExpirationFinCEN                      DATETIME,		--
	@AgentApp_Billpayment                           BIT,
	@AgentApp_Flex                                  BIT,
	@AgentApp_IdAgentReceiptType                    INT,
	@AgentApp_ComplianceOfficer                     VARCHAR(500),	--
	@AgentApp_Notes                                 VARCHAR(500),
	@AgentApp_IdAgentBankDeposit                    INT,
	@AgentApp_IdAgentBusinessType                   INT,
	@AgentApp_Activity                              VARCHAR(500),
	@AgentApp_TaxId                                 VARCHAR(500),
	@AgentApp_DoneOnSundayPayOn                     INT,
	@AgentApp_DoneOnMondayPayOn                     INT,
	@AgentApp_DoneOnTuesdayPayOn                    INT,
	@AgentApp_DoneOnWednesdayPayOn                  INT,
	@AgentApp_DoneOnThursdayPayOn                   INT,
	@AgentApp_DoneOnFridayPayOn                     INT,
	@AgentApp_DoneOnSaturdayPayOn                   INT,
	@AgentApp_CommissionAgent                       MONEY,
	@AgentApp_CommissionCorp                        MONEY,
	@AgentApp_HasAch                                BIT,
	@AgentApp_CommissionAgentOtherCountries         MONEY,
	@AgentApp_CommissionCorpOtherCountries          MONEY,
	@AgentApp_IdAgentClass                          INT,
	@AgentApp_IdAgentPaymentSchema                  INT,
	@AgentApp_RetainMoneyCommission                 BIT,
	@AgentApp_IdAgentCommissionPay                  INT,
	@AgentApp_AccountNumberCommission               INT,
	@AgentApp_RoutingNumberCommission               INT,
	@AgentApp_AccountNumberCollection               INT,			-- BM-586
	@AgentApp_RoutingNumberCollection               INT,			-- BM-586
	@AgentApp_IdCounty                              INT,
	@AgentApp_PhoneNumbers                          XML,			--
	@AgentApp_AgentCompetitions                     XML,			--
	@AgentApp_NeedsWFSubaccount                     BIT,			--
	@AgentApp_RequestWFSubaccount                   BIT,			--
	@AgentApp_BusinessPermissionNumber              VARCHAR(200),
	@AgentApp_BusinessPermissionExpiration          DATETIME,
	@AgentApp_IdAgentCollectTypeDefault		        INT,
	@AgentApp_AgentCollectTypes				        XML,
	@AgentApp_MailCheckTo							VARCHAR(20),
	@AgentApp_ComplianceOfficerPlaceOfBirth			VARCHAR(250),
	@AgentApp_SendNotifyOpening						BIT,			-- BM-1108

	@ResponsibleOwner_IdOwner                       INT,
	@ResponsibleOwner_Name                          VARCHAR(500),
	@ResponsibleOwner_LastName                      VARCHAR(500),
	@ResponsibleOwner_SecondLastName                VARCHAR(500),
	@ResponsibleOwner_Address                       VARCHAR(500),
	@ResponsibleOwner_City                          VARCHAR(500),
	@ResponsibleOwner_State                         VARCHAR(500),
	@ResponsibleOwner_Country                       VARCHAR(500),	--
	@ResponsibleOwner_ZipCode                       VARCHAR(500),
	@ResponsibleOwner_IdDocumentType                INT,
	@ResponsibleOwner_IdExpirationDate              DATETIME,
	@ResponsibleOwner_IdNumber                      INT,
	@ResponsibleOwner_IdState                       INT,			--
	@ResponsibleOwner_SSN                           VARCHAR(500),
	@ResponsibleOwner_HomePhoneNumber               VARCHAR(500),
	@ResponsibleOwner_CellPhoneNumber               VARCHAR(500),
	@ResponsibleOwner_DateOfBirth                   DATETIME,
	@ResponsibleOwner_IdCountryOfBirth              INT,
	@ResponsibleOwner_Email                         VARCHAR(500),
	@ResponsibleOwner_CreditScore                   MONEY,
	@ResponsibleOwner_IdCounty                      INT,
	@ResponsibleOwner_IdStateEmission				INT,
	@ResponsibleOwner_IdCountryEmission             INT,

	@BeneficialOwners                               XML,			--

	@Guarantor_IdGuarantor                          INT,
	@Guarantor_Name                                 VARCHAR(500),
	@Guarantor_LastName                             VARCHAR(500),
	@Guarantor_SecondLastName                       VARCHAR(500),
	@Guarantor_Address                              VARCHAR(500),
	@Guarantor_City                                 VARCHAR(500),
	@Guarantor_State                                VARCHAR(500),
	@Guarantor_Country                              VARCHAR(500),
	@Guarantor_ZipCode                              VARCHAR(500),
	@Guarantor_IdDocumentType                       INT,
	@Guarantor_IdExpirationDate                     DATETIME,
	@Guarantor_IdNumber                             INT,
	@Guarantor_IdState                              INT,
	@Guarantor_SSN                                  VARCHAR(500),
	@Guarantor_HomePhoneNumber                      VARCHAR(500),
	@Guarantor_CellPhoneNumber                      VARCHAR(500),
	@Guarantor_DateOfBirth                          DATETIME,
	@Guarantor_IdCountryOfBirth                     INT,
	@Guarantor_Email                                VARCHAR(500),
	@Guarantor_CreditScore                          MONEY,
	@Guarantor_IdCounty                             INT,

	@NotifyOpening_Note                             VARCHAR(500),	--
	@NotifyOpening_SubjectMail                      VARCHAR(500),	--

	@IdUser                                         INT,

	@Document_AgentDocuments						XML,			-- BM-586

	@Success										BIT OUT,
	@ErrorMessage									VARCHAR(200) OUT,
	@IdAgent										INT OUT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Catalogs</app>
<Description>This stored is used in Ares 2.0 Apis Legacy to create a Agent</Description>

<ChangeLog>
<log Date="17/08/2022" Author="maprado">Add @AgentApp_AgentCollectTypes & @AgentApp_IdAgentCollectTypeDefault parameters and logic insert </log>
<log Date="26/12/2022" Author="maprado">Se agrega AgentApp_Website, ResponsibleOwner_IdStateEmission y ResponsibleOwner_IdCountryEmission</log>
<log Date="01/02/2023" Author="maprado">BM-801 - Se remueve @AgentApp_PermitNumber ya que no se utiliza</log>
<log Date="27/02/2023" Author="maprado">BM-1108 - Se agrega AgentApp_SendNotifyOpening como bandera para envio de correo de NotifyOpening</log>
<log Date="01/03/2023" Author="maprado">BM- 586 - Se agrega AccountNumberCollection, RoutingNumberCollection y logica para guardado de imagenes desde Aws S3</log>
<log Date="22/03/2023" Author="maprado">BM- 1352 - IdAgentBankDeposit nullable y validacion @Document_AgentDocuments cuando no es nulo guarda registro</log>
</ChangeLog>
*********************************************************************/
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
		SELECT	@Success = 1,
				@ErrorMessage = NULL

		DECLARE @IdOwnerOut				INT,
				@IdAgentApplicationOut	INT,
				@Message				VARCHAR(MAX),
				@HasError				BIT,
				@IsValid				BIT

	IF ISNULL(@AgentApp_AgentCode, '') = ''
	BEGIN
		EXEC st_GetNewAgentCode @AgentApp_State, @IdUser, @AgentApp_AgentCode OUT, @IsValid OUT

		IF @IsValid = 0
		BEGIN
			SET @Success = 0
			SET @ErrorMessage = 'An unexpected error occurred while generating the agent code'

			ROLLBACK TRANSACTION
			RETURN
		END
	END

	--BEGIN BM-586
	DECLARE  @DocHandle INT

	CREATE TABLE #AgentDocuments
	(
		IdDocumentType	INT,
		FileName		VARCHAR(300),
		Extension		VARCHAR(5),
		Url				VARCHAR(300)
	);
	
	IF (@Document_AgentDocuments IS NOT NULL)
	BEGIN
		EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Document_AgentDocuments

		INSERT INTO #AgentDocuments
		SELECT IdDocumentType, FileName, Extension, Url
		FROM OPENXML (@DocHandle, '/AgentDocuments/AgentDocument',2)
		WITH (
				IdDocumentType		INT,
				FileName			VARCHAR(300),
				Extension			VARCHAR(5),
				Url					VARCHAR(300)
			);

		EXEC sp_xml_removedocument @DocHandle
	END
	--END BM-586

	DECLARE @OwnerBornCountry		VARCHAR(200)

	SELECT 
		@OwnerBornCountry = c.CountryName 
	FROM Country c WITH (NOLOCK)
	WHERE c.IdCountry = @ResponsibleOwner_IdCountryOfBirth

	--BEGIN BM-1352
	IF (@AgentApp_IdAgentBankDeposit = 0)
	BEGIN
		SET @AgentApp_IdAgentBankDeposit = NULL;
	END
	--END BM-1352
	
	EXEC st_CreateAgentApplication
			@AgentApp_IdAgentCommunication,							--@IdAgentApplicationCommunication
			@IdUser,												--@IdUserSeller
			@AgentApp_IdAgentReceiptType,							--@IdAgentApplicationReceiptType
			@AgentApp_IdAgentBankDeposit,							--@IdAgentApplicationBankDeposit
			@AgentApp_IdAgentBusinessType,							--@IdAgentBusinessType
			@AgentApp_DBA,											--@AgentName
			@AgentApp_AgentCode,									--@AgentCode
			@AgentApp_Address,										--@AgentAddress
			@AgentApp_City,											--@AgentCity
			@AgentApp_State,										--@AgentState
			@AgentApp_ZipCode,										--@AgentZipCode
			@AgentApp_Phone,										--@AgentPhone
			@AgentApp_Fax,											--@AgentFax
			@AgentApp_Contact,										--@AgentContact
			@AgentApp_TimeInBusiness,								--@AgentTimeInBusiness
			@AgentApp_Website,										--@AgentBusinessWebsite
			@AgentApp_Activity,										--@AgentActivity
			@AgentApp_TaxId,										--@TaxId
			@AgentApp_Notes,										--@Notes
			@AgentApp_BusinessPermissionNumber,						--@BusinessPermissionNumber
			@AgentApp_BusinessPermissionExpiration,					--@BusinessPermissionExpiration
			@AgentApp_DoneOnSundayPayOn,							--@DoneOnSundayPayOn
			@AgentApp_DoneOnMondayPayOn,							--@DoneOnMondayPayOn
			@AgentApp_DoneOnTuesdayPayOn,							--@DoneOnTuesdayPayOn
			@AgentApp_DoneOnWednesdayPayOn,							--@DoneOnWednesdayPayOn
			@AgentApp_DoneOnThursdayPayOn,							--@DoneOnThursdayPayOn
			@AgentApp_DoneOnFridayPayOn,							--@DoneOnFridayPayOn
			@AgentApp_DoneOnSaturdayPayOn,							--@DoneOnSaturdayPayOn
			@AgentApp_CommissionAgent,								--@CommissionAgent
			@AgentApp_CommissionCorp,								--@CommissionCorp
			@AgentApp_Billpayment,									--@HasBillPayment
			@AgentApp_Flex,											--@HasFlexStatus
			@AgentApp_HasAch,										--@HasAch
			@AgentApp_CommissionAgentOtherCountries,				--@CommissionAgentOtherCountries
			@AgentApp_CommissionCorpOtherCountries,					--@CommissionCorpOtherCountries
			@AgentApp_IdAgentClass,									--@IdAgentClass
			@AgentApp_DBA,											--@DoingBusinessAs
			@AgentApp_IdAgentPaymentSchema,							--@IdAgentPaymentSchema
			@AgentApp_RetainMoneyCommission,						--@RetainMoneyCommission
			@AgentApp_IdAgentCommissionPay,							--@IdAgentCommissionPay
			@AgentApp_AccountNumberCommission,						--@AccountNumberCommission
			@AgentApp_RoutingNumberCommission,						--@RoutingNumberCommission
			@AgentApp_IdCounty,										--@IdCounty
			@ResponsibleOwner_IdOwner,								--@IdOwner
			@ResponsibleOwner_Name,									--@OwnerName
			@ResponsibleOwner_LastName,								--@OwnerLastName
			@ResponsibleOwner_SecondLastName,						--@OwnerSecondLastName
			@ResponsibleOwner_Address,								--@OwnerAddress
			@ResponsibleOwner_City,									--@OwnerCity
			@ResponsibleOwner_State,								--@OwnerState
			@ResponsibleOwner_ZipCode,								--@OwnerZipcode
			@ResponsibleOwner_HomePhoneNumber,						--@OwnerPhone
			@ResponsibleOwner_CellPhoneNumber,						--@OwnerCel
			@ResponsibleOwner_Email,								--@OwnerEmail
			@ResponsibleOwner_SSN,									--@OwnerSSN
			@ResponsibleOwner_IdDocumentType,						--@OwnerIdType
			@ResponsibleOwner_IdNumber,								--@OwnerIdNumber
			@ResponsibleOwner_IdExpirationDate,						--@OwnerIdExpirationDate
			@ResponsibleOwner_DateOfBirth,							--@OwnerBornDate
			@OwnerBornCountry,										--@OwnerBornCountry
			@ResponsibleOwner_CreditScore,							--@OwnerCreditScore
			@ResponsibleOwner_IdCounty,								--@OwnerIdCounty
			@IdUser,												--@EnterByIdUser
			@AgentApp_PhoneNumbers,									--@PhoneNumbers
			@AgentApp_AgentCompetitions,							--@AgentCompetitions
			1,														--@IdLenguage
			@AgentApp_SendNotifyOpening,							--@SaveNote
			@NotifyOpening_Note,									--@Note
			@NotifyOpening_SubjectMail,								--@subjectMail
			@IdOwnerOut				OUT,							--@IdOwnerOut
			@IdAgentApplicationOut	OUT,							--@IdAgentApplicationOut
			@Message				OUT,							--@Message
			@HasError				OUT,							--@HasError
			@AgentApp_NeedsWFSubaccount,							--@NeedsWFSubaccount
			@AgentApp_RequestWFSubaccount,							--@RequestWFSubaccount
			NULL,													--@ValuesAgentBusinessType
			@ResponsibleOwner_IdStateEmission,						--@OwnerIdStateEmission
			@ResponsibleOwner_IdCountryEmission,					--@OwnerIdCountryEmission
			@AgentApp_ComplianceOfficerPlaceOfBirth,				--@ComplianceOfficerPlaceOfBirth
			@AgentApp_MailCheckTo									--@MailCheckTo

		IF @HasError = 1
		BEGIN
			SET @Success = 0
			SET @ErrorMessage = CONCAT('An error occurred while creating agent application, ', @Message)

			ROLLBACK TRANSACTION
			RETURN
		END

		DECLARE @GuarantorBornCountry		VARCHAR(200)

		SELECT 
			@GuarantorBornCountry = c.CountryName 
		FROM Country c WITH (NOLOCK)
		WHERE c.IdCountry = @Guarantor_IdCountryOfBirth

		UPDATE AgentApplications SET
			GuarantorName = @Guarantor_Name,
			GuarantorLastName = @Guarantor_LastName,
			GuarantorSecondLastName = @Guarantor_SecondLastName,
			GuarantorAddress = @Guarantor_Address,
			GuarantorCity = @Guarantor_City,
			GuarantorState = @Guarantor_State,
			GuarantorBornCountry = @GuarantorBornCountry,
			GuarantorZipCode = @Guarantor_ZipCode,
			GuarantorIdType = @Guarantor_IdDocumentType,
			GuarantorIdExpirationDate = @Guarantor_IdExpirationDate,
			GuarantorIdNumber = @Guarantor_IdNumber,
			GuarantorSSN = @Guarantor_SSN,
			GuarantorPhone = @Guarantor_HomePhoneNumber,
			GuarantorCel = @Guarantor_CellPhoneNumber,
			GuarantorBornDate = @Guarantor_DateOfBirth,
			GuarantorEmail = @Guarantor_Email,
			GuarantorCreditScore = @Guarantor_CreditScore,
			IdCountyGuarantor = @Guarantor_IdCounty
		WHERE IdAgentApplication = @IdAgentApplicationOut


		EXEC st_MoveAgentAppToAgent 
			@IdAgentApplicationOut,		--@IdAgentApplication
			0,							--@IsSpanishLanguage
			@HasError	OUT,			--@HasError
			@Message	OUT,			--@Message
			@IdAgent	OUT				--@IdNewAgent

		IF @HasError = 1
		BEGIN
			SET @Success = 0
			SET @ErrorMessage = CONCAT('An error occurred while creating agent, ', @Message)

			ROLLBACK TRANSACTION
			RETURN
		END

		UPDATE Agent SET
			IdAgentEntityType = @AgentApp_IdAgentEntityType,
			AgentEmail = @AgentApp_Email,
			IdAgentTaxIdType = @AgentApp_IdAgentTaxIdType,
			AgentContact = @AgentApp_Contact,
			IdAgentCollectType = @AgentApp_IdAgentCollectTypeDefault,
			AccountNumber = @AgentApp_AccountNumberCollection,			-- BM-586
			RoutingNumber = @AgentApp_RoutingNumberCollection			-- BM-586
		WHERE IdAgent = @IdAgent

		INSERT INTO Corp.AgentCollectTypeRelAgent(IdAgent, IdAgentCollectType, IsDefault, CreationDate, EnterByIdUser)
		SELECT @IdAgent, @AgentApp_IdAgentCollectTypeDefault, 1, GETDATE(), @IdUser

		INSERT INTO Corp.AgentCollectTypeRelAgent(IdAgent, IdAgentCollectType, IsDefault, CreationDate, EnterByIdUser)
		SELECT
			@IdAgent,
			CAST(t.c.value('.[1]', 'int') AS INT),
			0,
			GETDATE(), 
			@IdUser
		FROM @AgentApp_AgentCollectTypes.nodes('root/int') t(c)
		WHERE CAST(t.c.value('.[1]', 'int') AS INT) <> @AgentApp_IdAgentCollectTypeDefault

		--BEGIN BM-586
		IF EXISTS(SELECT 1 FROM #AgentDocuments)
		BEGIN
			INSERT INTO [dbo].[AgentDocument]  ([IdAgent], [IdDocumentType], [FileName], [Extension], [Url], [IsUpload], [IdGenericStatus], [CreationDate], [DateOfLastChange], [EnterByIdUser])
			SELECT @IdAgent, AD.IdDocumentType, AD.FileName, AD.Extension, AD.Url, 0, 1, GETDATE(), GETDATE(), @IdUser FROM #AgentDocuments AD
		END
		--END BM-586


		/*
		@AgentApp_Country                               VARCHAR(500),	--
@AgentApp_PermitNumber                          VARCHAR(500),	--
@AgentApp_Expires                               DATETIME,		--
@AgentApp_CheckCasher                           BIT,			--
@AgentApp_License                               BIT,			--
@AgentApp_LicenseNumber                         VARCHAR(500),	--
@AgentApp_FinCENReg                             VARCHAR(500),	--
@AgentApp_ExpirationFinCEN                      DATETIME,		--
@AgentApp_ComplianceOfficer                     VARCHAR(500),	--


@ResponsibleOwner_Country                       VARCHAR(500),	--
@ResponsibleOwner_IdState                       INT,			--
@BeneficialOwners                               XML,			--


@Guarantor_IdState
		
		*/

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT	@Success = 0,
				@ErrorMessage = 'An unexpected error occurred while inserting Agent'

		DECLARE @ExMessage VARCHAR(1000) = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		VALUES(OBJECT_NAME(@@PROCID), GETDATE(), @ExMessage)

	END CATCH
END
