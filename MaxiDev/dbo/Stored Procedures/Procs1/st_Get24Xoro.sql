CREATE PROCEDURE [dbo].[st_Get24Xoro]
(
	@IdGateway				INT
)
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="24/02/2023" Author="adominguez" Name="#1">Se agrega cajas populares para 24xOro</log>
<log Date="24/02/2023" Author="adominguez" Name="#2">Se agrega cajas populares para 24xOro 2da parte</log>
*********************************************************************/
AS
BEGIN

	DECLARE @MinutsToWait	INT,
			@NextStatus		INT
	
	SELECT 
		@MinutsToWait = Convert(INT, Value) 
	FROM GlobalAttributes with(nolock)
	WHERE Name='TimeFromReadyToAttemp'

	SET @NextStatus = 21

	SELECT 
		IdTransfer 
	INTO #Temp 
	FROM Transfer t with(nolock)
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

	DECLARE @DepositConecta2 VARCHAR(200) = 'MXIDEPCONECTA2'

	SELECT
		t.IdTransfer,
		a.AgentCode,
		t.ClaimCode,
		b.code										BranchCode,
		CASE 
			WHEN t.IdPaymentType = 2 AND p.PayerCode NOT IN (@DepositConecta2) THEN 'V00000'
			ELSE p.PayerCode
		END											IdPP,
		'USD'										OriginCurrency,
		c.CurrencyCode								TargetCurrency,
		t.ExRate,
		t.AmountInMN,
		t.AmountInDollars,
		t.DateOfTransfer,
		CASE p.PayerCode
			WHEN 'V00001' THEN 1
			WHEN 'MXICASHAFIRME' THEN 3
			WHEN 'MXICASHCONECTA2' THEN 4
			WHEN @DepositConecta2 THEN 5
			/*Inicia #1*/
			When 'SCP2209' then 10
			When 'SCP2210' then 10
			When 'SCP2211' then 10
			When 'SCP2213' then 10
			When 'SCP2214' then 10
			When 'SCP2215' then 10
			When 'SCP2216' then 10
			When 'SCP2219' then 10
			When 'SCP2222' then 10
			When 'SCP2223' then 10
			When 'SCP2224' then 10
			When 'SCP2225' then 10
			When 'SCP2227' then 10
			When 'SCP2229' then 10
			When 'SCP2233' then 10
			When 'SCP2235' then 10
			When 'SCP2237' then 10
			When 'SCP2239' then 10
			When 'SCP2247' then 10
			When 'SCP2254' then 10
			When 'SCP2255' then 10
			When 'SCP2258' then 10
			When 'SCP2259' then 10
			When 'SCP2260' then 10
			When 'SCP2261' then 10
			When 'SCP2264' then 10
			When 'SCP2265' then 10
			When 'SCP2267' then 10
			When 'SCP2269' then 10
			When 'SCP2282' then 10
			When 'SCP2284' then 10
			When 'SCP2285' then 10
			When 'SCP2287' then 10
			When 'SCP2290' then 10
			When 'SCP2304' then 10
			When 'SCP2306' then 10
			When 'SCP2312' then 10
			When 'SCP2313' then 10
			When 'SCP2314' then 10
			When 'SCP2315' then 10
			When 'TGR2206' then 8
			/*Termina #1*/
			/*Inicia #2*/
			When 'SCP2316' then 10
			When 'SCP2317' then 10
			When 'SCP2318' then 10
			When 'SCP2232' then 10
			When 'SCP2256' then 10
			When 'SCP2218' then 10
			When 'SCP2212' then 10
			When 'SCP2221' then 10
			When 'SCP2244' then 10
			When 'SCP2243' then 10
			When 'SCP2319' then 10
			When 'SCP2234' then 10
			When 'SCP2238' then 10
			When 'SCP2253' then 10
			When 'SCP2309' then 10
			When 'SCP2320' then 10
			When 'SCP2245' then 10
			When 'SCP2275' then 10
			/*Termina #2*/
			ELSE 2
		END											PaymentType,
		''											ServiceType,
		CASE 
			WHEN t.IdPaymentType = 2 AND p.PayerCode = @DepositConecta2 THEN '062'
			WHEN t.IdPaymentType = 2 THEN p.PayerCode
			ELSE NULL
		END											Bank,
		t.DepositAccountNumber,
		CASE t.AccountTypeId
			WHEN 1 THEN 'C'
			WHEN 2 THEN 'A'
			ELSE 'C'
		END											AccountType,
		t.CustomerCountry							CustomerCountry,
		co.CountryCode								BeneficiaryCountry,

		-- Customer
		t.IdCustomer,
		t.CustomerName,
		t.CustomerFirstLastName,
		t.CustomerSecondLastName,
		t.CustomerCity,
		t.CustomerState,
		t.CustomerZipcode,
		t.CustomerAddress,
		dbo.fn_EspecialChrEKOFF(T.CustomerPhoneNumber)	CustomerPhoneNumber,
		t.CustomerIdentificationNumber,
		t.CustomerIdCustomerIdentificationType		CustomerIdentificationType,

		-- Beneficiary
		t.IdBeneficiary,
		t.BeneficiaryName,
		t.BeneficiaryFirstLastName,
		t.BeneficiarySecondLastName,
		ct.CityName									BeneficiaryCity,
		st.StateName								BeneficiaryState,
		t.BeneficiaryZipcode,
		case 
			when p.IdPayer in (7169,7170,7171,7172,7174,7176,7177,7178,7179,7180,7181,7182,7183,7184,7185,7186,7188,7189,7190,
					7191,7192,7193,7194,7195,7196,7197,7198,7199,7200,7201,7202,7203,7204,7205,7206,7207,7208,7209,7210,7211,7212) then ''
			else t.BeneficiaryIdentificationNumber
			End BeneficiaryIdentificationNumber,--#1
		case 
			when p.IdPayer in (7169,7170,7171,7172,7174,7176,7177,7178,7179,7180,7181,7182,7183,7184,7185,7186,7188,7189,7190,
					7191,7192,7193,7194,7195,7196,7197,7198,7199,7200,7201,7202,7203,7204,7205,7206,7207,7208,7209,7210,7211,7212) then ''
			else t.IdBeneficiaryIdentificationType
			End BeneficiaryIdentificationType,--#1
		t.BeneficiaryAddress,
		t.BeneficiaryPhoneNumber,
		dbo.fn_EspecialChrEKOFF(t.BeneficiaryCelularNumber)	BeneficiaryCelularNumber
	FROM Transfer t WITH(NOLOCK)
		-- Currency
		JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = t.IdCountryCurrency
		JOIN Currency c WITH(NOLOCK) ON c.IdCurrency = cc.IdCurrency

		-- Datos demograficos cliente
		LEFT JOIN Branch b WITH(NOLOCK) ON b.IdBranch = t.IdBranch
		LEFT JOIN City ct WITH(NOLOCK) ON ct.IdCity = b.IdCity
		LEFT JOIN State st WITH(NOLOCK) ON st.IdState = ct.IdState
		LEFT JOIN Country co WITH(NOLOCK) ON st.IdCountry = co.IdCountry

		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Payer p WITH(NOLOCK) ON p.IdPayer = t.IdPayer
	WHERE 
		t.IdGateway = @IdGateway 
		AND t.IdStatus = @NextStatus
END