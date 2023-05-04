/********************************************************************
<Author> jfresendiz </Author>
<app> Corporative </app>
<Description>Regresa los MO que detonaron alguna regla de KYC</Description>
	
<ChangeLog>
	<log Date="03/08/2023" Author="jfresendiz">Se crea SP</log>
	<log Date="21/03/2023" Author="jfresendiz">BM-1401 Se corrige el parámetro offset para regresar la cantidad correcto de resultados</log>
</ChangeLog>
*********************************************************************/
CREATE   PROCEDURE [MoneyOrder].[st_GetMoneyOrdersDetonateKYC]
(
	@Offset	INT = 0,
	@Limit	INT = 500
)
AS 
BEGIN
	SELECT sr.IdSaleRecord, 
		sr.CreationDate, 
		br.IdRule,
		a.IdAgent,
		a.AgentCode, 
		a.AgentName, 
		sr.SequenceNumber, 
		(sr.CustomerName + ' ' + sr.CustomerFirstLastName + ' ' + sr.CustomerSecondLastName) as Customer, 
		sr.CustomerCelullarNumber, 
		sr.Payee, 
		sr.IdStatus, 
		s.StatusName , 
		sr.TotalAmount,
		COUNT(*) OVER() TotalRows
	FROM Agent a WITH(NOLOCK) 
		JOIN MoneyOrder.SaleRecord sr WITH(NOLOCK) ON a.IdAgent = sr.IdAgent
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = sr.IdStatus 
		JOIN MoneyOrder.SaleRecordBrokenRules br WITH(NOLOCK) ON sr.IdSaleRecord = br.IdSaleRecord 
	WHERE 
		sr.IdSaleRecord NOT IN (SELECT srh.IdSaleRecord FROM MoneyOrder.SaleRecordHold srh WITH(NOLOCK) WHERE srh.IsReleased = 1)
		AND sr.IdStatus <> 1
	ORDER BY sr.CreationDate
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
