CREATE PROCEDURE [Soporte].[st_GetTransfersForRemoteUsers]
AS
BEGIN
	DECLARE @Date DATETIME = DATEADD(HOUR, -2, GETDATE())
	DECLARE @Users TABLE (Id INT)
	
	INSERT INTO @Users
	SELECT
		u.IdUser
	FROM Users u WITH(NOLOCK)
	WHERE u.UserLogin IN 
	(
		'mxegonzalez',
		'mxjlopez',
		'mxmloera',
		'mxgurbina',
		'mxdaislas',
		'mxraarrambide',
		'mxjjtrevino',
		'mxkelorza',
		'mxlahernandez',
		'mxmeche',
		'mxemalvarez',
		'mxmagarcia',
		'mxnjgomez',
		'mxagarciaa',
		'mxrrodriguez',
		'mxvmramirez'
	)

	SELECT 
		us.UserName,
		CONVERT(VARCHAR, t.DateOfTransfer, 1) [Date],
		CONVERT(VARCHAR, t.DateOfTransfer, 108) [Time],
		a.AgentCode,
		pt.PaymentName,
		s.StatusName,
		p.PayerName,
		t.Folio,
		t.AmountInDollars,
		CONCAT(t.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
		CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
		ct.CityName,
		st.StateName,
		cty.CountryName
	FROM Transfer t WITH(NOLOCK)
		JOIN @Users u ON u.Id = t.EnterByIdUser

		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Users us WITH(NOLOCK) ON us.IdUser = u.Id
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = t.IdPaymentType
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = t.IdStatus
		JOIN Payer p WITH(NOLOCK) ON p.IdPayer = t.IdPayer

		-- Datos demograficos
		JOIN Branch br WITH(NOLOCK) ON br.IdBranch = t.IdBranch
		JOIN City ct WITH(NOLOCK) ON ct.IdCity = br.IdCity
		JOIN State st WITH(NOLOCK) ON st.IdState = ct.IdState
		JOIN Country cty WITH(NOLOCK) ON cty.IdCountry = st.IdCountry
	WHERE 
		CONVERT(DATE, t.DateOfTransfer) >= @Date
	UNION
	SELECT 
		us.UserName,
		CONVERT(VARCHAR, t.DateOfTransfer, 1) [Date],
		CONVERT(VARCHAR, t.DateOfTransfer, 108) [Time],
		a.AgentCode,
		pt.PaymentName,
		s.StatusName,
		p.PayerName,
		t.Folio,
		t.AmountInDollars,
		CONCAT(t.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
		CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
		ct.CityName,
		st.StateName,
		cty.CountryName
	FROM TransferClosed t WITH(NOLOCK)
		JOIN @Users u ON u.Id = t.EnterByIdUser

		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Users us WITH(NOLOCK) ON us.IdUser = u.Id
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = t.IdPaymentType
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = t.IdStatus
		JOIN Payer p WITH(NOLOCK) ON p.IdPayer = t.IdPayer

		-- Datos demograficos
		JOIN Branch br WITH(NOLOCK) ON br.IdBranch = t.IdBranch
		JOIN City ct WITH(NOLOCK) ON ct.IdCity = br.IdCity
		JOIN State st WITH(NOLOCK) ON st.IdState = ct.IdState
		JOIN Country cty WITH(NOLOCK) ON cty.IdCountry = st.IdCountry
	WHERE 
		CONVERT(DATE, t.DateOfTransfer) >= @Date
	ORDER BY UserName, Date, Time
END