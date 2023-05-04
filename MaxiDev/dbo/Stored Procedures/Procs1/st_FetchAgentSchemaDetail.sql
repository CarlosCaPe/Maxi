CREATE PROCEDURE st_FetchAgentSchemaDetail
(
	@IdAgent					BIGINT,
	@IdAgentSchema				BIGINT,

	@Offset						BIGINT,
	@Limit						BIGINT
)
AS
BEGIN
	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		sd.IdAgentSchemaDetail,
		sd.IdAgentSchema,
		sd.IdPayerConfig,
		CONCAT(p.PayerName, ' - ', pt.PaymentName) PayerSumarry,
		sd.SpreadValue,
		sd.DateOfLastChange,
		sd.EnterByIdUser,
		
		-- Fee
		sd.IdFee				Fee_IdFee,
		f.FeeName				Fee_FeeName,
		f.DateOfLastChange		Fee_DateOfLastChange,
		f.EnterByIdUser			Fee_EnterByIdUser,

		-- Comission
		sd.IdCommission			Commission_IdCommission,
		c.CommissionName		Commission_CommissionName,
		c.DateOfLastChange		Commission_DateOfLastChange,
		c.EnterByIdUser			Commission_EnterByIdUser,

		-- Spread
		sd.IdSpread				Spread_IdSpread,
		sp.SpreadName			Spread_SpreadName,
		sp.DateOfLastChange		Spread_DateOfLastChange,
		sp.EnterByIdUser		Spread_EnterByIdUser,

		sd.TempSpread,
		sd.EndDateTempSpread
	--INTO #Result
	FROM AgentSchemaDetail sd WITH(NOLOCK)
		JOIN AgentSchema s WITH(NOLOCK) ON s.IdAgentSchema = sd.IdAgentSchema

		LEFT JOIN Fee f WITH(NOLOCK) ON f.IdFee = sd.IdFee
		LEFT JOIN Commission c WITH(NOLOCK) ON c.IdCommission = sd.IdCommission
		LEFT JOIN Spread sp WITH(NOLOCK) ON sp.IdSpread = sd.IdSpread
		
		JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = sd.IdPayerConfig
		JOIN Payer p WITH(NOLOCK) ON p.IdPayer = pc.IdPayer
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = pc.IdPaymentType
	WHERE
		s.IdAgent = @IdAgent
		AND sd.IdAgentSchema = @IdAgentSchema
	ORDER BY sd.IdAgentSchemaDetail
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

	--SELECT * FROM #Result


	--SELECT DISTINCT
	--	f.*
	--FROM Fee f WITH(NOLOCK)
	--	JOIN #Result sd ON sd.IdFee = f.IdFee

	--SELECT DISTINCT
	--	c.*
	--FROM Commission c WITH(NOLOCK)
	--	JOIN #Result sd ON sd.IdCommission = c.IdCommission
		
END
