CREATE PROCEDURE st_FetchTransfers
(
	@IdAgent		INT,
	@IdCustomer		INT,

	@StartDate		DATE,
	@EndDate		DATE,

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN
	;WITH AllTransfers AS 
	(	
		SELECT
			t.IdTransfer,
			t.IdAgent,
			t.IdCustomer,
			t.ClaimCode,
			t.DateOfTransfer,
			t.CustomerName,
			t.CustomerFirstLastName,
			t.CustomerSecondLastName,
			t.CustomerAddress,
			t.CustomerCity,
			t.CustomerState,
			t.CustomerCountry,
			t.CustomerBornDate,
			t.BeneficiaryName,
			t.BeneficiaryFirstLastName,
			t.BeneficiarySecondLastName,
			t.BeneficiaryAddress,
			t.BeneficiaryCity,
			t.BeneficiaryState,
			t.BeneficiaryCountry,
			t.BeneficiaryBornDate,
			t.BeneficiaryPhoneNumber,
			t.BeneficiaryCelularNumber,
			t.IdPaymentType,
			t.AmountInMN,
			t.AmountInDollars,
			t.ExRate,
			t.DepositAccountNumber,
			cu.CurrencyCode,
			t.GatewayBranchCode BranchCode
		FROM Transfer t WITH (NOLOCK)
			JOIN CountryCurrency cc WITH (NOLOCK) ON cc.IdCountryCurrency = t.IdCountryCurrency
			JOIN Currency cu WITH (NOLOCK) ON cu.IdCurrency = cc.IdCurrency
		WHERE 
			(@IdAgent IS NULL OR t.IdAgent = @IdAgent)
			AND (@IdCustomer IS NULL OR t.IdCustomer = @IdCustomer)
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
		UNION ALL
		SELECT
			tc.IdTransferClosed IdTransfer,
			tc.IdAgent,
			tc.IdCustomer,
			tc.ClaimCode,
			tc.DateOfTransfer,
			tc.CustomerName,
			tc.CustomerFirstLastName,
			tc.CustomerSecondLastName,
			tc.CustomerAddress,
			tc.CustomerCity,
			tc.CustomerState,
			tc.CustomerCountry,
			tc.CustomerBornDate,
			tc.BeneficiaryName,
			tc.BeneficiaryFirstLastName,
			tc.BeneficiarySecondLastName,
			tc.BeneficiaryAddress,
			tc.BeneficiaryCity,
			tc.BeneficiaryState,
			tc.BeneficiaryCountry,
			tc.BeneficiaryBornDate,
			tc.BeneficiaryPhoneNumber,
			tc.BeneficiaryCelularNumber,
			tc.IdPaymentType,
			tc.AmountInMN,
			tc.AmountInDollars,
			tc.ExRate,
			tc.DepositAccountNumber,
			cu.CurrencyCode,
			tc.GatewayBranchCode BranchCode
		FROM TransferClosed tc WITH (NOLOCK)
			JOIN CountryCurrency cc WITH (NOLOCK) ON cc.IdCountryCurrency = tc.IdCountryCurrency
			JOIN Currency cu WITH (NOLOCK) ON cu.IdCurrency = cc.IdCurrency
		WHERE 
			(@IdAgent IS NULL OR tc.IdAgent = @IdAgent)
			AND (@IdCustomer IS NULL OR tc.IdCustomer = @IdCustomer)
			AND CONVERT(DATE, tc.DateOfTransfer) BETWEEN @StartDate AND @EndDate
	)
	SELECT
		COUNT(*) OVER() _PagedResult_Total,
		t.*
	FROM AllTransfers t
	ORDER BY t.DateOfTransfer
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
