
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-05-16
-- Description:	Returns transfer for Transfer To Mobile gateway
-- =============================================
CREATE PROCEDURE [dbo].[st_GetTransferToMobile]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add ; insert/update</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

    -- Insert statements for procedure here
	
	--- Get Minutes to wait to be send to service ---
	DECLARE @MinutsToWait INT, @GatewayId INT = 31 /*TransferToMobile*/
	SELECT @MinutsToWait = CONVERT(INT, [Value]) FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'TimeFromReadyToAttemp'
	--Set @MinutsToWait=0

	--DROP TABLE #temp
	---  Update transfer to Attempt -----------------
	SELECT [IdTransfer] INTO #temp FROM [dbo].[Transfer] WITH (NOLOCK) WHERE DATEDIFF(MINUTE, [DateOfTransfer], GETDATE())>@MinutsToWait AND [IdGateway]=@GatewayId AND [IdStatus]=20
	UPDATE [dbo].[Transfer] SET [IdStatus]=21, [DateStatusChange]=GETDATE() WHERE [IdTransfer] IN (SELECT [IdTransfer] FROM #temp);
	--------- Tranfer log ---------------------------                              
	INSERT INTO [dbo].[TransferDetail] ([IdStatus],[IdTransfer],[DateOfMovement])
	SELECT 21, [IdTransfer], GETDATE() FROM #temp;

	-----------------------------------------------------------------------

	SELECT

		-- Transfer
		'SOURCE_AMOUNT' [CalculationMode]
		, ROUND(T.[AmountInDollars],2) [Amount]
		, C.[CurrencyCode] [AmountCurrencyCode] -- Always should be USD
		, ROUND(T.[AmountInDollars] + T.[Fee],2) [CustomerAmount] -- Optional
		, C.[CurrencyCode] [CustomerAmountCurrencyCode] -- Optional, Always should be USD
		, ROUND(T.[AmountInDollars] * T.[ExRate],2) [AmountToReceive] -- Mandatory if calculation mode set to RECEIVE_AMOUNT
		, C.[CurrencyCode] [AmountToReceiveCurrencyCode] -- Mandatory if calculation mode set to RECEIVE_AMOUNT
		, NULL [SourceBranchCode]
		, 'MSISDN' [RoutingType]
		, '+' + T.[DepositAccountNumber] [RoutingParam]
		, NULL [RoutingParam2] -- Optional
		, 'CASH' [OriginType]
		, NULL [OriginParam] -- Optional
		, 'USA' [SourceCountryCode]
		, T.[BeneficiaryCity] [DestinationCity] -- Optional
		, C2.[CountryCode] [DestinationCountryCode]
		, 'MBP' [PaymentMode] -- Mobile Payment (Mobile Wallet)
		, T.[ClaimCode] [ForeignTransactionCode]
		, ROUND(T.[Fee],2) [CustomerFee] -- Optional
		, ROUND(T.[ExRate],2) [RetailExchangeRate] -- Optional

		-- Sender
		, NULL [SenderCode] -- Optional
		, T.[CustomerName] [SenderFirstName]
		, NULL [SenderMiddleName] -- Optional
		, T.[CustomerFirstLastName] [SenderLastName]
		, T.[CustomerSecondLastName] [SenderLastName2] -- Optional

		--, T.[CustomerBornDate] AS [SenderDateOfBirth] -- Optional
		, ISNULL(T.[CustomerBornDate], DATEADD(year,-18, dbo.RemoveTimeFromDatetime(GETDATE()))) AS [SenderDateOfBirth] -- Optional -> 2016-Ago-31
		
		, T.[CustomerAddress] [SenderAddress]
		, T.[CustomerZipCode] [SenderPostalCode] -- Optional
		, T.[CustomerCity] [SenderCity]
		, T.[CustomerCountry] [SenderCountryCode]
		, NULL [SenderIdDocumentCountryCode] -- Optional
		, NULL [SenderIdDocumentTypeCode] -- Not optional if ID Document Number element has a value ///////////////// ************* ALTER TABLE [dbo].[CustomerIdentificationType]
		, NULL /*T.[CustomerIdentificationNumber]*/ [SenderIdDocumentNumber] -- Optional
		, NULL [SenderIdDocumentDeliveryDate] -- Optional
		, NULL /*T.[CustomerExpirationIdentification]*/ [SenderIdDocumentExpirationDate] -- Optional
		, T.[CustomerPhoneNumber] [SenderPhoneNumber1] -- Optional
		, NULL [SenderPhoneNumber2] -- Optional
		, NULL [SenderEmail] -- Optional
		, NULL [SenderGender] -- Optional
		, SUBSTRING(T.[CustomerOccupation],1,50) [SenderOccupation] -- Optional, Free text string with a maximum of 50 characters length.
		, 'NOT_SET' [SenderBeneficiaryRelationship] -- Optional
		, 'NOT_SET' [SenderSourceOfFunds] -- Optional

		-- Beneficiary
		, NULL [BeneficiaryCode] -- Optional
		, T.[BeneficiaryName] [BeneficiaryFirstName]
		, NULL [BeneficiaryMiddleName] -- Optional
		, T.[BeneficiaryFirstLastName] [BeneficiaryLastName]
		, T.[BeneficiarySecondLastName] [BeneficiaryLastName2] -- Optional

		--, T.[BeneficiaryBornDate] [BeneficiaryDateOfBirth] -- Optional
		, ISNULL(T.[BeneficiaryBornDate], DATEADD(year,-18, dbo.RemoveTimeFromDatetime(GETDATE()))) AS [BeneficiaryDateOfBirth] -- Optional -> 2016-Ago-31

		, T.[BeneficiaryAddress] [BeneficiaryAddress]
		, T.[BeneficiaryZipCode] [BeneficiaryZipCode] -- Optional
		, T.[BeneficiaryCity] [BeneficiaryCity]
		, C2.[CountryCode] [BeneficiaryCountryCode]
		, NULL [BeneficiaryIdDocumentCountryCode] -- Optional
		, NULL [BeneficiaryIdDocumentTypeCode] -- Optional
		, NULL [BeneficiaryIdDocumentNumber] -- Optional
		, NULL [BeneficiaryIdDocumentDeliveryDate] -- Optional
		, NULL [BeneficiaryIdDocumentExpirationDate] -- Optional
		, T.[BeneficiaryPhoneNumber] [BeneficiaryPhoneNumber1] -- Optional
		, NULL [BeneficiaryPhoneNumber2] -- Optional
		, NULL [BeneficiaryEmail] -- Optional
		, NULL [BeneficiaryGender] -- Optional
		, SUBSTRING(T.[BeneficiaryOccupation],1,50) [BeneficiaryOccupation] -- Optional
		, NULL [BeneficiaryBankAccount] --  Only applies to "BA" (Bank Account) money transfers
		, NULL [BeneficiaryBankAgencyName] --  Only applies to "BA" (Bank Account) money transfers
		, NULL [BeneficiaryPrepaidCardNumber] -- Not optional for payment mode / service "PPR"
		, NULL [BeneficiarySSNumber] -- Optional
		, NULL [BeneficiarySSCode] -- Optional
		, NULL [BeneficiarySSLoanNumber] -- Optional
		, NULL [BeneficiarySSLStartMonth] -- Optional
		, NULL [BeneficiarySSLoanEndMonth] -- Optional

		-- Beneficiary2
		-- Beneficiary3

		-- AdditionalData
		, 'Maxi Money Services le agradece su preferencia.' [Notes]
		, NULL [OperatorName] -- Optional
		, NULL [OperatorCode] -- Optional
		, NULL [PinCode] -- Optional
		, 'OTHER' [PurposeOfRemittance]
		, 'NOT_SET' [MultipleBeneficiaryOption] -- Optional

	FROM [dbo].[Transfer] T WITH (NOLOCK)
	JOIN [dbo].[Payer] P WITH (NOLOCK) ON T.[IdPayer] = P.[IdPayer]
	LEFT JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON CC.[idcountrycurrency] = T.[IdCountryCurrency]
	LEFT JOIN [dbo].[Currency] C WITH (NOLOCK) ON CC.[IdCurrency] = C.[IdCurrency]
	LEFT JOIN [dbo].[Country] C2 WITH (NOLOCK) ON CC.[IdCountry] = C2.[IdCountry]
	WHERE [IdGateway] = @GatewayId AND [IdStatus] = 21

END
