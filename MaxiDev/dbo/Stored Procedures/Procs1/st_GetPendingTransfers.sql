CREATE PROCEDURE [dbo].[st_GetPendingTransfers]  --56
(
	@IdGateway			INT,
	@Limit				INT = NULL
)
AS 
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez" Name="#1">Se agregan campos para Terrapay y EasyPagos.</log>
<log Date="2023/04/14" Author="jdarellano">Se agrega validación para enviar siempre "ECUADOR" para EasyPagos.</log>
</ChangeLog>
******************************************* **************************/
BEGIN

	DECLARE @MinutsToWait	INT,
			@NextStatus		INT;
	
	SELECT 
		@MinutsToWait = CONVERT(INT, [Value]) 
	FROM dbo.GlobalAttributes WITH (NOLOCK)
	WHERE [Name] = 'TimeFromReadyToAttemp';

	SET @NextStatus = 21;

	SELECT 
		IdTransfer 
	INTO #Temp 
	FROM dbo.[Transfer] AS t WITH (NOLOCK)
	WHERE 
		DATEDIFF(MINUTE, DateOfTransfer, GETDATE()) > @MinutsToWait 
		AND IdGateway = @IdGateWay
		AND IdStatus = 20;

	UPDATE dbo.[Transfer] SET
		IdStatus = @NextStatus,
		DateStatusChange = GETDATE()
	WHERE IdTransfer IN (SELECT IdTransfer FROM #Temp);

	INSERT INTO dbo.TransferDetail (IdStatus,IdTransfer,DateOfMovement)
	SELECT
		@NextStatus,
		IdTransfer,
		GETDATE() 
	FROM #Temp;

	SELECT
		t.ClaimCode							IdReference,
		t.DateOfTransfer,
		t.CustomerName,
		t.CustomerFirstLastName,
		t.CustomerSecondLastName,
		t.CustomerAddress,
		t.CustomerCity,
		t.CustomerState						CustomerState,
		t.CustomerCountry					CustomerCountry,
		t.CustomerBornDate,
		t.BeneficiaryName,
		t.BeneficiaryFirstLastName,
		t.BeneficiarySecondLastName,
		t.BeneficiaryAddress,
		CASE 
			WHEN ISNULL(t.BeneficiaryCity, '') <> '' THEN t.BeneficiaryCity
			ELSE ct.CityName
		END BeneficiaryCity,
		CASE 
			WHEN ISNULL(t.BeneficiaryState, '') <> '' THEN t.BeneficiaryState
			ELSE st.StateName
		END BeneficiaryState,
		CASE 
			WHEN IdGateway = 56 THEN 'ECUADOR'
			WHEN ISNULL(t.BeneficiaryCountry, '') <> '' THEN t.BeneficiaryCountry
			ELSE co.CountryName
		END BeneficiaryCountry,
		t.BeneficiaryBornDate,
		t.BeneficiaryPhoneNumber,
		t.BeneficiaryCelularNumber,
		t.IdPaymentType						PaymentType,
		t.AmountInMN,
		t.AmountInDollars,
		t.ExRate,
		t.DepositAccountNumber,
		c.CurrencyCode						CurrencyCode,
		t.GatewayBranchCode					BranchCode,
		--#1 Begin
		p.PayerName,
		p.PayerCode,
		t.CustomerCelullarNumber			CustomerCelularNumber,
		d.Prefix							CustomerDialingCode,
		cASE 
			when t.IdGateway = 56 and  t.AccountTypeId = 1 then 'CC'
			when t.IdGateway = 56 and  t.AccountTypeId = 2 then 'CA'
			WHEN t.AccountTypeId = 1 then 'CHECKING' 
			WHEN t.AccountTypeId = 2 then 'SAVINGS'
		ELSE '' END 						AccountType,
		ci.Name								CustomerIdentificationType,
		t.CustomerIdentificationNumber,
		t.CustomerExpirationIdentification,
		t.Purpose,
		t.MoneySource,
		t.Relationship,
		d2.Prefix							BeneficiaryDialingCode,
		benid.[Name]						IdBeneficiaryIdentificationType,
		t.BeneficiaryIdentificationNumber	BeneficiaryIdentificationNumber
		--#1 End
	INTO #Result
	FROM dbo.[Transfer] t WITH(NOLOCK)
		-- Currency
		JOIN dbo.CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = t.IdCountryCurrency
		JOIN dbo.Currency c WITH(NOLOCK) ON c.IdCurrency = cc.IdCurrency
		JOIN dbo.Country co WITH(NOLOCK) ON cc.IdCountry = co.IdCountry

		-- Datos demograficos cliente
		LEFT JOIN dbo.Branch b WITH(NOLOCK) ON b.IdBranch = t.IdBranch
		LEFT JOIN dbo.City ct WITH(NOLOCK) ON ct.IdCity = b.IdCity
		LEFT JOIN dbo.[State] st WITH(NOLOCK) ON st.IdState = ct.IdState
		--JOIN Country co WITH(NOLOCK) ON st.IdCountry = co.IdCountry

		-- Datos del Pagador
		JOIN dbo.Payer p WITH(NOLOCK) ON p.IdPayer = t.IdPayer

		--Datos del Cliente
		JOIN dbo.Customer cu WITH(NOLOCK) ON cu.IdCustomer = t.IdCustomer
		LEFT JOIN dbo.DialingCodePhoneNumber d WITH(NOLOCK) ON d.IdDialingCodePhoneNumber = cu.IdDialingCodePhoneNumber
		LEFT JOIN dbo.CustomerIdentificationType ci WITH(NOLOCK) on t.CustomerIdCustomerIdentificationType=ci.IdCustomerIdentificationType

		--Datos del Beneficiario
		JOIN dbo.Beneficiary ben WITH(NOLOCK) ON ben.IdBeneficiary = t.IdBeneficiary
		LEFT JOIN dbo.DialingCodePhoneNumber d2 WITH(NOLOCK) ON d2.IdDialingCodePhoneNumber = ben.IdDialingCodePhoneNumber
		LEFT JOIN dbo.BeneficiaryIdentificationType benid WITH(NOLOCK) ON benid.IdBeneficiaryIdentificationType = t.IdBeneficiaryIdentificationType
	WHERE 
		t.IdGateway = @IdGateway 
		AND t.IdStatus = @NextStatus;

	IF @Limit > 0
		SELECT TOP (@Limit) r.* FROM #Result r;
	ELSE 
		SELECT r.* FROM #Result r;
END
