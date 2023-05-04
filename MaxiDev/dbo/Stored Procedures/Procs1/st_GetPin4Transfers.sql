CREATE PROCEDURE [dbo].[st_GetPin4Transfers]
AS 
BEGIN

	DECLARE @MinutsToWait	INT,
			@NextStatus		INT,
			@IdGateway		INT
	
	SET @IdGateway = 53 --46

	SELECT 
		@MinutsToWait = Convert(INT, Value) 
	FROM GlobalAttributes WITH(NOLOCK)
	WHERE Name='TimeFromReadyToAttemp'

	SET @NextStatus = 21

	SELECT 
		IdTransfer 
	INTO #Temp 
	FROM Transfer t WITH(NOLOCK)
	WHERE 
		DATEDIFF(MINUTE, DateOfTransfer, GETDATE()) > @MinutsToWait 
		AND IdGateway = @IdGateway
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

	DECLARE @NewTransferSMS VARCHAR(500)
	SELECT 
		@NewTransferSMS = sa.Value
	FROM ServiceAttributes sa WITH(NOLOCK) 
		JOIN Gateway g WITH(NOLOCK) ON g.Code = sa.Code
	WHERE g.IdGateway = @IdGateway
	AND sa.AttributeKey = 'NewTransfer_SMS'

	DECLARE @DefaultPrefix VARCHAR(20) = dbo.GetGlobalAttributeByName('InfiniteCountryCode')

	SELECT
		t.IdTransfer,

		CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) SenderName,
		t.CustomerCelullarNumber															SenderPhone,
		ISNULL(dcCust.Prefix, @DefaultPrefix)												SenderPhonePrefix,

		t.DepositAccountNumber																BeneficiaryPhone,
		ISNULL(dcBen.Prefix, @DefaultPrefix)												BeneficiaryPhonePrefix,

		t.AmountInDollars																	IssuerAmount,
		'USD'																				IssuerCurrency,

		t.ClaimCode																			ClaimCode,

		RIGHT(t.ClaimCode, 4)																SecretKey,

		destc.CountryCodeISO3166															AcquirerCountry,
		NULL																				OrderReleaseDate,

		'ENG'																				BeneficiaryLanguage,
		'ENG'																				SenderLanguage,

		@NewTransferSMS																		[Messages]
	FROM Transfer t WITH(NOLOCK)
		-- Currency
		JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = t.IdCountryCurrency
		JOIN Country destc WITH(NOLOCK) ON destc.IdCountry = cc.IdCountry
		JOIN Currency c WITH(NOLOCK) ON c.IdCurrency = cc.IdCurrency

		LEFT JOIN DialingCodePhoneNumber dcCust WITH(NOLOCK) ON dcCust.IdDialingCodePhoneNumber = t.IdDialingCodePhoneNumber
		LEFT JOIN DialingCodePhoneNumber dcBen WITH(NOLOCK) ON dcBen.IdDialingCodePhoneNumber = t.IdDialingCodeBeneficiaryPhoneNumber

		JOIN Customer cu WITH(NOLOCK) ON cu.IdCustomer = t.IdCustomer
	WHERE 
		t.IdStatus = @NextStatus
		AND t.IdGateway = @IdGateway
	ORDER BY t.IdTransfer
END
