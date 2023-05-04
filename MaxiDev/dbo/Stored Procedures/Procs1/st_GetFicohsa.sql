CREATE PROCEDURE [dbo].[st_GetFicohsa]
AS
BEGIN

	DECLARE @IdGateWay		INT,
			@MinutsToWait	INT,
			@NextStatus		INT
	
	SELECT 
		@IdGateWay = g.IdGateway 
	FROM Gateway g WHERE g.Code = 'FICOHSA'

	SELECT 
		@MinutsToWait = Convert(INT, Value) 
	FROM GlobalAttributes 
	WHERE Name='TimeFromReadyToAttemp'

	SET @NextStatus = 21


	---------

	SELECT 
		IdTransfer 
	INTO #Temp 
	FROM Transfer t 
	WHERE 
		DATEDIFF(MINUTE, DateOfTransfer, GETDATE()) > @MinutsToWait 
		AND IdGateway = @IdGateWay
		AND IdStatus = 20

	UPDATE Transfer SET
		IdStatus = @NextStatus,
		DateStatusChange = GETDATE()
	WHERE IdTransfer IN (SELECT IdTransfer FROM #Temp)

	INSERT INTO TransferDetail (IdStatus,IdTransfer,DateOfMovement)
	SELECT
		@NextStatus,
		IdTransfer,
		GETDATE() 
	FROM #Temp

	---------

	SELECT DISTINCT
		t.IdPaymentType							PaymentType,
		-- Remesa
		t.ClaimCode								Remittance_Id,
		t.DateOfTransfer						Remittance_Date,
		CASE 
			WHEN ISNULL(cec.UseRefExrate, 0) = 0 THEN t.AmountInMN							
			ELSE round(dbo.funGetConvertAmount(t.AmountInMN, T.ReferenceExRate) * t.ReferenceExRate,4)
		END										Remittance_Amount,
		-- Siempre 'HNL'
		c.CurrencyCode							Remittance_Currency,

		-- Temps
		GETDATE()								Remittance_DateOfIssue,

		CASE 
			WHEN ISNULL(cec.UseRefExrate, 0) = 0 THEN t.ExRate
			ELSE t.ReferenceExRate
		END										Remittance_ExchangeRate,
		CASE
			WHEN ISNULL(cec.UseRefExrate, 0) = 0 THEN t.AmountInDollars
			ELSE dbo.funGetConvertAmount(T.AmountInMN, T.ReferenceExRate)
		END										Remittance_RefAmount,
		'USD'									Remittance_RefCurrency,
		t.ReferenceExRate						Remittance_RefExchangeRate,
		t.IdTransfer							Remittance_Sequence,

		-- Beneficiario
		t.IdBeneficiary							Beneficiary_Id,
		CONCAT(t.BeneficiaryName, 
			' ', t.BeneficiaryFirstLastName, 
			' ', t.BeneficiarySecondLastName)	Beneficiary_Name,
		-- # Todo: Pendiente Definir
		''										Beneficiary_IdType,

		-- # Catalogos Demograficos

		SUBSTRING(bct.CityName, 1, 25)					Beneficiary_City,
		ISNULL(bState.Code, bst.StateCodeISO3166)		Beneficiary_State,
		ISNULL(bCountry.Code, bctr.CountryCodeISO3166)	Beneficiary_Country,
						
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(t.BeneficiaryPhoneNumber, ')', ''), 
					'(', ''
				), '-', ''
			), ' ', ''
		)										Beneficiary_PhoneNumber,
		t.BeneficiaryOccupation					Beneficiary_Occupation,
		t.BeneficiaryBornDate					Beneficiary_DOF,
		t.BeneficiaryAddress					Beneficiary_Address,
		
		-- Remitente
		t.IdCustomer							Remitter_Id,
		CONCAT(t.CustomerName, 
			' ', t.CustomerFirstLastName, 
			' ', t.CustomerSecondLastName)		Remitter_Name,

		-- # Catalogos Demograficos

		CASE WHEN t.IdPaymentType = 2 
			THEN ISNULL(cState.Code + '.0000', 'US.00.0000')
			ELSE SUBSTRING(t.CustomerCity, 1, 25)
		END												Remitter_City,
		ISNULL(cState.Code, cst.StateCodeISO3166)		Remitter_State,
		ISNULL(cCountry.Code, cctr.CountryCodeISO3166)	Remitter_Country,
		
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(t.CustomerPhoneNumber, ')', ''), 
					'(', ''
				), '-', ''
			), ' ', ''
		)										Remitter_PhoneNumber,
		t.CustomerBornDate						Remitter_DOF,
		t.CustomerAddress						Remitter_Address,
		t.DepositAccountNumber					Remitter_DepositAccountNumber
	FROM Transfer t 
		JOIN CountryCurrency cc ON cc.IdCountryCurrency = t.IdCountryCurrency
		JOIN Currency c ON c.IdCurrency = cc.IdCurrency
		
		JOIN Branch br WITH(NOLOCK) ON br.IdBranch = t.IdBranch
		JOIN City bct WITH(NOLOCK) ON bct.IdCity = br.IdCity

		JOIN State bst WITH(NOLOCK) ON bst.IdState = bct.IdState
		LEFT JOIN GatewayCatalog bState WITH(NOLOCK) ON bState.IdReference = bst.IdState 
            AND bState.IdGatewayCatalogType = 2 AND bState.IdPaymentType = t.IdPaymentType
		
        JOIN Country bctr WITH(NOLOCK) ON bctr.IdCountry = bst.IdCountry
        LEFT JOIN GatewayCatalog bCountry WITH(NOLOCK) ON bCountry.IdReference = bctr.IdCountry
            AND bCountry.IdGatewayCatalogType = 1 AND bCountry.IdPaymentType = t.IdPaymentType

		LEFT JOIN CountryExrateConfig cec WITH(NOLOCK) on cec.IdCountry = cc.IdCountry and cec.IdGenericStatus = 1 and cec.IdGateway = t.IdGateway

		-- Datos demofraficos cliente / agencia
		
		LEFT JOIN State cst WITH(NOLOCK) ON cst.StateCode = t.CustomerState-- AND cst.IdCountry = 18
		LEFT JOIN GatewayCatalog cState WITH(NOLOCK) ON cState.IdReference = cst.IdState
            AND cState.IdGatewayCatalogType = 2 AND cState.IdPaymentType = t.IdPaymentType

        LEFT JOIN Country cctr WITH(NOLOCK) ON cctr.CountryCode = t.CustomerCountry
        LEFT JOIN GatewayCatalog cCountry WITH(NOLOCK) ON cCountry.IdReference = cctr.IdCountry
            AND cCountry.IdGatewayCatalogType = 1 AND cCountry.IdPaymentType = t.IdPaymentType

		LEFT JOIN City ccty WITH(NOLOCK) ON ccty.CityName = t.CustomerCity
        LEFT JOIN GatewayCatalog cCity WITH(NOLOCK) ON cCountry.IdReference = ccty.IdCity
            AND cCountry.IdGatewayCatalogType = 3 AND cCountry.IdPaymentType = t.IdPaymentType

	WHERE 
		t.IdGateway = @IdGateWay
		AND t.IdStatus = 21
END
