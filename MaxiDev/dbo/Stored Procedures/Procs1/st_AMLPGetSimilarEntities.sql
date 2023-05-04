CREATE PROCEDURE st_AMLPGetSimilarEntities
(
	@IdEntity		INT,
	@TypeEntity		VARCHAR(50),
	@DateFrom		DATE,
	@DateTo			DATE
)
AS
BEGIN
	DECLARE @Name			VARCHAR(200),
			@FirstLastName	VARCHAR(200),
			@SecondLastName	VARCHAR(200),
			@IsCustomer		BIT

	IF ISNULL(@TypeEntity, '') = 'Customer'
	BEGIN
		SET @IsCustomer = 1
		SELECT TOP 1
			@Name = c.Name,
			@FirstLastName = c.FirstLastName,
			@SecondLastName = c.SecondLastName
		FROM Customer c WITH (NOLOCK) 
		WHERE c.IdCustomer = @IdEntity
	END
	ELSE
	BEGIN
		SET @IsCustomer = 0
		SELECT TOP 1
			@Name = b.Name,
			@FirstLastName = b.FirstLastName,
			@SecondLastName = b.SecondLastName
		FROM Beneficiary b WITH (NOLOCK)
		WHERE b.IdBeneficiary = @IdEntity
	END

	DECLARE @LikeSentence		VARCHAR(500)

	SET @LikeSentence = CONCAT('%', @Name, '%', @FirstLastName, '%', @SecondLastName, '%')

	DECLARE @FindTransfers TABLE 
	(
		IdTransfer		INT,
		IdCustomer		INT,
		IdBeneficiary	INT
	)

	INSERT INTO @FindTransfers
	SELECT 
		t.IdTransfer,
		t.IdCustomer,
		t.IdBeneficiary
	FROM Transfer t WITH(NOLOCK) 
	WHERE 
		t.DateOfTransfer BETWEEN @DateFrom AND @DateTo
		AND 
		(
			(@IsCustomer = 1 AND CONCAT(t.CustomerName, t.CustomerFirstLastName, t.CustomerSecondLastName) LIKE @LikeSentence)
			OR 
			(@IsCustomer = 0 AND CONCAT(t.BeneficiaryName, t.BeneficiaryFirstLastName, t.BeneficiarySecondLastName) LIKE @LikeSentence)
		)
	UNION ALL
	SELECT
		t.IdTransferClosed IdTransfer,
		t.IdCustomer,
		t.IdBeneficiary
	FROM TransferClosed t WITH(NOLOCK)
	WHERE 
		t.DateOfTransfer BETWEEN @DateFrom AND @DateTo
		AND 
		(
			(@IsCustomer = 1 AND CONCAT(t.CustomerName, t.CustomerFirstLastName, t.CustomerSecondLastName) LIKE @LikeSentence)
			OR 
			(@IsCustomer = 0 AND CONCAT(t.BeneficiaryName, t.BeneficiaryFirstLastName, t.BeneficiarySecondLastName) LIKE @LikeSentence)
		)

	DECLARE @Transfers TABLE (Id INT)

	IF @IsCustomer = 1
		INSERT INTO @Transfers
		SELECT
			MAX(ft.IdTransfer) 
		FROM @FindTransfers ft 
		GROUP BY ft.IdCustomer
	ELSE
		INSERT INTO @Transfers
		SELECT
			MAX(ft.IdTransfer) 
		FROM @FindTransfers ft 
		GROUP BY ft.IdBeneficiary

	;WITH AllTransfers AS
	(
		SELECT
			t.IdTransfer,
			'Transfer' [Type],
			t.DateOfTransfer,
			t.Folio,
			t.IdCountryCurrency,
			t.IdBeneficiary,
			CONCAT(T.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
			t.IdCustomer,
			CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
			t.IdBranch BranchSend,
			t.AmountInDollars,
			t.IdPaymentType,
			t.IdStatus,
			t.EnterByIdUser,
			t.IdAgent,
			t.IdBranch
		FROM Transfer t WITH(NOLOCK)
			JOIN @Transfers tt ON tt.Id = t.IdTransfer
		UNION ALL
		SELECT
			t.IdTransferClosed IdTransfer,
			'TransferClosed' [Type],
			t.DateOfTransfer,
			t.Folio,
			t.IdCountryCurrency,
			t.IdBeneficiary,
			CONCAT(T.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
			t.IdCustomer,
			CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
			t.IdBranch BranchSend,
			t.AmountInDollars,
			t.IdPaymentType,
			t.IdStatus,
			t.EnterByIdUser,
			t.IdAgent,
			t.IdBranch
		FROM TransferClosed t WITH(NOLOCK)
			JOIN @Transfers tt ON tt.Id = t.IdTransferClosed
	)
	SELECT
		t.IdTransfer,
		t.Type,
		t.DateOfTransfer,
		a.AgentCode,
		t.Folio,
		t.IdCustomer,
		t.Customer,
		t.IdBeneficiary,
		t.Beneficiary,
		t.AmountInDollars,
		st.StatusName,
		us.UserName,
		stateSent.StateCode StateSent,
		statePaid.StateCode StatePaid,
		pt.PaymentName,
		a.AgentName
	FROM AllTransfers t WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Status st WITH(NOLOCK) ON st.IdStatus = t.IdStatus
		JOIN Users us WITH(NOLOCK) ON us.IdUser = t.EnterByIdUser
		JOIN Branch branchSent WITH(NOLOCK) ON branchSent.IdBranch = t.IdBranch
		JOIN City citySent WITH(NOLOCK) ON citySent.IdCity = branchSent.IdCity
		JOIN State stateSent WITH(NOLOCK) ON stateSent.IdState = citySent.IdState
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = t.IdPaymentType
		LEFT JOIN (
			SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo 
			FROM TransferPayInfo WITH(NOLOCK)
			GROUP BY IdTransfer
		) pay ON t.IdTransfer = pay.IdTransfer
		LEFT JOIN TransferPayInfo payt WITH(NOLOCK) ON pay.IdTransferPayInfo = payt.IdTransferPayInfo
		LEFT JOIN Branch branchPaid WITH(NOLOCK) ON PAYT.IdBranch = branchPaid.IdBranch
		LEFT JOIN City cityPaid WITH(NOLOCK) ON branchPaid.IdCity = cityPaid.IdCity
		LEFT JOIN State statePaid WITH(NOLOCK) ON cityPaid.IdState= statePaid.IdState
END