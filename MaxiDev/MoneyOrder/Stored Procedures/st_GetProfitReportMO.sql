-- =============================================
-- Author:		Jesús Batta 
-- Create date: 2023-03-28
-- Description:	Report Profit Money Orders
-- =============================================
CREATE PROCEDURE [MoneyOrder].[st_GetProfitReportMO]
	@InitialDateInput DATE, 
	@FinalDateInput DATE
AS
BEGIN
	SET NOCOUNT ON;
    WITH records AS (
		SELECT
			IdAgent,
			IdStatus,
			Amount,
			FeeAmount,
			AgentCommission,
			CreationDate,
			DateOfLastChange,
			IdAgentPaymentSchema
		FROM MoneyOrder.SaleRecord WITH (NOLOCK)
		WHERE CreationDate BETWEEN @InitialDateInput AND DATEADD(day, 1, @FinalDateInput)
	), records_rep as (
	SELECT
		r.*,
		a.AgentCode as AgentCode,
		a.AgentName as AgentName,
		u.UserName as SalesRep,
		--m.UserName as Manager
		NULL as Manager
	FROM records r WITH (NOLOCK)
	INNER JOIN Agent a WITH (NOLOCK) ON a.IdAgent = r.IdAgent
	INNER JOIN Users u  WITH (NOLOCK) ON a.IdUserSeller = u.IdUser
	LEFT JOIN Seller s  WITH (NOLOCK) ON s.IdUserSeller = u.IdUser
	--LEFT JOIN Users m  WITH (NOLOCK) ON s.IdUserSellerParent = m.IdUser
	), agent_records as (
	SELECT
		IdAgent,
		AgentCode,
		AgentName,
		SalesRep,
		Manager,
		SUM(1) as NumberTotal,
		SUM(CASE WHEN (IdStatus = 77 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN 1 ELSE 0 END) as NumberVoid,
		SUM(CASE WHEN (IdStatus = 75 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN 1 ELSE 0 END) as NumberStopPayment,
		SUM(Amount) as AmountTotal,
		SUM(CASE WHEN (IdStatus = 77 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN Amount ELSE 0 END) as AmountVoid,
		SUM(CASE WHEN (IdStatus = 75 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN Amount ELSE 0 END) as AmountStopPayment,
		SUM(Amount) as COGSTotal,
		SUM(CASE WHEN (IdStatus = 77 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN Amount ELSE 0 END) as COGSVoid,
		SUM(CASE WHEN (IdStatus = 75 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN Amount ELSE 0 END) as COGSStopPayment,
		SUM(FeeAmount) as FeeTotal,
		SUM(CASE WHEN (IdStatus = 77 and DateOfLastChange < DATEADD(day, 1, @FinalDateInput)) THEN FeeAmount ELSE 0 END) as FeeVoid,
		0 as FeeStopPayment, -- this column is excluded from the final result
		SUM(CASE WHEN IdAgentPaymentSchema = 1 THEN AgentCommission ELSE 0 END) as ComMonth,
		SUM(CASE WHEN IdAgentPaymentSchema = 2 THEN AgentCommission ELSE 0 END) as ComRet
	FROM records_rep
	GROUP BY IdAgent, AgentCode, AgentName, SalesRep, Manager
	), pre_report as (
	SELECT *,
		NumberTotal - NumberVoid as NumberNet,
		AmountTotal - AmountVoid as AmountNet,
		COGSTotal - COGSVoid as COGSNet,
		FeeTotal - FeeVoid + FeeStopPayment as FeeNet  -- verify how to admin charges will be included here
	FROM agent_records
	), report as (
	SELECT 
		p.*,
		p.FeeNet - p.ComMonth - p.ComRet as Profit,
		CASE WHEN p.NumberNet != 0 THEN (p.FeeNet - p.ComMonth - p.ComRet) / p.NumberNet ELSE NULL END as Margin
	FROM pre_report p 
	)
	SELECT 
	 AgentCode,
	 AgentName,
	 SalesRep,
	 NumberTotal,
	 NumberVoid,
	 --NumberStopPayment,
	 NumberNet,
	 AmountTotal,
	 AmountVoid,
	 --AmountStopPayment,
	 AmountNet,
	 COGSTotal,
	 COGSVoid,
	 --COGSStopPayment,
	 COGSNet,
	 FeeTotal,
	 FeeVoid,
	 --FeeStopPayment, -- retired from final report
	 FeeNet,
	 ComMonth,
	 ComRet,
	 NULL as PayerFee,  -- review what will happens with this field
	 Profit,
	 Margin,
	 Manager
	FROM report
END
