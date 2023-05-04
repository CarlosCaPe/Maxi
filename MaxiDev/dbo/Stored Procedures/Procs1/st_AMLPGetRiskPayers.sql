CREATE PROCEDURE st_AMLPGetRiskPayers
AS
BEGIN
	SELECT
		rp.IdRiskPayer,
		rp.IdPayer,
		rp.IdPaymentType,
		rp.RiskValue
	FROM AMLP_RiskPayer rp
END