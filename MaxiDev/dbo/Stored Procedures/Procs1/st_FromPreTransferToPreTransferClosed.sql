
CREATE   PROCEDURE [dbo].[st_FromPreTransferToPreTransferClosed]
as
/********************************************************************
<Author>Maprado</Author>
<app>MaxiAgent</app>
<Description></Description>

<ChangeLog>
<log Date="21/04/2023" Author="maprado"> Creation SP </log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON

BEGIN TRAN
    BEGIN TRY

	CREATE TABLE #tmpPreTransferToBeClosed(
		[IdPreTransfer] INT,
		[IdOnWhoseBehalf] INT
	);
	
	CREATE INDEX IX_tmpPreTransferToBeClosed_IdTransfer ON #tmpPreTransferToBeClosed (IdPreTransfer)

    INSERT INTO #tmpPreTransferToBeClosed
    SELECT IdPreTransfer,IdOnWhoseBehalf FROM [PreTransfer] WITH (NOLOCK) WHERE IdTransfer IS NOT NULL ORDER BY IdTransfer ASC;



    DECLARE @Contador INT
    SELECT @Contador = COUNT(1) FROM #tmpPreTransferToBeClosed;


    -------------------------------------- Move Transfer -------------------------------------------------------
	INSERT INTO [dbo].[PreTransferClosed]
	(
		[IdPreTransferClosed]
		,[IdCustomer]
        ,[IdBeneficiary]
        ,[IdPaymentType]
        ,[IdBranch]
        ,[IdPayer]
        ,[IdGateway]
        ,[GatewayBranchCode]
        ,[IdAgentPaymentSchema]
        ,[IdAgent]
        ,[IdAgentSchema]
        ,[IdCountryCurrency]
        ,[AmountInDollars]
        ,[Fee]
        ,[AgentCommission]
        ,[CorporateCommission]
        ,[DateOfPreTransfer]
        ,[ExRate]
        ,[ReferenceExRate]
        ,[AmountInMN]
        ,[Folio]
        ,[DepositAccountNumber]
        ,[DateOfLastChange]
        ,[EnterByIdUser]
        ,[TotalAmountToCorporate]
        ,[BeneficiaryName]
        ,[BeneficiaryFirstLastName]
        ,[BeneficiarySecondLastName]
        ,[BeneficiaryAddress]
        ,[BeneficiaryCity]
        ,[BeneficiaryState]
        ,[BeneficiaryCountry]
        ,[BeneficiaryZipcode]
        ,[BeneficiaryPhoneNumber]
        ,[BeneficiaryCelularNumber]
        ,[BeneficiarySSNumber]
        ,[BeneficiaryBornDate]
        ,[BeneficiaryOccupation]
        ,[BeneficiaryNote]
        ,[CustomerName]
        ,[CustomerIdAgentCreatedBy]
        ,[CustomerIdCustomerIdentificationType]
        ,[CustomerFirstLastName]
        ,[CustomerSecondLastName]
        ,[CustomerAddress]
        ,[CustomerCity]
        ,[CustomerState]
        ,[CustomerCountry]
        ,[CustomerZipcode]
        ,[CustomerPhoneNumber]
        ,[CustomerCelullarNumber]
        ,[CustomerSSNumber]
        ,[CustomerBornDate]
        ,[CustomerOccupation]
        ,[CustomerIdentificationNumber]
        ,[CustomerExpirationIdentification]
        ,[IdOnWhoseBehalf]
        ,[Purpose]
        ,[Relationship]
        ,[MoneySource]
        ,[AgentCommissionExtra]
        ,[AgentCommissionOriginal]
        ,[ModifierCommissionSlider]
        ,[ModifierExchangeRateSlider]
        ,[CustomerIdCarrier]
        ,[IdSeller]
        ,[OriginExRate]
        ,[OriginAmountInMN]
        ,[NoteAdditional]
        ,[CustomerIdentificationIdCountry]
        ,[CustomerIdentificationIdState]
        ,[BrokenRules]
        ,[IdCity]
        ,[StateTax]
        ,[OWBRuleType]
        ,[TransferAmount]
        ,[IsValid]
        ,[IdTransferResend]
        ,[Status]
        ,[IdTransfer]
        ,[IdBeneficiaryIdentificationType]
        ,[BeneficiaryIdentificationNumber]
        ,[CustomerIdCountryOfBirth]
        ,[BeneficiaryIdCountryOfBirth]
        ,[AccountTypeId]
        ,[CustomerOccupationDetail]
        ,[TransferIdCity]
        ,[BeneficiaryIdCarrier]
        ,[CustomerIdOccupation]
        ,[CustomerIdSubOccupation]
        ,[CustomerSubOccupationOther]
        ,[CustomerOFACMatch]
        ,[BeneficiaryOFACMatch]
        ,[OnlineTransfer]
        ,[SendMoneyAlertInvitation]
        ,[IdTransferOriginal]
        ,[IsModify]
        ,[IdPaymentMethod]
        ,[Discount]
        ,[DateOfPreTransferUTC]
        ,[OperationFee]
        ,[IdDialingCodePhoneNumber]
        ,[IsValidCustomerPhoneNumber]
        ,[IdDialingCodeBeneficiaryPhoneNumber]
	)
	SELECT PT.[IdPreTransfer]
      ,[IdCustomer]
      ,[IdBeneficiary]
      ,[IdPaymentType]
      ,[IdBranch]
      ,[IdPayer]
      ,[IdGateway]
      ,[GatewayBranchCode]
      ,[IdAgentPaymentSchema]
      ,[IdAgent]
      ,[IdAgentSchema]
      ,[IdCountryCurrency]
      ,[AmountInDollars]
      ,[Fee]
      ,[AgentCommission]
      ,[CorporateCommission]
      ,[DateOfPreTransfer]
      ,[ExRate]
      ,[ReferenceExRate]
      ,[AmountInMN]
      ,[Folio]
      ,[DepositAccountNumber]
      ,[DateOfLastChange]
      ,[EnterByIdUser]
      ,[TotalAmountToCorporate]
      ,[BeneficiaryName]
      ,[BeneficiaryFirstLastName]
      ,[BeneficiarySecondLastName]
      ,[BeneficiaryAddress]
      ,[BeneficiaryCity]
      ,[BeneficiaryState]
      ,[BeneficiaryCountry]
      ,[BeneficiaryZipcode]
      ,[BeneficiaryPhoneNumber]
      ,[BeneficiaryCelularNumber]
      ,[BeneficiarySSNumber]
      ,[BeneficiaryBornDate]
      ,[BeneficiaryOccupation]
      ,[BeneficiaryNote]
      ,[CustomerName]
      ,[CustomerIdAgentCreatedBy]
      ,[CustomerIdCustomerIdentificationType]
      ,[CustomerFirstLastName]
      ,[CustomerSecondLastName]
      ,[CustomerAddress]
      ,[CustomerCity]
      ,[CustomerState]
      ,[CustomerCountry]
      ,[CustomerZipcode]
      ,[CustomerPhoneNumber]
      ,[CustomerCelullarNumber]
      ,[CustomerSSNumber]
      ,[CustomerBornDate]
      ,[CustomerOccupation]
      ,[CustomerIdentificationNumber]
      ,[CustomerExpirationIdentification]
      ,PT.[IdOnWhoseBehalf]
      ,[Purpose]
      ,[Relationship]
      ,[MoneySource]
      ,[AgentCommissionExtra]
      ,[AgentCommissionOriginal]
      ,[ModifierCommissionSlider]
      ,[ModifierExchangeRateSlider]
      ,[CustomerIdCarrier]
      ,[IdSeller]
      ,[OriginExRate]
      ,[OriginAmountInMN]
      ,[NoteAdditional]
      ,[CustomerIdentificationIdCountry]
      ,[CustomerIdentificationIdState]
      ,[BrokenRules]
      ,[IdCity]
      ,[StateTax]
      ,[OWBRuleType]
      ,[TransferAmount]
      ,[IsValid]
      ,[IdTransferResend]
      ,[Status]
      ,[IdTransfer]
      ,[IdBeneficiaryIdentificationType]
      ,[BeneficiaryIdentificationNumber]
      ,[CustomerIdCountryOfBirth]
      ,[BeneficiaryIdCountryOfBirth]
      ,[AccountTypeId]
      ,[CustomerOccupationDetail]
      ,[TransferIdCity]
      ,[BeneficiaryIdCarrier]
      ,[CustomerIdOccupation]
      ,[CustomerIdSubOccupation]
      ,[CustomerSubOccupationOther]
      ,[CustomerOFACMatch]
      ,[BeneficiaryOFACMatch]
      ,[OnlineTransfer]
      ,[SendMoneyAlertInvitation]
      ,[IdTransferOriginal]
      ,[IsModify]
      ,[IdPaymentMethod]
      ,[Discount]
      ,[DateOfPreTransferUTC]
      ,[OperationFee]
      ,[IsValidCustomerPhoneNumber]
      ,[IdDialingCodePhoneNumber]
      ,[IdDialingCodeBeneficiaryPhoneNumber]
	FROM [dbo].[PreTransfer] PT
	INNER JOIN #tmpPreTransferToBeClosed PTC ON (PT.IdPreTransfer = PTC.IdPreTransfer);

    IF @@ROWCOUNT <> @Contador
		SELECT 5/0
    
    PRINT ('  tabla PreTransferClosed insertada ' + CONVERT(VARCHAR,GETDATE()));

    ------------------------------ Inicia Borrado de tablas ----------------------------
             
    DELETE PreTransfer WHERE IdPreTransfer IN ( SELECT IdPreTransfer FROM #tmpPreTransferToBeClosed WITH (NOLOCK) )
    PRINT ('  borrado pretransfer  ' + CONVERT(VARCHAR,GETDATE()))    
    
             
    DROP TABLE #tmpPreTransferToBeClosed
    PRINT ('  Drop  #tmpPreTransferToBeClosed ' + CONVERT(VARCHAR,GETDATE()))    
    
    COMMIT    
    
    PRINT ('  Commit ' + CONVERT(VARCHAR,GETDATE()))    
    
    
END TRY   
BEGIN CATCH   
    
    DECLARE @ErrorMessage NVARCHAR(MAX);
    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorMessage;

    ROLLBACK;    
  
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_FromPreTransferToPreTransferClosed',GETDATE(),@ErrorMessage)

    PRINT ('  Rollback ' + CONVERT(VARCHAR,GETDATE()))    
    
END CATCH
