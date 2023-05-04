CREATE PROCEDURE [dbo].[st_TransferDetail]
( 
    @IdTransfer Int, 
    @BrokenRule XML OUTPUT,
    @IsTransferReceipt BIT
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="10/05/2018" Author="snevarez">Case to ClaimCode for TrasnferTo(TTApi)</log>
<log Date="01/04/2019" Author="azavala">Return IdCustomer and IdBeneficiary</log>	
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON
 
IF EXISTS(SELECT TOP 1 1 FROM [dbo].[Transfer] WITH (NOLOCK) WHERE [IdTransfer]=@IdTransfer)
BEGIN
	--------------------------------------------- From Transaction ---------------------------------------------- 
	SELECT
		A.[IdAgent],
		A.[AgentPhone], 
		A.[IdAgentPaymentSchema],
		A.AgentState,
		B.[PaymentName],
		C.[PaymentName] [PaymentTypeName],
		T.[IdAgentSchema],
		ISNULL(D.[BranchName],'') [BranchName],
		IsNull (T.[IdBranch],0) [IdBranc],
		T.[IdBeneficiary],
		T.[IdCustomer],
		T.[IdCountryCurrency],
		F.[CountryName]+'/'+G.[CurrencyName] [CountryCurrency],
		ISNULL (T.[IdGateway],0) [IdGateway],
		ISNULL (H.[GatewayName],'') [Gateway],
		ISNULL (T.[IdOnWhoseBehalf],0) [IdOnWhoseBehalf],
		T.[IdPayer],
		I.[PayerName], 
		T.[IdPaymentType],
		T.[IdSeller],
		K.[UserName],
		T.[IdStatus],
		L.[StatusName],
		T.[IdTransfer],
		T.[AgentCommission],
		T.[AgentCommissionExtra],
		T.[AgentCommissionOriginal],
		T.[AmountInDollars],
		T.[AmountInMN],
		T.[DepositAccountNumber],
		T.[ExRate],
		T.[ReferenceExRate],
		
		/*T.[ClaimCode],*/
		CASE WHEN Api.Serial IS NULL THEN T.ClaimCode ELSE T.ClaimCode + '_' + CONVERT(VARCHAR(12),Api.Serial) END AS ClaimCode,/*10/05/2018*/

		T.[ConfirmationCode],
		T.[GatewayBranchCode],
		T.[Fee],
		T.[Folio],
		T.[CorporateCommission],
		T.[DateOfTransfer],
		T.[MoneySource],
		T.[Purpose],
		T.[Relationship],
		T.[TotalAmountToCorporate],
		T.[ModifierCommissionSlider],
		T.[ModifierExchangeRateSlider],
		ISNULL(T.[ReviewDenyList],0) [ReviewDenyList],
		ISNULL(T.[ReviewOfac],0) [ReviewOfac],
		ISNULL(T.[ReviewKYC],0) [ReviewKYC],
		T.[BeneficiaryAddress],
		T.[BeneficiaryBornDate],
		T.[BeneficiaryCelularNumber],
		T.[BeneficiaryCity],
		T.[BeneficiaryCountry],
		T.[BeneficiaryFirstLastName],
		T.[BeneficiarySecondLastName],
		T.[BeneficiaryName],
		T.[BeneficiaryOccupation],
		T.[BeneficiaryPhoneNumber],
		T.[BeneficiaryNote],
		T.[BeneficiarySSNumber],
		T.[BeneficiaryState],
		T.[BeneficiaryZipcode],
		T.[CustomerAddress],
		isnull(T.[CustomerBornDate], N.BornDate) AS CustomerBornDate,
		T.[CustomerCelullarNumber],
		T.[CustomerCity],
		T.[CustomerCountry],
		T.[CustomerExpirationIdentification],
		T.[CustomerFirstLastName],
		T.[CustomerSecondLastName],
		T.[CustomerName],
		T.[CustomerIdAgentCreatedBy],
		Q.[AgentCode]+' '+Q.[AgentName] [CustomerAgentCreatedBy],
		ISNULL(T.[CustomerIdCarrier],0) [CustomerIdCarrier],
		ISNULL(M.[Name],'') [CarrierName],
		ISNULL(T.[CustomerIdCustomerIdentificationType],0) [CustomerIdCustomerIdentificationType],
		ISNULL(P.[Name],'') [CustomerIdentificationName],
		T.[CustomerIdentificationNumber],
		T.CustomerIdOccupation,
		T.CustomerIdSubOccupation,
		T.CustomerSubOccupationOther,
		--T.[CustomerOccupation]
		/*S44:REQ. MA.025*/
		CASE 
		  WHEN T.[CustomerOccupation] IN ('--OTHER--', '--OTRA--') 
			 THEN (REPLACE(T.[CustomerOccupation],'-','') + ' ' + T.CustomerOccupationDetail ) 
			 ELSE T.[CustomerOccupation] END 
		  AS [CustomerOccupation], 

		T.[CustomerPhoneNumber], 
		T.[CustomerSSNumber],
		T.[CustomerState],
		T.[CustomerZipcode],
		N.[PhysicalIdCopy],
		A.[AgentCode],
		A.[AgentName],
		T.[BeneficiaryZipcode],
		T.[ReviewGateway],
		T.[ReviewReturned],
		T.[ReviewRejected],
		RT.[IdDocumentTransfertStatus],
		ISNULL(O.[IdOnWhoseBehalf],0) [OWBIdOnWhoseBehalf],
		ISNULL(O.[Name],'') [OWBName],
		ISNULL(O.[FirstLastName],'') [OWBFirstLastName],
		ISNULL(O.[SecondLastName],'') [OWBSecondLastName],
		ISNULL(O.[Address],'') [OWBAddress],
		ISNULL(O.[City],'') [OWBCity],
		ISNULL(O.[State],'') [OWBState],
		ISNULL(O.[Country],'') [OWBCountry],
		ISNULL(O.[Zipcode],'') [OWBZipcode],
		ISNULL(O.[PhoneNumber],'') [OWBPhoneNumber],
		ISNULL(O.[CelullarNumber],'') [OWBCelullarNumber],
		ISNULL(O.[SSNumber],'') [OWBSSNumber],
		ISNULL(O.[BornDate],'') [OWBBornDate],
		ISNULL(O.[Occupation],'') [OWBOccupation],
		ISNULL(O.[PhysicalIdCopy],'') [OWBPhysicalIdCopy],
		ISNULL(O.[IdCustomerIdentificationType],0) [OWBIdCustomerIdentificationType], ISNULL(O.[IdentificationNumber],'') [OWBIdentificationNumber],
		ISNULL(O.[ExpirationIdentification],'') [OWBExpirationIdentification],
		ISNULL(O.[Purpose],'') [OWBPurpose],
		ISNULL(O.[Relationship],'') [OWBRelationship],
		ISNULL(O.[MoneySource],'') [OWBMoneySource],
		ISNULL(R.[AgentCode]+' '+R.[AgentName],'') [OWBAgentCreatedBy],
		ISNULL(S.[UserName],'') [EnterByUserName],
		[IdBeneficiaryIdentificationType],
		[BeneficiaryIdentificationNumber],
		CASE 
			WHEN (SELECT TOP 1 1 FROM [dbo].[AgentUser] WITH (NOLOCK) WHERE [IdUser] = T.[EnterByIdUser]) = 1
				THEN 1
			ELSE
				0
		END [IsMonoAgent],
		ISNULL(DLC.[IdDenyListCustomer], 0) [IdDenyListCustomer],
		DLC.[NoteInToList] [NoteIntoListCustomer],
		DLC.[NoteOutFromList] [NoteOutFromListCustomer],
		DLC.[IdGenericStatus] [IdDenyListStatusCustomer],
		ISNULL(DLB.[IdDenyListBeneficiary], 0) [IdDenyListBeneficiary],
		DLB.[NoteInToList] [NoteIntoListBeneficiary],
		DLB.[NoteOutFromList] [NoteOutFromListBeneficiary],
		DLB.[IdGenericStatus] [IdDenyListStatusBeneficiary],
		T.[CustomerIdentificationIdCountry] [CustomerIdentificationIdCountry],
		T.[CustomerIdentificationIdState] [CustomerIdentificationIdState],
		CO.[CountryName] [CustomerIdentificationCountryName]
		,ISNULL((SELECT TOP 1 CSAR.[StatusSAR] FROM [dbo].[StatusCustomerSAR] CSAR WITH (NOLOCK) WHERE CSAR.[IdCustomer] = T.[IdCustomer] ORDER BY CSAR.[DataLastChange] DESC),0) [CustomerStatusSAR]
		,ISNULL((SELECT TOP 1 BSAR.[StatusSAR] FROM [dbo].[StatusBeneficiarySAR] BSAR WITH (NOLOCK) WHERE BSAR.[IdBeneficiary] = T.[IdBeneficiary] ORDER BY BSAR.[DataLastChange] DESC),0) [BeneficiaryStatusSAR]
		,CASE WHEN BRT.[IdTransfer] IS NULL THEN 0 ELSE 1 END [HasComplianceFormat]
		, T.[CustomerIdCountryOfBirth]
		, T.[BeneficiaryIdCountryOfBirth]
		, T.IdCustomer
		, T.IdBeneficiary	
	FROM [dbo].[Transfer] T WITH (NOLOCK)
	    INNER JOIN [dbo].[Agent] A WITH (NOLOCK) ON (A.[IdAgent]=T.[IdAgent])
	    INNER JOIN [dbo].[AgentPaymentSchema] B WITH (NOLOCK) ON A.[IdAgentPaymentSchema]=B.[IdAgentPaymentSchema]
	    INNER JOIN [dbo].[PaymentType] C WITH (NOLOCK) ON T.[IdPaymentType]=C.[IdPaymentType] 
	    LEFT JOIN [dbo].[Branch] D WITH (NOLOCK) ON D.[IdBranch]=T.[IdBranch]
	    INNER JOIN [dbo].[CountryCurrency] E WITH (NOLOCK) ON E.[IdCountryCurrency]=T.[IdCountryCurrency]
	    INNER JOIN [dbo].[Country] F WITH (NOLOCK) ON F.[IdCountry]=E.[IdCountry]
	    INNER JOIN [dbo].[Currency] G WITH (NOLOCK) ON G.[IdCurrency]=E.[IdCurrency]
	    LEFT JOIN [dbo].[Gateway] H WITH (NOLOCK) ON T.[IdGateway]=H.[IdGateway]
	    INNER JOIN [dbo].[Payer] I WITH (NOLOCK) ON I.[IdPayer]=T.[IdPayer]
	    INNER JOIN [dbo].[Users] K WITH (NOLOCK) ON K.[IdUser]=T.[IdSeller]
	    INNER JOIN [dbo].[Status] L WITH (NOLOCK) ON L.[IdStatus]=T.[IdStatus]
	    LEFT JOIN [dbo].[Carriers] M WITH (NOLOCK) ON M.[IdCarrier]=T.[CustomerIdCarrier]
	    INNER JOIN [dbo].[Customer] N WITH (NOLOCK) ON N.[IdCustomer]=T.[IdCustomer]
	    LEFT JOIN [dbo].[OnWhoseBehalf] O WITH (NOLOCK) ON T.[IdOnWhoseBehalf]=O.[IdOnWhoseBehalf]
	    LEFT JOIN [dbo].[CustomerIdentificationType] P WITH (NOLOCK) ON P.[IdCustomerIdentificationType]=T.[CustomerIdCustomerIdentificationType]
	    INNER JOIN [dbo].[Agent] Q WITH (NOLOCK) ON Q.[IdAgent]=N.[IdAgentCreatedBy]
	    LEFT JOIN [dbo].[Agent] R WITH (NOLOCK) ON R.[IdAgent]=O.[IdAgentCreatedBy]
	    LEFT JOIN [dbo].[Users] S WITH (NOLOCK) ON S.[IdUser]=T.[EnterByIdUser]
	    LEFT JOIN [dbo].[DenyListCustomer] DLC (NOLOCK) ON T.[IdCustomer] = DLC.[IdCustomer]
	    LEFT JOIN [dbo].[DenyListBeneficiary] DLB (NOLOCK) ON T.[IdBeneficiary] = DLB.[IdBeneficiary]
	    LEFT JOIN [dbo].[RelationTransferDocumentStatus] RT (NOLOCK) ON T.[IdTransfer] = RT.[IdTransfer] AND RT.[IsTransferReceipt] = @IsTransferReceipt
	    LEFT JOIN [dbo].[Country] CO WITH (NOLOCK) ON T.[CustomerIdentificationIdCountry] = CO.[IdCountry]
	    LEFT JOIN (
		    SELECT
			    BR.[IdTransfer]
		    FROM [dbo].[BrokenRulesByTransfer] BR (NOLOCK)
		    JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
		    WHERE LTRIM(ISNULL(CF.[FileOfName],'')) != ''
		    GROUP BY BR.[IdTransfer]
		    ) BRT ON T.[IdTransfer] = BRT.[IdTransfer]
	   LEFT JOIN TTApiSerial AS Api (NOLOCK) On T.IdTransfer = Api.IdTransfer /*10/05/2018*/
	WHERE T.[IdTransfer]=@IdTransfer;

END
ELSE
BEGIN
---------------------- From TransactionClosed -------------------------------------------------------- 
 
	SELECT 
		A.[IdAgent],
		A.[AgentPhone],
		A.[IdAgentPaymentSchema],
		A.AgentState,
		B.[PaymentName],
		T.[PaymentTypeName],
		T.[IdAgentSchema],
		IsNull(T.[BranchName],'') [BranchName],
		IsNull (T.[IdBranch],0) [IdBranc],
		T.[IdBeneficiary],
		T.[IdCustomer],
		T.[IdCountryCurrency],
		T.[CountryName]+'/'+T.[CurrencyName] [CountryCurrency],
		ISNULL(T.[IdGateway],0) [IdGateway],
		ISNULL(T.[GatewayName],'') [Gateway],
		ISNULL(T.[IdOnWhoseBehalf],0) [IdOnWhoseBehalf],
		T.[IdPayer],
		T.[PayerName],
		T.[IdPaymentType],
		T.[IdSeller],
		K.[UserName],
		T.[IdStatus],
		T.[StatusName],
		T.[IdTransferClosed] [IdTransfer],
		T.[AgentCommission],
		T.[AgentCommissionExtra],
		T.[AgentCommissionOriginal],
		T.[AmountInDollars],
		T.[AmountInMN],
		T.[DepositAccountNumber],
		T.[ExRate],
		T.[ReferenceExRate],
		T.[ClaimCode],
		T.[ConfirmationCode],
		T.[GatewayBranchCode],
		T.[Fee],
		T.[Folio],
		T.[CorporateCommission],
		T.[DateOfTransfer],
		T.[MoneySource],
		T.[Purpose],
		T.[Relationship],
		T.[TotalAmountToCorporate],
		T.[ModifierCommissionSlider],
		T.[ModifierExchangeRateSlider],
		ISNULL(T.[ReviewDenyList],0) [ReviewDenyList],
		ISNULL (T.[ReviewOfac],0) [ReviewOfac],
		ISNULL (T.[ReviewKYC],0) [ReviewKYC],
		T.[BeneficiaryAddress],
		T.[BeneficiaryBornDate],
		T.[BeneficiaryCelularNumber],
		T.[BeneficiaryCity],
		T.[BeneficiaryCountry],
		T.[BeneficiaryFirstLastName],
		T.[BeneficiarySecondLastName],
		T.[BeneficiaryName],
		T.[BeneficiaryOccupation],
		T.[BeneficiaryPhoneNumber],
		T.[BeneficiaryNote],
		T.[BeneficiarySSNumber],
		T.[BeneficiaryState],
		T.[BeneficiaryZipcode],
		T.[CustomerAddress],
		isnull(T.[CustomerBornDate], N.BornDate) AS CustomerBornDate,
		T.[CustomerCelullarNumber],
		T.[CustomerCity],
		T.[CustomerCountry],
		T.[CustomerExpirationIdentification],
		T.[CustomerFirstLastName],
		T.[CustomerSecondLastName],
		T.[CustomerName],
		T.[CustomerIdAgentCreatedBy],
		Q.[AgentCode]+' '+Q.[AgentName] [CustomerAgentCreatedBy],
		ISNULL(T.[CustomerIdCarrier],0) [CustomerIdCarrier],
		ISNULL(M.[Name],'') [CarrierName],
		ISNULL(T.[CustomerIdCustomerIdentificationType],0) [CustomerIdCustomerIdentificationType],
		ISNULL(P.[Name],'') [CustomerIdentificationName],
		T.[CustomerIdentificationNumber],
		T.CustomerIdOccupation,
		T.CustomerIdSubOccupation,
		T.CustomerSubOccupationOther,
		--T.[CustomerOccupation]
		/*S44:REQ. MA.025*/
		CASE 
		  WHEN T.[CustomerOccupation] IN ('--OTHER--', '--OTRA--') 
			 THEN (REPLACE(T.[CustomerOccupation],'-','') + ' ' + T.CustomerOccupationDetail ) 
			 ELSE T.[CustomerOccupation] END 
		  AS [CustomerOccupation], 

		T.[CustomerPhoneNumber], 
		T.[CustomerSSNumber],
		T.[CustomerState],
		T.[CustomerZipcode],
		N.[PhysicalIdCopy],
		A.[AgentCode],
		A.[AgentName],
		T.[BeneficiaryZipcode],
		T.[ReviewGateway],
		T.[ReviewReturned],
		T.[ReviewRejected],
		NULL [IdDocumentTransfertStatus],
		ISNULL(O.[IdOnWhoseBehalf],0) [OWBIdOnWhoseBehalf],
		ISNULL(O.[Name],'') [OWBName],
		ISNULL(O.[FirstLastName],'') [OWBFirstLastName],
		ISNULL(O.[SecondLastName],'') [OWBSecondLastName],
		ISNULL(O.[Address],'') [OWBAddress],
		ISNULL(O.[City],'') [OWBCity],
		ISNULL(O.[State],'') [OWBState],
		ISNULL(O.[Country],'') [OWBCountry],
		ISNULL(O.[Zipcode],'') [OWBZipcode],
		ISNULL(O.[PhoneNumber],'') [OWBPhoneNumber],
		ISNULL(O.[CelullarNumber],'') [OWBCelullarNumber],
		ISNULL(O.[SSNumber],'') [OWBSSNumber],
		ISNULL(O.[BornDate],'') [OWBBornDate],
		ISNULL(O.[Occupation],'') [OWBOccupation], 
		ISNULL(O.[PhysicalIdCopy],'') [OWBPhysicalIdCopy],
		ISNULL(O.[IdCustomerIdentificationType],0) [OWBIdCustomerIdentificationType],
		ISNULL(O.[IdentificationNumber],'') [OWBIdentificationNumber],
		ISNULL(O.[ExpirationIdentification],'') [OWBExpirationIdentification],
		ISNULL(O.[Purpose],'') [OWBPurpose],
		ISNULL(O.[Relationship],'') [OWBRelationship],
		ISNULL(O.[MoneySource],'') [OWBMoneySource],
		ISNULL(R.[AgentCode]+' '+R.[AgentName],'') [OWBAgentCreatedBy],
		ISNULL(S.[UserName],'') [EnterByUserName],
		[IdBeneficiaryIdentificationType],
		[BeneficiaryIdentificationNumber],  
		CASE
			WHEN (SELECT TOP 1 1 FROM [dbo].[AgentUser] WITH (NOLOCK) WHERE [IdUser] = T.[EnterByIdUser]) = 1
				THEN 1
			ELSE
				0
		END AS [IsMonoAgent],
		ISNULL(DLC.[IdDenyListCustomer], 0) [IdDenyListCustomer],
		DLC.[NoteInToList] [NoteIntoListCustomer],
		DLC.[NoteOutFromList] [NoteOutFromListCustomer],
		DLC.[IdGenericStatus] [IdDenyListStatusCustomer],
		ISNULL(DLB.[IdDenyListBeneficiary], 0) [IdDenyListBeneficiary],
		DLB.[NoteInToList] [NoteIntoListBeneficiary],
		DLB.[NoteOutFromList] [NoteOutFromListBeneficiary],
		DLB.[IdGenericStatus] [IdDenyListStatusBeneficiary],
		T.[CustomerIdentificationIdCountry] [CustomerIdentificationIdCountry],
		T.[CustomerIdentificationIdState] [CustomerIdentificationIdState],
		co.[CountryName] [CustomerIdentificationCountryName]
		,ISNULL((SELECT TOP 1 CSAR.[StatusSAR] FROM [dbo].[StatusCustomerSAR] CSAR WITH (NOLOCK) WHERE CSAR.[IdCustomer] = T.[IdCustomer] ORDER BY CSAR.[DataLastChange] DESC),0) [CustomerStatusSAR]
		,ISNULL((SELECT TOP 1 BSAR.[StatusSAR] FROM [dbo].[StatusBeneficiarySAR] BSAR WITH (NOLOCK) WHERE BSAR.[IdBeneficiary] = T.[IdBeneficiary] ORDER BY BSAR.[DataLastChange] DESC),0) [BeneficiaryStatusSAR]
		,0 [HasComplianceFormat]
		, T.[CustomerIdCountryOfBirth]
		, T.[BeneficiaryIdCountryOfBirth]
	From [dbo].[TransferClosed] T WITH (NOLOCK)
	    INNER JOIN [dbo].[Agent] A WITH (NOLOCK) ON (A.[IdAgent]=T.[IdAgent])
	    INNER JOIN [dbo].[AgentPaymentSchema] B WITH (NOLOCK) ON A.[IdAgentPaymentSchema]=B.[IdAgentPaymentSchema]
	    INNER JOIN [dbo].[Users] K WITH (NOLOCK) ON K.[IdUser]=T.[IdSeller]
	    LEFT JOIN [dbo].[Carriers] M WITH (NOLOCK) ON M.[IdCarrier]=T.[CustomerIdCarrier]
	    INNER JOIN [dbo].[Customer] N WITH (NOLOCK) ON N.[IdCustomer]=T.[IdCustomer]
	    LEFT JOIN [dbo].[OnWhoseBehalf] O WITH (NOLOCK) ON T.[IdOnWhoseBehalf]=O.[IdOnWhoseBehalf]
	    LEFT JOIN [dbo].[CustomerIdentificationType] P WITH (NOLOCK) ON P.[IdCustomerIdentificationType]=T.[CustomerIdCustomerIdentificationType] 
	    INNER JOIN [dbo].[Agent] Q WITH (NOLOCK) ON Q.[IdAgent]=N.[IdAgentCreatedBy]
	    LEFT JOIN [dbo].[Agent] R WITH (NOLOCK) ON R.[IdAgent]=O.[IdAgentCreatedBy]
	    LEFT JOIN [dbo].[Users] S WITH (NOLOCK) ON S.[IdUser]=T.[EnterByIdUser]
	    LEFT JOIN [dbo].[DenyListCustomer] DLC WITH (NOLOCK) ON T.[IdCustomer] = DLC.[IdCustomer]
	    LEFT JOIN [dbo].[DenyListBeneficiary] DLB (NOLOCK) ON T.[IdBeneficiary] = DLB.[IdBeneficiary]
	    LEFT JOIN [dbo].[Country] CO WITH (NOLOCK) ON T.[CustomerIdentificationIdCountry] = CO.[IdCountry]
	    LEFT JOIN (
		    SELECT
			    BR.[IdTransfer]
		    FROM [dbo].[BrokenRulesByTransfer] BR (NOLOCK)
		    JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
		    WHERE LTRIM(ISNULL(CF.[FileOfName],'')) != ''
		    GROUP BY BR.[IdTransfer]
		    ) BRT ON T.[IdTransferClosed] = BRT.[IdTransfer]
	 WHERE T.[IdTransferClosed]=@IdTransfer;
 
END

--Get xml representation of transfer's details 
--Select @TransferDetail= [dbo].[fun_GetTransferDetailsXml] (@IdTransfer)
 
DECLARE @BrokenRules TABLE ( 
	[Action] NVARCHAR(MAX),
	[MessageInEnglish] NVARCHAR(MAX), 
	[MessageInSpanish] NVARCHAR(MAX),
	[RuleNameKYC] NVARCHAR(MAX),
	RuleDetail NVARCHAR(MAX)
) 
 
INSERT INTO @BrokenRules ([Action], [MessageInEnglish], [MessageInSpanish], [RuleNameKYC], [RuleDetail])
	SELECT
		KYCA.[Action]
		,BR.[MessageInEnglish]
		,BR.[MessageInSpanish]
		,ISNULL(CASE WHEN KYCR.[RuleName] <> BR.[RuleName] THEN '*' + KYCR.[RuleName] ELSE KYCR.[RuleName] END , ISNULL(BR.[RuleName],''))AS RuleNameKYC
		,ISNULL(KYCAC.Display -- IF
			+ ', ' + ISNULL(A.[AgentCode] + ' ' + A.[AgentName],'ALL') -- AGENT
			+ ', ' + ISNULL(G.[GatewayName],'ALL') -- GATEWAY
			+ ', ' + ISNULL(C.[CountryName],'ALL') -- COUNTRY
			+ ', ' + ISNULL(PT.[PaymentName],'ALL') -- PAYMENT TYPE
			+ ', ' + ISNULL(P.[PayerName],'ALL') -- PAYER
			,'')
	FROM [dbo].[BrokenRulesByTransfer] BR (NOLOCK)
	    JOIN [dbo].[KYCAction] KYCA (NOLOCK) ON BR.[IdKYCAction]=KYCA.[IdKYCAction]
	    LEFT JOIN [dbo].[KYCRule] KYCR (NOLOCK) ON BR.[IdRule] = KYCR.[IdRule]
	    LEFT JOIN [dbo].[KYCActor] KYCAC (NOLOCK) ON KYCR.[Actor] = KYCAC.[Name]
	    LEFT JOIN [dbo].[Agent] A (NOLOCK) ON KYCR.[IdAgent] = A.[IdAgent]
	    LEFT JOIN [dbo].[Payer] P (NOLOCK) ON KYCR.[IdPayer] = P.[IdPayer]
	    LEFT JOIN [dbo].[Country] C (NOLOCK) ON KYCR.[IdCountry] = C.[IdCountry]
	    LEFT JOIN [dbo].[PaymentType] PT (NOLOCK) ON KYCR.IdPaymentType = PT.IdPaymentType
	    LEFT JOIN [dbo].[Gateway] G (NOLOCK) ON KYCR.IdGateway = G.IdGateway
	WHERE BR.[IdTransfer]=@IdTransfer
	   ORDER BY [IdBrokenRulesByTransfer];
 
IF EXISTS (SELECT 1 FROM @BrokenRules)
	SET @BrokenRule=ISNULL((SELECT * FROM @BrokenRules FOR XML AUTO, ELEMENTS, ROOT('Rule')),'<Rule></Rule>');
ELSE
	SET @BrokenRule='<Rule></Rule>';



