CREATE PROCEDURE st_FetchBankDeposits
(
	@IdBankDepositFile			INT,
	@StartDate					DATE,
	@EndingDate					DATE,
	@FilterDate					VARCHAR(20),	-- DepositDate, TransactionDate, None
	@Description				INT,
	@StartAmount				MONEY,
	@EndingAmount				MONEY,
	@Reference					VARCHAR(200),
	@Details					VARCHAR(1000)
)
AS
BEGIN
	DECLARE @SearchByDate BIT = IIF(@StartDate IS NOT NULL AND @EndingDate IS NOT NULL AND @FilterDate IN ('DepositDate', 'TransactionDate'), 1, 0)
	DECLARE @SearchByAmount BIT = IIF(@StartAmount IS NOT NULL AND @EndingAmount IS NOT NULL, 1, 0)
	
	SELECT
		bd.*,
		ab.IdAgentBalance	AgentBalance_IdAgentBalance,
		ab.IdAgent			AgentBalance_IdAgent,
		ab.TypeOfMovement	AgentBalance_TypeOfMovement,
		ab.DateOfMovement	AgentBalance_DateOfMovement,
		ab.Amount			AgentBalance_Amount,
		ab.Reference		AgentBalance_Reference,
		ab.Description		AgentBalance_Description,
		ab.Country			AgentBalance_Country,
		ab.Commission		AgentBalance_Commission,
		ab.DebitOrCredit	AgentBalance_DebitOrCredit,
		ab.Balance			AgentBalance_Balance,
		ab.IdTransfer		AgentBalance_IdTransfer,
		ab.FxFee			AgentBalance_FxFee,
		ab.IsMonthly		AgentBalance_IsMonthly
	FROM BankDeposit bd WITH(NOLOCK)
		LEFT JOIN ConciliationMatch cm WITH(NOLOCK) ON cm.IdBankDeposit = bd.IdBankDeposit
		LEFT JOIN AgentDeposit ad WITH(NOLOCK) ON ad.IdAgentDeposit = cm.IdAgentDeposit
		LEFT JOIN AgentBalance ab WITH(NOLOCK) ON ab.IdAgentBalance = ad.IdAgentBalance
	WHERE
		bd.IdBankDepositFile = @IdBankDepositFile
		AND (
			@SearchByDate = 0 
			OR 
			(
				(@FilterDate = 'DepositDate' AND bd.DepositDate BETWEEN @StartDate AND @EndingDate)
				OR (@FilterDate = 'TransactionDate' AND bd.TransactionDate BETWEEN @StartDate AND @EndingDate)
			)
		)
		AND (ISNULL(@Description, '') = '' OR bd.Description LIKE CONCAT('%', @Description ,'%'))
		AND (@SearchByAmount = 0 OR bd.Amount BETWEEN @StartAmount AND @EndingAmount)
		AND (ISNULL(@Reference, '') = '' OR bd.Reference LIKE CONCAT('%', @Reference ,'%'))
		AND (ISNULL(@Details, '') = '' OR bd.Details LIKE CONCAT('%', @Details ,'%'))
END
