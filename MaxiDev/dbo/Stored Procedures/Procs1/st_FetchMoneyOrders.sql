/********************************************************************
<Author>Arcadio Contreras</Author>
<Description>Consultar el listado de Money Orders</Description>

<ChangeLog>
	<log Date="03/01/2023" Author="acontreras">Se crea sp</log>
	<log Date="03/08/2023" Author="jcsierra">Se agrega filtro para descartar los MO en Origin</log>
	<log Date="03/16/2023" Author="jcsierra">Fix column PayToOrder</log>
	<log Date="03/20/2023" Author="jcsierra">Fix order by dataset</log>
</ChangeLog>
*********************************************************************/
CREATE   PROCEDURE [dbo].[st_FetchMoneyOrders]
(
	@StartDate		   DATETIME,
	@EndDate		   DATETIME,
	@Status			   INT,
	@IdAgent	       INT,
	@Customer          VARCHAR(200),
	@SequenceNumber    VARCHAR(200),
	@Offset			   BIGINT,
	@Limit			   BIGINT
)
AS
BEGIN
	SELECT	
		sr.IdSaleRecord,
		sr.CreationDate,
		sr.IdAgent,
		a.AgentName,
		a.AgentCode,
		sr.SequenceNumber,
		CONCAT(sr.CustomerName, ' ', sr.CustomerFirstLastName, ' ', sr.CustomerSecondLastName) customer,
		sr.CustomerCelullarNumber phone,
		sr.Payee PayToOrder,
		sr.IdStatus,
		s.StatusName,
		sr.TotalAmount total,
		COUNT(*) OVER() _PagedResult_Total
	FROM MoneyOrder.SaleRecord sr WITH (NOLOCK) 
		INNER JOIN Agent a WITH (NOLOCK)  ON a.IdAgent = sr.IdAgent
		INNER JOIN Status s WITH (NOLOCK)  ON s.IdStatus = sr.IdStatus
	WHERE
		(@Customer IS NULL OR CONCAT(sr.CustomerName, ' ', sr.CustomerFirstLastName, ' ', sr.CustomerSecondLastName) LIKE CONCAT('%', @Customer, '%'))
		AND (@SequenceNumber IS NULL OR sr.SequenceNumber LIKE CONCAT('%', @SequenceNumber, '%'))
		AND (@IdAgent IS NULL OR sr.IdAgent = @IdAgent) 
		AND (@Status IS NULL OR sr.IdStatus = @Status)
		AND CONVERT(DATE, sr.CreationDate) BETWEEN @StartDate AND @EndDate
		AND sr.IdStatus <> 1
	ORDER BY sr.CreationDate DESC
		OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
