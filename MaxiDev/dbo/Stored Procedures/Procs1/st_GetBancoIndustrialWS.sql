-- =============================================
-- Author:		Jorge Gomez
-- Create date: 27-09-2019
-- Description:	This stored is used in Banco Industrial Gateway
-- Proyecto:    M00072 - Banco Industrial Web Services
-- =============================================

CREATE PROCEDURE [dbo].[st_GetBancoIndustrialWS]
AS
	
	--- Get Minutes to wait to be send to service ---
	DECLARE @MinutsToWait INT
	SELECT @MinutsToWait = CONVERT(INT, [Value]) FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'TimeFromReadyToAttemp'
	--Set @MinutsToWait=0

	---  Update transfer to Attempt -----------------
	SELECT [IdTransfer] INTO #temp FROM [dbo].[Transfer] WITH (NOLOCK) WHERE DATEDIFF(MINUTE, [DateOfTransfer], GETDATE())>@MinutsToWait AND [IdGateway]=16 AND [IdStatus]=20
	UPDATE [dbo].[Transfer] SET [IdStatus]=21, [DateStatusChange]=GETDATE() WHERE [IdTransfer] IN (SELECT [IdTransfer] FROM #temp)
	--------- Tranfer log ---------------------------                              
	INSERT INTO [dbo].[TransferDetail] ([IdStatus],[IdTransfer],[DateOfMovement])
	SELECT 21, [IdTransfer], GETDATE() FROM #temp


	-----------------------------------------------------------------------

	SELECT      
		'01'																			[Origen], -- 01 Internet, 02 Teller, 03 Otros
		A.[ClaimCode]																	[NumeroDeRemesa],
		REPLACE(CONVERT(VARCHAR(10), [DateOfTransfer], 103),'/','')						[FechaEnvioRemesa],
		REPLACE(CONVERT(VARCHAR(8), [DateOfTransfer], 108),':','')						[HoraEnvioRemesa],
		CONVERT(NVARCHAR(MAX),ROUND([AmountInDollars],2))								[MontoEnDolares],
		CONVERT(NVARCHAR(MAX),ROUND([ExRate],2))										[TasaDeCambio],
		CONVERT(NVARCHAR(MAX),ROUND([AmountInMN],2))									[MontoEnQuetzales],
		LTRIM(RTRIM(A.[CustomerName] + ' ' + REPLACE(A.[CustomerFirstLastName],'.','') + ' ' + REPLACE(A.[CustomerSecondLastName],'.',''))) [NombreRemitente],
		A.[CustomerPhoneNumber]															[TelefonoRemitente],
		A.[CustomerAddress]																[DireccionRemitente],
		A.[CustomerCity]																[CiudadRemitente],
		--LEFT(a.customerstate+space(20), 20)											EstadoRemitente,
		--LEFT(a.customerzipcode+space(20), 20)											CodigoPostalRemitente,
		'USA'																			[PaisRemitente],
		LTRIM(RTRIM(A.[BeneficiaryName] + ' ' + REPLACE(A.[BeneficiaryFirstLastName],'.','') + ' ' + REPLACE(A.[BeneficiarySecondLastName],'.',''))) [NombreBeneficiario],
		A.[BeneficiaryPhoneNumber]														[TelefonoBeneficiario],
		A.[BeneficiaryAddress]															[DireccionBeneficiario],
		A.[BeneficiaryCity]																[CiudadBeneficiario],
		--LEFT(a.beneficiarystate+space(20), 20)										EstadoBeneficiario,
		--LEFT(a.beneficiaryzipcode+space(20), 20)										CodigoPostalBeneficiario,
		A.[BeneficiaryCountry]															[PaisBeneficiario],
		CASE [IdPaymentType]                                                          
			WHEN 1 THEN '0'
			WHEN 2 THEN '1'
		END																				[FormaDePago],
		[DepositAccountNumber]															[NumeroDeCuenta],
		--RIGHT('0001', 4)																CodigoBanco,
		--LEFT('BANCO INDUSTRIAL'+space(50), 50)										NombreBanco,
		CASE [AccountTypeId]                                                          
			WHEN 1 THEN '1'
			WHEN 2 THEN '2'
			ELSE '0'
		END																				[TipoDeCuenta],
		C.[CurrencyCode]																[CodigoMoneda]
	FROM [dbo].[Transfer] A WITH (NOLOCK)                             
	JOIN [dbo].[Payer] D WITH (NOLOCK) ON (A.[IdPayer] = D.[IdPayer])
	JOIN [dbo].[Branch] B WITH (NOLOCK) ON A.[IdBranch] = B.[IdBranch]
	LEFT JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON CC.[idcountrycurrency] = A.[IdCountryCurrency]
	LEFT JOIN [dbo].[Currency] C WITH (NOLOCK) ON C.[IdCurrency]= CC.[IdCurrency]
	WHERE [IdGateway] = 16 AND [IdStatus] = 21


